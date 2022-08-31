local status, n = pcall(require, 'nightfox')
if (not status) then return end

n.setup({
	options = {
		transparent = true,
		styles = {
			comments = 'italic',
			functions = 'italic',
			keywords = 'italic,bold',
			variables = 'italic',
		}
	}
})

vim.cmd('colorscheme carbonfox')
