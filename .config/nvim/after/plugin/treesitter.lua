local ts = require('nvim-treesitter.configs')

ts.setup({
	ensure_installed = {
		'c_sharp',
		'css',
		'html',
		'javascript',
		'json',
		'latex',
		'lua',
		'make',
		'python',
		'rust',
		'scss',
		'svelte',
		'tsx',
		'typescript',
		'yaml',
	},
	sync_install = false,
	auto_install = false,
	ignore_install = {},
	highlight = {
		enable = true,
		disable = {},
		additional_vim_regex_highlighting = false,
	},
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = '<C-n>i',
			node_incremental = '<C-n>n',
			scope_incremental = '<C-n>s',
			node_decremental = '<C-n>m',
		},
	},

	-- autotag plugin
	autotag = {
		enable = true,
	}
})
