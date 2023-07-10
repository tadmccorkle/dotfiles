vim.g.mapleader = ','

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.laststatus = 3
vim.opt_global.foldcolumn = '1'

vim.opt.listchars = {
	tab = '→ ',
	space = '·',
	nbsp = '+',
}
vim.opt.list = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 0
vim.opt.autoindent = true
vim.opt.smartindent = true

vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.showbreak = '↳  '

vim.opt.cdhome = true

vim.opt.wildignorecase = true
vim.opt.wildignore:append { '*/node_modules/*', '*/venv/*' }

vim.opt.inccommand = 'split'

-- reset terminal cursor when exiting vim
vim.api.nvim_create_autocmd('VimLeave', {
	pattern = '*',
	command = 'set guicursor=a:ver25-blinkon250-blinkoff250'
})

-- hide line numbers in terminal windows
vim.api.nvim_create_autocmd('TermOpen', {
	pattern = '*',
	command = 'setlocal nonumber norelativenumber'
})

-- human-readable printing
P = function(x)
	print(vim.inspect(x))
	return x
end
