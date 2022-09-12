local telescope = require('telescope')
local actions = require('telescope.actions')

telescope.setup({
	defaults = {
		mappings = {
			n = {
				['<C-e>'] = actions.close,
			}
		}
	}
})

local map = require('tad.map')
map('n', '<Leader>ff', '<cmd>Telescope find_files<CR>')
map('n', '<Leader>fg', '<cmd>Telescope git_files<CR>')
map('n', '<Leader>fb', '<cmd>Telescope buffers<CR>')
map('n', '<Leader>fh', '<cmd>Telescope help_tags<CR>')
