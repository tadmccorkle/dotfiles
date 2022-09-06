local keymap = vim.keymap

-- increment/decrement
keymap.set('n', '+', '<C-a>')
keymap.set('n', '-', '<C-x>')

-- select all
keymap.set('n', '<C-a>', 'gg<S-v>G')

-- tabs
keymap.set('n', 'te', ':tabedit')
keymap.set('n', 'tc', ':tabclose')
keymap.set('n', 'tn', ':tabnext')
keymap.set('n', 'tp', ':tabprevious')
keymap.set('n', 'tf', ':tabfirst')
keymap.set('n', 'tl', ':tablast')

-- deletion
keymap.set('i', '<C-Del>', '<C-o>dw')
keymap.set('i', '<C-S-Del>', '<C-o>d$')
