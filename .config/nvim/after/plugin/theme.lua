local status, nightfox = pcall(require, 'nightfox')
if not status then return end

nightfox.setup({
	options = {
		transparent = true,
		styles = {
			comments = 'italic',
			functions = 'italic',
			keywords = 'italic,bold',
			variables = 'italic',
		}
	},
})

vim.cmd('colorscheme nightfox')
