-- nightfox theme
local nightfox = require('nightfox')

nightfox.setup({
	options = {
		transparent = true,
		styles = {
			comments = 'italic',
			functions = 'italic',
			keywords = 'italic,bold',
			variables = 'italic',
		}
	},
})

vim.cmd('colorscheme nightfox')


-- lualine
local lualine = require('lualine')

lualine.setup({
	options = {
		icons_enabled = false,
		component_separators = {},
		section_separators = {},
	}
})
