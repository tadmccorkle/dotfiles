vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.h",
	callback = function()
		vim.cmd(":set filetype=c")
	end,
})
