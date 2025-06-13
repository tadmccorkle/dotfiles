vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.showmode = false
vim.opt.laststatus = 3
vim.opt.foldcolumn = '1'
vim.opt.splitright = true
vim.opt.splitbelow = false
vim.opt.inccommand = 'split'
vim.opt.hlsearch = true

vim.opt.list = true
vim.opt.listchars = {
	tab = '→ ',
	space = '·',
	nbsp = '+',
}

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

vim.opt.wrap = true
vim.opt.diffopt:append({ 'followwrap' })
vim.opt.breakindent = true
vim.opt.showbreak = '↳  '

vim.opt.shortmess:append({ I = true })

vim.opt.cdhome = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wildignorecase = true
vim.opt.wildignore:append({ '*/node_modules/*', '*/venv/*' })

vim.opt.completeopt = 'menu,menuone,noselect'

vim.opt.formatoptions:append('l')

vim.g.netrw_banner = 0

local map = vim.keymap.set

map({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

map('n', '<Esc>', '<Cmd>nohlsearch<CR>')

map({ 'n', 'v' }, 'x', '"_x')         -- 'x' without yank by default
map({ 'n', 'v' }, 'X', '"_X')         -- 'X' without yank by default
map({ 'n', 'v' }, '<Leader>x', '""x') -- 'x' with yank
map({ 'n', 'v' }, '<Leader>X', '""X') -- 'x' with yank
map({ 'n', 'v' }, '<Leader>d', '"_d') -- 'd' without yank
map({ 'n', 'v' }, '<Leader>D', '"_D') -- 'D' without yank
map({ 'n', 'v' }, '<Leader>c', '"_c') -- 'c' without yank
map({ 'n', 'v' }, '<Leader>C', '"_C') -- 'C' without yank
map('v', '<Leader>p', '"_dP')         -- paste in visual mode without losing register
map({ 'n', 'v' }, '<leader>y', '"+y') -- yank to clipboard
map('n', '<leader>Y', '"+Y')          -- yank line to clipboard

-- place cursor in center row when jumping vertically
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')

-- windows
map('n', '<A-,>', '<C-w><')  -- narrower
map('n', '<A-.>', '<C-w>>')  -- wider
map('n', '<A-<>', '<C-w>5<') -- much narrower
map('n', '<A->>', '<C-w>5>') -- much wider
map('n', '<A-t>', '<C-w>+')  -- taller
map('n', '<A-s>', '<C-w>-')  -- shorter
map('n', '<A-T>', '<C-w>5+') -- much taller
map('n', '<A-S>', '<C-w>5-') -- much shorter
map('n', '<A-=>', '<C-w>=')  -- distribute evenly

-- diagnostics
local opts = { silent = true }
map('n', '<Leader>]D', function()
	vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, opts)
map('n', '<Leader>[D', function()
	vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end, opts)
map('n', '<Leader>do', vim.diagnostic.open_float, opts)
map('n', '<Leader>dl', vim.diagnostic.setloclist, opts)

-- source and execute
map('n', '<Leader><Leader>s', '<Cmd>source %<CR>', { silent = true })
map('n', '<Leader><Leader>x', '<Cmd>.lua<CR>', { silent = true })
map('v', '<Leader><Leader>x', ':lua<CR>', { silent = true })

-- set filetype
map('n', '<Leader><Leader>ft', '<Cmd>set filetype=', { silent = true })
map('n', '<Leader><Leader>ftgc', '<Cmd>set filetype=gitcommit<CR>', { silent = true })

-- remove auto-comment format filetype option
vim.api.nvim_create_autocmd('VimEnter', {
	pattern = '*',
	command = 'setlocal formatoptions-=o'
})

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

-- highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
	pattern = '*',
})

-- human-readable printing
P = function(x)
	print(vim.inspect(x))
	return x
end

-- force reload
R = function(x)
	package.loaded[x] = nil
	return require(x)
end

if vim.fn.has('win32') == 1 then
	require('tad.windows')
end
require('tad.fileformat')
