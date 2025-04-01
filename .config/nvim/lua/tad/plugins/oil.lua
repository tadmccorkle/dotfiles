return {
	{
		'stevearc/oil.nvim',
		opts = {
			view_options = {
				show_hidden = true,
			},
		},
		init = function()
			vim.keymap.set('n', '<Leader>o', '<Cmd>Oil<CR>')
		end,
	},
}
