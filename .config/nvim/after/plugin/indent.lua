local status, ibl = pcall(require, 'ibl')
if not status then return end

vim.cmd [[highlight IblIndent guifg=#29394f gui=nocombine]]
vim.cmd [[highlight IblScope guifg=#a6b8d1f gui=nocombine]]

ibl.setup({
	indent = {
		tab_char = "▎",
	},
	scope = {
		show_start = false,
		show_end = false,
	}
})
