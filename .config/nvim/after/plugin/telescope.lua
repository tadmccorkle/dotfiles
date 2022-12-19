local status, telescope = pcall(require, 'telescope')
if not (status) then return end

telescope.setup()

telescope.load_extension('fzf')

local map = require('tad.map')
map('n', '<Leader>ff', '<Cmd>Telescope find_files<CR>')
map('n', '<Leader>fg', '<Cmd>Telescope git_files<CR>')
map('n', '<Leader>fb', '<Cmd>Telescope buffers<CR>')
map('n', '<Leader>lg', '<Cmd>Telescope live_grep<CR>')
map('n', '<Leader>gs', '<Cmd>Telescope grep_string<CR>')
map('n', '<Leader>fh', '<Cmd>Telescope help_tags<CR>')
map('n', '<Leader>fm', '<Cmd>Telescope keymaps<CR>')
