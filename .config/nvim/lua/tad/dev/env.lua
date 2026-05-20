-- Dev Setup
--
-- Per-project configuration lives in .nvim-dev.lua at project root.

local M = {}

---@class DevState
---@field main_win? integer main editing window id
---@field output_win? integer command output window id
---@field output_buf? integer command output buffer id (persistent)
---@field proc? vim.SystemObj currently running command process
local state

---@return DevState
local function default_state()
	return {
		main_win = nil,
		output_win = nil,
		output_buf = nil,
		proc = nil,
	}
end

state = default_state()

local USER_CMDS = {
	run = "DRun",
	cmd = "DCmd",
	config = "DevConfig",
	qf = "DevQf",
	reload = "DevReload",
	close = "DevClose",
}

local DEFAULT_COMMANDS = {
	build = "./run.sh build",
	lint = "./run.sh lint",
	clean = "./run.sh clean",
	test = "./run.sh test",
}

local CONFIG_TEMPLATE = [[-- .nvim-dev.lua
-- :DRun <key> completions

return {
  build = "./run.sh build",
  lint = "./run.sh lint",
  clean = "./run.sh clean",
  test = "./run.sh test",
}
]]

local function load_project_commands()
	local config_path = vim.fn.getcwd() .. "/.nvim-dev.lua"
	local ok, cmds = pcall(dofile, config_path)
	if ok and type(cmds) == "table" then
		return cmds
	end
	return vim.deepcopy(DEFAULT_COMMANDS)
end

local function output_buf_create()
	if state.output_buf and vim.api.nvim_buf_is_valid(state.output_buf) then
		return state.output_buf
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(buf, "dev output")

	local opts = { buf = buf }
	vim.api.nvim_set_option_value("buftype", "nofile", opts)
	vim.api.nvim_set_option_value("bufhidden", "hide", opts)
	vim.api.nvim_set_option_value("swapfile", false, opts)
	vim.api.nvim_set_option_value("filetype", "dev.output", opts)

	return buf
end

local function output_buf_set(lines, append)
	vim.api.nvim_buf_set_lines(state.output_buf, append and -1 or 0, -1, false, lines)
end

local function output_append(lines)
	if state.output_buf and vim.api.nvim_buf_is_valid(state.output_buf) then
		output_buf_set(lines, true)
	end
end

local function output_ensure_win()
	if state.output_win and vim.api.nvim_win_is_valid(state.output_win) then
		vim.api.nvim_win_set_buf(state.output_win, state.output_buf)
		return
	end

	local win = vim.api.nvim_open_win(state.output_buf, false, {
		width = math.floor(vim.o.columns * 0.35),
		split = "left",
		style = "minimal",
	})

	vim.api.nvim_set_option_value("wrap", false, { win = win })

	state.output_win = win
end

local function parse_ref_under_cursor()
	local line = vim.api.nvim_get_current_line()
	local patterns = {
		"([%w%.%/%\\%-_]+%.%a+):(%d+):%d+:",
		"([%w%.%/%\\%-_]+%.%a+):(%d+),",
		"([%w%.%/%\\%-_]+%.%a+):(%d+)",
	}
	for _, p in ipairs(patterns) do
		local file, lnum = line:match(p)
		if file and lnum then
			return { file = file, line = tonumber(lnum) }
		end
	end
	return nil
end

local function jump_to_output_ref()
	local ref = parse_ref_under_cursor()

	if not ref then
		vim.notify("[dev] no file:line reference found on this line", vim.log.levels.WARN)
		return
	end

	if not vim.loop.fs_stat(ref.file) then
		local cwd_path = vim.fn.getcwd() .. "/" .. ref.file
		if vim.loop.fs_stat(cwd_path) then
			ref.file = cwd_path
		else
			vim.notify("[dev] cannot find file: " .. ref.file, vim.log.levels.ERROR)
			return
		end
	end

	if state.main_win and vim.api.nvim_win_is_valid(state.main_win) then
		vim.api.nvim_set_current_win(state.main_win)
	end

	local abs = vim.fn.fnamemodify(ref.file, ":p")
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) == abs then
			vim.api.nvim_set_current_buf(buf)
			vim.api.nvim_win_set_cursor(0, { ref.line, 0 })
			vim.cmd("normal! zz")
			return
		end
	end

	vim.cmd("edit " .. vim.fn.fnameescape(ref.file))
	vim.api.nvim_win_set_cursor(0, { ref.line, 0 })
	vim.cmd("normal! zz")
end

local function populate_quickfix(lines)
	if not lines and not (state.output_buf and vim.api.nvim_buf_is_valid(state.output_buf)) then
		return
	end

	lines = lines or vim.api.nvim_buf_get_lines(state.output_buf, 0, -1, false)

	local qflist = vim.fn.getqflist({ lines = lines }).items
	local cwd = vim.fn.getcwd()

	local qf_items = {}
	for _, item in ipairs(qflist) do
		if item.bufnr == 0 and item.filename then
			local abs = cwd .. "/" .. item.filename
			if vim.loop.fs_stat(abs) then
				item.filename = abs
				item.bufnr = nil
			end
		end
		if item.valid == 1 or (item.bufnr and item.bufnr > 0) then
			table.insert(qf_items, item)
		end
	end

	vim.fn.setqflist({}, "r", {
		title = "dev",
		items = qf_items,
	})
