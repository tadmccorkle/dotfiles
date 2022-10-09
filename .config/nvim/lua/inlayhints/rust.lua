-- logic initially copied from https://github.com/lvimuser/lsp-inlayhints.nvim
-- minor formatting changes and other modifications applied
local M = {}

local opts = {
	parameter_hints = {
		show = false,
		prefix = ' : ',
		separator = ', ',
	},
	type_hints = {
		show = true,
		prefix = ' » ',
		separator = ', ',
	},
	only_current_line = false,
	labels_separator = '',
	highlight = 'Comment',
}

local store = {
	active_clients = {},
	b = setmetatable({}, {
		__index = function(t, bufnr)
			t[bufnr] = {}
			return rawget(t, bufnr)
		end,
	}),
}

local ns = vim.api.nvim_create_namespace('textDocument/inlayHints')
local AUGROUP = 'rust_inlayhints'

local function get_type_vt(labels)
	if not (opts.type_hints.show and next(labels)) then
		return ''
	end

	local pattern = opts.type_hints.separator .. '%s?$'
	local t = {}
	for i, label in ipairs(labels) do
		-- remove any surrounding colons
		label = label:match '^:?%s?(.*)$' or label
		label = label:match '(.*):$' or label
		t[i] = label:gsub(pattern, '')
	end

	return (opts.type_hints.prefix or '') .. table.concat(t, opts.type_hints.separator)
end

local function get_param_vt(labels)
	if not (opts.parameter_hints.show and next(labels)) then
		return ''
	end

	local t = {}
	for i, label in ipairs(labels) do
		-- remove any surrounding colons
		label = label:match '^:?%s?(.*)$' or label
		label = label:match '(.*):%s?$' or label
		t[i] = label
	end

	return (opts.parameter_hints.prefix or '')
			.. '('
			.. table.concat(t, opts.parameter_hints.separator)
			.. ') '
end

local function get_labels(line_hints)
	local param_labels = {}
	local type_labels = {}

	for _, hint in ipairs(line_hints) do
		local tbl = hint.kind == 2 and param_labels or type_labels

		-- label may be a string or InlayHintLabelPart[]
		-- https://microsoft.github.io/language-server-protocol/specifications/lsp/4.17/specification/#inlayHintLabelPart
		if type(hint.label) == 'table' then
			for _, label_part in ipairs(hint.label) do
				table.insert(tbl, label_part.value)
			end
		else
			table.insert(tbl, hint.label)
		end
	end

	return param_labels, type_labels
end

local function render_hints(bufnr, parsed, namespace)
	for line, line_hints in pairs(parsed) do
		local param_labels, type_labels = get_labels(line_hints)

		local param_vt = get_param_vt(param_labels)
		local type_vt = get_type_vt(type_labels)

		local virt_text
		if type_vt ~= '' then
			if param_vt ~= '' then
				virt_text = type_vt .. opts.labels_separator .. param_vt
			else
				virt_text = type_vt
			end
		else
			virt_text = param_vt
		end

		if virt_text ~= '' then
			vim.api.nvim_buf_set_extmark(bufnr, namespace, line, 0, {
				virt_text = { { virt_text, opts.highlight } },
				hl_mode = 'combine',
			})
		end
	end
end

local function get_visible_lines()
	return { first = vim.fn.line 'w0', last = vim.fn.line 'w$' }
end

local function col_of_row(row, offset_encoding)
	row = row - 1

	local line = vim.api.nvim_buf_get_lines(0, row, row + 1, true)[1]
	if not line or #line == 0 then
		return 0
	end

	return vim.lsp.util._str_utfindex_enc(line, nil, offset_encoding)
end

local function get_hint_ranges(offset_encoding)
	local line_count = vim.api.nvim_buf_line_count(1) -- 1-based index

	if line_count <= 200 then
		local col = col_of_row(line_count, offset_encoding)
		return {
			start = { 1, 0 },
			['end'] = { line_count, col },
		}
	end

	local extra = 30
	local visible = get_visible_lines()

	local start_line = math.max(1, visible.first - extra)
	local end_line = math.min(line_count, visible.last + extra)
	local end_col = col_of_row(end_line, offset_encoding)

	return {
		start = { start_line, 0 },
		['end'] = { end_line, end_col },
	}
