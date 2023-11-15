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
		end
	},
}
