return {
	{
		'lukas-reineke/indent-blankline.nvim',
		main = 'ibl',
		config = function()
			vim.cmd [[highlight IblIndent guifg=#29394f gui=nocombine]]
			vim.cmd [[highlight IblScope guifg=#a6b8d1f gui=nocombine]]
			require('ibl').setup({
				indent = {
					tab_char = "▎",
				},
				scope = {
					show_start = false,
					show_end = false,
				},
			})
		end,
	},
}
