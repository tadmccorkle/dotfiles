require('tad.base')
require('tad.keymaps')
require('tad.plugins')

if vim.fn.has('win32') then
	require('tad.windows')
end
