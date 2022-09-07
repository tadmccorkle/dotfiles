local map = require('tad.map')

-- cut without yank
map('n', 'x', '"_x')

-- increment/decrement
map('n', '+', '<C-a>')
map('n', '-', '<C-x>')

-- select all
map('n', '<C-a>', 'gg<S-v>G')

-- tabs
map('n', 'te', ':tabedit')
map('n', 'tc', ':tabclose')
map('n', 'tn', ':tabnext')
map('n', 'tp', ':tabprevious')
map('n', 'tf', ':tabfirst')
map('n', 'tl', ':tablast')

-- deletion
map('i', '<C-Del>', '<C-o>dw')
map('i', '<C-S-Del>', '<C-o>d$')

-- TODO - window resizing
