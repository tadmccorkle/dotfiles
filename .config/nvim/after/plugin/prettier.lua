local status, prettier = pcall(require, 'prettier')
if not status then return end

prettier.setup({
	bin = 'prettierd',
	filetypes = {
		'css',
		'graphql',
		'html',
		'javascript',
		'javascriptreact',
		'json',
		'less',
		'markdown',
		'scss',
		'typescript',
		'typescriptreact',
		'yaml',
	},
	cli_options = {
		use_tabs = true,
		single_quote = false,
		trailing_comma = 'es5',
		print_width = 100,
		semi = true,
		end_of_line = 'auto',
	},
})
