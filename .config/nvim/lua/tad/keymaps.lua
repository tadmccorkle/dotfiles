local map = require('tad.map')

map('n', 'x', '"_x')                  -- without yank in normal mode by default
map('n', '<Leader>x', '""x')          -- with yank in normal mode
map('v', '<Leader>x', '"_x')          -- without yank in visual mode
map({ 'n', 'v' }, '<Leader>d', '"_d') -- without yank
map({ 'n', 'v' }, '<Leader>c', '"_c') -- without yank
map('v', '<Leader>p', '"_dP')         -- paste in visual mode without losing register
map({ 'n', 'v' }, '<leader>y', '"+y') -- yank to clipboard
map('n', '<leader>Y', '"+Y')          -- yank line to clipboard

-- place cursor in center row when jumping vertically
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')

-- increment/decrement
map({ 'n', 'v' }, '+', '<C-a>')
map({ 'n', 'v' }, '-', '<C-x>')
map('v', 'g+', 'g<C-a>')
map('v', 'g-', 'g<C-x>')

-- select all
map('n', '<C-a>', 'gg<S-v>G')

-- windows
map('n', '<A-,>', '<C-w><')
map('n', '<A-.>', '<C-w>>')
map('n', '<A-<>', '<C-w>5<')
map('n', '<A->>', '<C-w>5>')
map('n', '<A-=>', '<C-w>=')
map('n', '<A-t>', '<C-w>+')
map('n', '<A-s>', '<C-w>-')

-- save and source
map('n', '<Leader><Leader>s', '<Cmd>w | source %<CR>', { silent = true })
