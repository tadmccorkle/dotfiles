return {
	"williamboman/mason.nvim",
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"folke/neodev.nvim",
		},
	},
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			-- 'Hoffs/omnisharp-extended-lsp.nvim',
		},
	},
	"nvim-lua/plenary.nvim",
	{ "numToStr/Comment.nvim", config = true, lazy = false },
	{ "folke/zen-mode.nvim",   config = true },
}
