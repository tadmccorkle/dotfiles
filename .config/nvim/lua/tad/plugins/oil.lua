return {
	{
		'stevearc/oil.nvim',
		opts = {
			skip_confirm_for_simple_edits = true,
			view_options = {
				show_hidden = true,
			},
		},
		init = function()
			vim.keymap.set('n', '<Leader>o', '<Cmd>Oil --float<CR>')
		end,
	},
}
