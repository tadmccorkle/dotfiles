local status, indent = pcall(require, 'indent_blankline')
if not status then return end

vim.cmd [[highlight IndentBlanklineChar guifg=#29394f gui=nocombine]]
vim.cmd [[highlight IndentBlanklineSpaceChar guifg=#29394f gui=nocombine]]
vim.cmd [[highlight IndentBlanklineSpaceCharBlankline guifg=#29394f gui=nocombine]]

indent.setup({
	space_char_blankline = ' ',
})
