return {
	{
		'nvim-treesitter/nvim-treesitter',
		lazy = false,
		dependencies = {
			'windwp/nvim-ts-autotag',
			'nvim-treesitter/playground',
		},
		build = function()
			require('nvim-treesitter.install').update({ with_sync = true })()
		end,
		config = function()
			if vim.fn.has('win32') == 1 and vim.fn.executable("clang") == 1 then
				-- fix issues with windows recognizing some compiled parsers
				require('nvim-treesitter.install').compilers = { "clang" }
			end

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
		end,
	},
}
