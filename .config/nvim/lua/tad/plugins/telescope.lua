return {
	{
		'nvim-telescope/telescope.nvim',
		branch = '0.1.x',
		dependencies = {
			'nvim-lua/plenary.nvim',
			{
				'nvim-telescope/telescope-fzf-native.nvim',
				build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release '
						.. '&& cmake --build build --config Release'
						.. '&& cmake --install build --prefix build',
				cond = function()
					return vim.fn.executable 'cmake' == 1
				end,
			},
		},
		config = function()
			local telescope = require('telescope')
			telescope.setup()

			pcall(telescope.load_extension, 'fzf')

			local builtin = require('telescope.builtin')
			local map = vim.keymap.set

			map('n', '<Leader>ff', builtin.find_files)
			map('n', '<Leader>ft', builtin.git_files)
			map('n', '<Leader>fb', builtin.buffers)
			map('n', '<leader>f.', builtin.oldfiles)
			map('n', '<Leader>fg', builtin.live_grep)
			map('n', '<Leader>fw', builtin.grep_string)
			map('n', '<Leader>fh', builtin.help_tags)
			map('n', '<Leader>fm', builtin.keymaps)
			map('n', '<Leader>fd', builtin.diagnostics)
			map('n', '<Leader>fr', builtin.resume)
			map('n', '<leader>/', function()
				local dropdown = require('telescope.themes').get_dropdown({
					winblend = 10,
					previewer = false,
				})
				builtin.current_buffer_fuzzy_find(dropdown)
			end)
			map('n', '<Leader>fo', function()
				builtin.live_grep({
					grep_open_files = true,
					additional_args = { '--hidden' },
					glob_pattern = { '!**/.git/*' },
				})
			end)
			map('n', '<leader>fc', function()
				builtin.find_files { cwd = vim.fn.stdpath 'config' }
			end)
			map('n', '<Leader>FF', function()
				builtin.find_files({
					find_command = {
						'rg', '--files', '--hidden',
						'--glob', '!**/.git/*',
					}
				})
			end)
			map('n', '<Leader>FG', function()
				builtin.live_grep({
					additional_args = { '--hidden' },
					glob_pattern = { '!**/.git/*' },
				})
			end)
		end
	},
}
