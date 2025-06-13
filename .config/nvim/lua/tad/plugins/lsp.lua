return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"folke/neodev.nvim",
			"stevearc/conform.nvim",
		},
		config = function()
			require('tad.lsp')
		end
	},
}
