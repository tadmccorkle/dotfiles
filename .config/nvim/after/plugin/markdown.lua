local md_status, md = pcall(require, 'markdown')
if not md_status then return end

md.setup({
	on_attach = function(bufnr)
		vim.keymap.set({ 'n', 'i' }, '<M-l><M-o>', '<Cmd>MDListItemBelow<CR>', { buffer = bufnr })
		vim.keymap.set({ 'n', 'i' }, '<M-L><M-O>', '<Cmd>MDListItemAbove<CR>', { buffer = bufnr })
		vim.keymap.set('n', '<M-l><M-c>', '<Cmd>MDTaskToggle<CR>', { buffer = bufnr })
		vim.keymap.set('x', '<M-l><M-c>', ':MDTaskToggle<CR>', { buffer = bufnr })
	end
})
