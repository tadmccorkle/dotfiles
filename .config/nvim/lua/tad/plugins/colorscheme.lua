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
						["@markup.italic"] = { fg = "palette.red", style = "italic" },
						["@markup.strikethrough"] = { fg = "fg3", style = "strikethrough" },
					}
				}
			})
			vim.cmd([[colorscheme nightfox]])
		end,
	},
}
