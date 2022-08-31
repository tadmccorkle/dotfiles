vim.opt.number = true
vim.opt.colorcolumn = '100'

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 0
vim.opt.autoindent = true
vim.opt.smartindent = true

vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.showbreak = '  '

vim.opt.cdhome = true

vim.opt.formatoptions:append { 'r' }

vim.opt.wildignorecase = true
vim.opt.wildignore:append { '*/node_modules/*', '*/venv/*' }

-- reset terminal cursor when exiting vim
vim.api.nvim_create_autocmd('VimLeave', {
  pattern = '*',
  command = 'set guicursor=a:ver25-blinkon250-blinkoff250'
})
