local indent = require('indent_blankline')

vim.cmd [[highlight IndentBlanklineChar guifg=#29394f gui=nocombine]]
vim.cmd [[highlight IndentBlanklineSpaceChar guifg=#29394f gui=nocombine]]
vim.cmd [[highlight IndentBlanklineSpaceCharBlankline guifg=#29394f gui=nocombine]]

indent.setup({
	space_char_blankline = ' ',
})
