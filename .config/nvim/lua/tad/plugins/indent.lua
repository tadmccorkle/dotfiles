return {
	{
		'lukas-reineke/indent-blankline.nvim',
		main = 'ibl',
		config = function()
			vim.cmd [[highlight IblIndent guifg=#29394f gui=nocombine]]
			require('ibl').setup({
				indent = {
					tab_char = "▎",
				},
				scope = {
					enabled = false,
					show_start = false,
					show_end = false,
				},
			})
		end,
	},
}
