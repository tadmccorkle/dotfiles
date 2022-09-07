local git = require('git')

git.setup({
	default_mappings = true,
	target_branch = 'master',
})


local gitsigns = require('gitsigns')

gitsigns.setup({
	current_line_blame = true,
	current_line_blame_opts = {
		virt_text = true,
		virt_text_pos = 'eol',
	}
})
