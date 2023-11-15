return {
	'tadmccorkle/markdown.nvim',
	event = 'VeryLazy',
	opts = {
		on_attach = function(bufnr)
			local map = vim.keymap.set
			local opts = { buffer = bufnr }
			map({ 'n', 'i' }, '<M-l><M-o>', '<Cmd>MDListItemBelow<CR>', opts)
			map({ 'n', 'i' }, '<M-L><M-O>', '<Cmd>MDListItemAbove<CR>', opts)
			map('n', '<M-c>', '<Cmd>MDTaskToggle<CR>', opts)
			map('x', '<M-c>', ':MDTaskToggle<CR>', opts)

			local function toggle(key)
				return "<Esc>gv<Cmd>lua require'markdown.inline'"
						.. ".toggle_emphasis_visual'" .. key .. "'<CR>"
			end
			map('x', '<C-b>', toggle('b'), opts)
			map('x', '<C-i>', toggle('i'), opts)
		end
	},
	dev = true,
}
