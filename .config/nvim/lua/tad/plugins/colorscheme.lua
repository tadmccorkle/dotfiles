return {
	{
		'EdenEast/nightfox.nvim',
		lazy = false,
		priority = 1000,
		config = function()
			require('nightfox').setup({
				options = {
					transparent = true,
					dim_inactive = true,
					styles = {
						comments = 'italic',
						keywords = 'bold',
					}
				},
				palettes = {
					nightfox = {
						bg0 = "#080808",
					}
				},
				groups = {
					nightfox = {
						WinSeparator = { fg = "fg3" },
					}
				}
			})
			vim.cmd([[colorscheme nightfox]])
		end,
	},
}
