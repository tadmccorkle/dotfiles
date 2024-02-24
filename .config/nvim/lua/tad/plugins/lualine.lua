return {
	{
		'nvim-lualine/lualine.nvim',
		opts = {
			options = {
				icons_enabled = false,
				component_separators = {},
				section_separators = {},
			},
			sections = {
				lualine_c = {
					{
						'filename',
						path = 1,
					}
				}
			},
		},
	},
}
