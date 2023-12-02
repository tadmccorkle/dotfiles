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

vim.opt.shortmess:append({ I = true })

vim.opt.cdhome = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wildignorecase = true
vim.opt.wildignore:append { '*/node_modules/*', '*/venv/*' }

vim.opt.inccommand = 'split'

vim.opt.completeopt = 'menu,menuone,noselect'

local map = vim.keymap.set

map({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
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

-- diff view
map('n', '<Leader>dv', '<Cmd>DiffviewOpen<CR>')
map('n', '<Leader>DV', ':DiffviewOpen ')

-- zen mode
map('n', '<Leader>zm', '<Cmd>ZenMode<CR>')

-- telescope
map('n', '<Leader>ff', '<Cmd>Telescope find_files<CR>')
map('n', '<Leader>fg', '<Cmd>Telescope git_files<CR>')
map('n', '<Leader>fb', '<Cmd>Telescope buffers<CR>')
map('n', '<Leader>lg', '<Cmd>Telescope live_grep<CR>')
map('n', '<Leader>gs', '<Cmd>Telescope grep_string<CR>')
map('n', '<Leader>fh', '<Cmd>Telescope help_tags<CR>')
map('n', '<Leader>fm', '<Cmd>Telescope keymaps<CR>')
map('n', '<Leader>fd', '<Cmd>Telescope diagnostics<CR>')
map('n', '<Leader>fr', '<Cmd>Telescope resume<CR>')
map('n', '<Leader>FF', function()
	require('telescope.builtin').find_files({
		find_command = {
			'rg', '--files', '--hidden',
			'--glob', '!**/.git/*',
		}
	})
end)
map('n', '<Leader>LG', function()
	require('telescope.builtin').live_grep({
		additional_args = { '--hidden' },
		glob_pattern = { '!**/.git/*' },
	})
end)

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
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
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
require('tad.cmp')
require('tad.lsp')
require('tad.treesitter')
require('tad.fileformat')
