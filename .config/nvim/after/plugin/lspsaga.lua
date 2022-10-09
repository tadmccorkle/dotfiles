local status, saga = pcall(require, 'lspsaga')
if not status then return end

saga.init_lsp_saga({
	-- transparency: 0 (opaque) - 100 (transparent)
	saga_winblend = 0,
	move_in_saga = {
		prev = '<C-p>',
		next = '<C-n>'
	},
	-- error, warn, info, hint
	diagnostic_header = {
		'❌',
		'⚠️',
		'ℹ️',
		'🔎'
	},
	code_action_icon = '💡',
	code_action_num_shortcut = true,
	finder_icons = {
		def = '📖',
		ref = '📑',
		link = '🔗',
	},
	finder_action_keys = {
		open = 'o',
		vsplit = 's',
		split = 'i',
		tabe = 't',
		quit = 'q',
	},
	code_action_keys = {
		quit = 'q',
		exec = '<CR>',
	},
	definition_action_keys = {
		quit = 'q',
	},
	rename_action_quit = '<C-e>',
	rename_in_select = true,
})
