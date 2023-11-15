return {
	{
		'NeogitOrg/neogit',
		dependencies = {
			'nvim-lua/plenary.nvim',
			{
				'sindrets/diffview.nvim',
				opts = {
					use_icons = false,
					enhanced_diff_hl = true,
				},
			},
		},
		opts = {
			integrations = {
				diffview = true
			},
		},
	},
	{
		'lewis6991/gitsigns.nvim',
		opts = {
			current_line_blame = true,
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = 'eol',
			},
		},
	},
}
