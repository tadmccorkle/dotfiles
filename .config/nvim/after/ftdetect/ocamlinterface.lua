vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
	pattern = '*.mli',
	callback = function()
		vim.cmd(':set filetype=ocamlinterface')
	end,
})
