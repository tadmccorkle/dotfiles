return {
	{
		'nvim-treesitter/nvim-treesitter',
		dependencies = {
			'windwp/nvim-ts-autotag',
			'nvim-treesitter/playground',
		},
		build = function()
			require('nvim-treesitter.install').update({ with_sync = true })()
		end,
	},
}
