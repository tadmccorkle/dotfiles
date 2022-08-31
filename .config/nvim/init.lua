require('tad.base')
require('tad.plugins')

if vim.fn.has('win32') then
	require('tad.windows')
end
