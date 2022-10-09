-- nightfox theme
local theme_status, nightfox = pcall(require, 'nightfox')

if theme_status then
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
end


-- lualine
local lualine_status, lualine = pcall(require, 'lualine')

if lualine_status then
	lualine.setup({
		options = {
			icons_enabled = false,
			component_separators = {},
			section_separators = {},
		}
	})
end
