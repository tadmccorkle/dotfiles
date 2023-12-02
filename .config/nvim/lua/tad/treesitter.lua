-- defer until after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
	require('nvim-treesitter.configs').setup({
		ensure_installed = {
			'bash',
			'c',
			'c_sharp',
			'cmake',
			'comment',
			'cpp',
			'css',
			'dockerfile',
			'gitattributes',
			'gitignore',
			'go',
			'html',
			'javascript',
			'json',
			'latex',
			'lua',
			'make',
			'markdown',
			'markdown_inline',
			'ocaml',
			'ocaml_interface',
			'python',
			'regex',
			'rst',
			'rust',
			'query',
			'scss',
			'sql',
			'svelte',
			'toml',
			'tsx',
			'typescript',
			'vim',
			'vimdoc',
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
		},

		-- treesitter query playground
		playground = {
			enable = true,
		},
	})
end, 0)