end

local function get_params(range, bufnr)
	return {
		textDocument = vim.lsp.util.make_text_document_params(bufnr),
		range = {
			-- convert to 1-based index
			start = { line = range.start[1] - 1, character = range.start[2] },
			['end'] = { line = range['end'][1] - 1, character = range['end'][2] },
		},
	}
end

local function parseHints(result)
	if type(result) ~= 'table' then
		return {}
	end

	local map = {}
	for _, inlayHint in pairs(result) do
		local line = tonumber(inlayHint.position.line)
		if not map[line] then
			---@diagnostic disable-next-line: need-check-nil
			map[line] = {}
		end

		table.insert(map[line], {
			label = inlayHint.label,
			kind = inlayHint.kind or 1,
			position = inlayHint.position,
		})

		table.sort(map[line], function(a, b)
			return a.position.character < b.position.character
		end)
	end

	return map
end

local function clear(bufnr, line_start, line_end)
	if bufnr == nil or bufnr == 0 then
		bufnr = vim.api.nvim_get_current_buf()
	end

	vim.api.nvim_buf_clear_namespace(bufnr, ns, line_start or 0, line_end or -1)
end

local function handler(range)
	return function(_, result, ctx)
		local bufnr = ctx.bufnr
		if vim.api.nvim_get_current_buf() ~= bufnr then
			return
		end

		-- range given is 2-based index, but clear is 0-based index (end is exclusive)
		clear(bufnr, range.start[1] - 1, range['end'][1])

		local parsed = parseHints(result)

		if opts.only_current_line then
			local cursor = vim.api.nvim_win_get_cursor(0)
			local line = cursor[1] - 1
			parsed = { [line] = parsed[line] }
		end

		render_hints(bufnr, parsed, ns)
	end
end

local function show(bufnr)
	if bufnr == nil or bufnr == 0 then
		bufnr = vim.api.nvim_get_current_buf()
	end

	if not store.b[bufnr].client then
		return
	end

	local client = vim.lsp.get_client_by_id(store.b[bufnr].client.id)
	if not client then
		return
	end

	local range = get_hint_ranges(client.offset_encoding)
	local params = get_params(range, bufnr)
	if not params then
		return
	end

	client.request('textDocument/inlayHint', params, handler(range), bufnr)
end

function M.on_attach(client, bufnr)
	if not store.b[bufnr].attached then
		vim.api.nvim_buf_attach(bufnr, false, {
			on_detach = function()
				vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
			end,
			on_lines = function(_, _, _, first_lnum, last_lnum)
				vim.api.nvim_buf_clear_namespace(bufnr, ns, first_lnum, last_lnum)
			end,
		})
	end

	store.b[bufnr].client = { name = client.name, id = client.id }
	store.b[bufnr].attached = true

	if not store.active_clients[client.name] then
		show(bufnr)
	end
	store.active_clients[client.name] = true

	-- WinScrolled covers |scroll-cursor|
	local events = {
		'BufEnter',
		--'BufWinEnter',
		--'TabEnter',
		'BufWritePost',
		--'BufReadPost',
		'CursorHold',
		'InsertLeave',
		'WinScrolled'
	}

	local aucmd = vim.api.nvim_create_autocmd(events, {
		group = vim.api.nvim_create_augroup(AUGROUP, { clear = false }),
		buffer = bufnr,
		callback = function()
			show()
		end,
	})
	store.b[bufnr].aucmd = aucmd

	vim.api.nvim_create_autocmd('LspDetach', {
		group = vim.api.nvim_create_augroup(AUGROUP .. 'Detach', { clear = false }),
		buffer = bufnr,
		once = true,
		callback = function(args)
			if not store.b[bufnr] or args.data.client_id ~= store.b[bufnr].client_id then
				return
			end

			pcall(vim.api.nvim_del_autocmd, aucmd)
			rawset(store.b, bufnr, nil)
		end,
	})
end

return M
