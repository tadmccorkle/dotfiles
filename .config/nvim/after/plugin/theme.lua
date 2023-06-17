local status, nightfox = pcall(require, 'nightfox')
if not status then return end

nightfox.setup({
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

vim.cmd('colorscheme nightfox')
