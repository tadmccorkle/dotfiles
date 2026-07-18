vim.api.nvim_create_user_command("Dev", function()
	require("tad.dev.env").setup()
end, { desc = "dev: open dev environment" })

vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
	callback = function()
		local config_path = vim.fn.getcwd() .. "/.nvim-dev.lua"
		local stat = vim.uv.fs_stat(config_path)
		if stat and stat.type == "file" then
			require("tad.dev.env").setup()
		end
	end,
	desc = "dev: setup dev environment when .nvim-dev.lua file is detected",
})
