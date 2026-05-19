vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.as",
	callback = function()
		vim.cmd(":set filetype=text")
		vim.cmd(":set syntax=javascript")
	end,
})
