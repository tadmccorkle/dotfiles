return {
	{
		'neovim/nvim-lspconfig',
		dependencies = {
			{ 'folke/lazydev.nvim', ft = 'lua' },
			'williamboman/mason.nvim',
			'williamboman/mason-lspconfig.nvim',
			'WhoIsSethDaniel/mason-tool-installer.nvim',
			'mfussenegger/nvim-lint',
			'stevearc/conform.nvim',
			'b0o/SchemaStore.nvim',
		},
		config = function()
			require('tad.extools')
		end
	},
}
