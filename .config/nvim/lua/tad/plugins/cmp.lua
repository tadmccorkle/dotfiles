return {
	{
		'hrsh7th/nvim-cmp',
		event = 'InsertEnter',
		dependencies = {
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-buffer',
			{
				'L3MON4D3/LuaSnip',
				opts = {
					update_events = 'TextChanged,TextChangedI',
					region_check_events = 'CursorMoved,InsertEnter',
				},
			},
			'saadparwaiz1/cmp_luasnip',
			-- 'Hoffs/omnisharp-extended-lsp.nvim',
		},
		config = function()
			require('tad.cmp')
		end
	},
}
