local map = require('tad.map')

map('n', 'x', '"_x') -- cut without yank in normal mode by default
map({ 'n', 'v' }, '<Leader>d', '"_d') -- delete without yank
map('v', '<Leader>p', '"_dP') -- paste in visual without losing register

-- increment/decrement
map('n', '+', '<C-a>')
map('n', '-', '<C-x>')

-- select all
map('n', '<C-a>', 'gg<S-v>G')

-- tabs
map('n', '<Leader>te', ':tabedit')
map('n', '<Leader>tc', ':tabclose')
map('n', '<Leader>tn', ':tabnext')
map('n', '<Leader>tp', ':tabprevious')
map('n', '<Leader>tf', ':tabfirst')
map('n', '<Leader>tl', ':tablast')

-- windows
map('n', '<Leader>wrh', '<C-w><')
map('n', '<Leader>wrj', '<C-w>-')
map('n', '<Leader>wrk', '<C-w>+')
map('n', '<Leader>wrl', '<C-w>>')
map('n', '<Leader>wr=', '<C-w>=')
map('n', '<Leader>wcl', '<C-w>c')

-- deletion
map('i', '<C-Del>', '<C-o><Leader>dw')
map('i', '<C-S-Del>', '<C-o><Leader>d$')
