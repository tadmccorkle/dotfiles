local status, null_ls = pcall(require, 'null-ls')
if not status then return end

---@diagnostic disable-next-line: redundant-parameter - disabling because this shouldn't be flagged
null_ls.setup({
	---@diagnostic disable-next-line: unused-local
	on_attach = function(client, bufnr)
		if client.server_capabilities.documentFormattingProvider then
			vim.cmd('nnoremap <silent><buffer> <Leader>f :lua vim.lsp.buf.format({ async = true })<CR>')

			-- format on save
			vim.cmd('autocmd BufWritePost <buffer> lua vim.lsp.buf.format({ async = true })')
		end

		if client.server_capabilities.documentRangeFormattingProvider then
			vim.cmd('xnoremap <silent><buffer> <Leader>f :lua vim.lsp.buf.range_formatting({})<CR>')
		end
	end,
})
