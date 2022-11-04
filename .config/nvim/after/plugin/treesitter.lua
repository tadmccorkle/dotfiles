local status, ts = pcall(require, 'nvim-treesitter.configs')
if not status then return end

ts.setup({
	ensure_installed = {
		'bash',
		'c',
		'c_sharp',
		'comment',
		'cpp',
		'css',
		'gitattributes',
		'help',
		'html',
		'javascript',
		'json',
		'latex',
		'lua',
		'make',
		'python',
		'regex',
		'rst',
		'rust',
		'scss',
		'sql',
		'svelte',
		'toml',
		'tsx',
		'typescript',
		'vim',
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

	-- autotag plugin
	autotag = {
		enable = true,
	}
})