end

function M.run(cmd)
	if state.proc and not state.proc:is_closing() then
		state.proc:kill("sigterm")
		state.proc = nil
	end

	output_ensure_win()

	output_buf_set({
		"[" .. os.date("%Y-%m-%d %H:%M:%S") .. "] > " .. cmd,
	}, false)

	state.proc = vim.system({ "sh", "-c", cmd }, {
		text = true,
	}, function(out)
		state.proc = nil

		vim.schedule(function()
			output_append({ out.code == 0 and " ✓ exited 0" or (" ✗ exited " .. out.code), "" })

			local lines = {}
			if out.stdout and out.stdout ~= "" then
				vim.list_extend(lines, vim.split(out.stdout, "\n", { trimempty = true }))
				table.insert(lines, "")
			end
			lines = vim.list_extend(lines, vim.split(out.stderr, "\n", { trimempty = true }))

			output_append(lines)
			populate_quickfix(lines)
		end)
	end)

	if state.proc == 0 or state.proc == -1 then
		vim.notify("[dev] failed to run: " .. cmd, vim.log.levels.ERROR)
		state.proc = nil
	end
end

function M.run_project_command(name)
	local cmds = load_project_commands()
	local cmd = cmds[name]
	if cmd then
		M.run(cmd)
	else
		vim.notify("[dev] unknown command: " .. tostring(name), vim.log.levels.ERROR)
	end
end

function M.pick_project_command()
	local cmds = load_project_commands()
	local names = vim.tbl_keys(cmds)
	table.sort(names)
	vim.ui.select(names, {
		prompt = "Run project command:",
		format_item = function(name)
			return string.format("%-12s  %s", name, cmds[name])
		end,
	}, function(choice)
		if choice then
			M.run_project_command(choice)
		end
	end)
end

function M.setup()
	if state.output_buf and vim.api.nvim_buf_is_valid(state.output_buf) then
		output_ensure_win()
		return
	end

	state.main_win = vim.api.nvim_get_current_win()
	state.output_buf = output_buf_create()
	output_ensure_win()

	for _, sc in ipairs({
		{ key = "b", name = "build" },
		{ key = "l", name = "lint" },
		{ key = "t", name = "test" },
		{ key = "c", name = "clean" },
	}) do
		vim.keymap.set("n", "<Leader><Leader>g" .. sc.key, function()
			M.run_project_command(sc.name)
		end, { noremap = true, silent = true, desc = "dev: run project " .. sc.name })
	end

	vim.keymap.set(
		"n",
		"<CR>",
		jump_to_output_ref,
		{ noremap = true, silent = true, buffer = state.output_buf, desc = "dev: jump to error" }
	)

	vim.api.nvim_create_user_command(USER_CMDS.run, function(a)
		local name = vim.trim(a.args)
		if name == "" then
			M.pick_project_command()
		else
			M.run_project_command(name)
		end
	end, {
		nargs = "?",
		complete = function()
			return vim.tbl_keys(load_project_commands())
		end,
		desc = "dev: run project command",
	})

	vim.api.nvim_create_user_command(USER_CMDS.cmd, function(a)
		M.run(a.args)
	end, { nargs = "+", desc = "dev: run arbitrary command" })

	vim.api.nvim_create_user_command(USER_CMDS.config, function()
		local path = vim.fn.getcwd() .. "/.nvim-dev.lua"
		if vim.fn.filereadable(path) == 0 then
			local f = io.open(path, "w")
			if f then
				f:write(CONFIG_TEMPLATE)
				f:close()
			else
				vim.notify("[dev] could not create " .. path, vim.log.levels.ERROR)
				return
			end
		end
		if state.main_win and vim.api.nvim_win_is_valid(state.main_win) then
			vim.api.nvim_set_current_win(state.main_win)
		end
		vim.cmd("edit " .. vim.fn.fnameescape(path))
	end, { desc = "dev: create/open .nvim-dev.lua project config" })

	vim.api.nvim_create_user_command(USER_CMDS.qf, function()
		populate_quickfix()
	end, { desc = "dev: populate quickfix from output buffer" })

	vim.api.nvim_create_user_command(USER_CMDS.close, M.teardown, { desc = "dev: close dev environment" })

	local function load_config()
		local names = vim.tbl_keys(load_project_commands())
		table.sort(names)
		vim.notify("[dev] loaded commands: " .. table.concat(names, ", "), vim.log.levels.INFO)
	end

	vim.api.nvim_create_user_command(USER_CMDS.reload, load_config, { desc = "dev: reload project config" })

	load_config()
end

function M.teardown()
	if state.proc and not state.proc:is_closing() then
		state.proc:kill("sigterm")
		state.proc = nil
	end

	if state.output_win and vim.api.nvim_win_is_valid(state.output_win) then
		vim.api.nvim_win_close(state.output_win, true)
	end

	if state.output_buf and vim.api.nvim_buf_is_valid(state.output_buf) then
		vim.api.nvim_buf_delete(state.output_buf, { force = true })
	end

	state = default_state()

	for _, cmd in pairs(USER_CMDS) do
		pcall(vim.api.nvim_del_user_command, cmd)
	end

	vim.notify("[dev] environment closed", vim.log.levels.INFO)
end

return M
