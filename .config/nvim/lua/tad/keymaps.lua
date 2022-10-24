local map = require('tad.map')

map('n', 'x', '"_x') -- without yank in normal mode by default
map('v', '<Leader>x', '"_x') -- without yank in visual mode
map({ 'n', 'v' }, '<Leader>d', '"_d') -- without yank
map({ 'n', 'v' }, '<Leader>c', '"_c') -- without yank
map('v', '<Leader>p', '"_dP') -- paste in visual mode without losing register

-- increment/decrement
map('n', '+', '<C-a>')
map('n', '-', '<C-x>')

-- select all
map('n', '<C-a>', 'gg<S-v>G')

-- tabs
map('n', '<Leader>te', '<Cmd>tabedit<CR>')
map('n', '<Leader>tc', '<Cmd>tabclose<CR>')
map('n', '<Leader>tn', '<Cmd>tabnext<CR>')
map('n', '<Leader>tp', '<Cmd>tabprevious<CR>')
map('n', '<Leader>tf', '<Cmd>tabfirst<CR>')
map('n', '<Leader>tl', '<Cmd>tablast<CR>')

-- windows
map('n', '<A-,>', '<C-w><')
map('n', '<A-.>', '<C-w>>')
map('n', '<A-<>', '<C-w>5<')
map('n', '<A->>', '<C-w>5>')
map('n', '<A-=>', '<C-w>=')
map('n', '<A-t>', '<C-w>+')
map('n', '<A-s>', '<C-w>-')

-- deletion
map('i', '<C-Del>', '<C-o><Leader>dw')
map('i', '<C-S-Del>', '<C-o><Leader>d$')
