local status, lualine = pcall(require, 'lualine')
if not status then return end

lualine.setup({
	options = {
		icons_enabled = false,
		component_separators = {},
		section_separators = {},
	}
})
