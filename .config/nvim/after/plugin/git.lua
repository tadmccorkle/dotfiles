local status, git = pcall(require, 'git')
if not status then return end

git.setup({
	default_mappings = true,
	keymaps = {
		blame = "<Leader>Gb",
		browse = "<Leader>Go",
		open_pull_request = "<Leader>Gp",
		create_pull_request = "<Leader>Gn",
		diff = "<Leader>Gd",
		diff_close = "<Leader>GD",
		revert = "<Leader>Gr",
		revert_file = "<Leader>GR",
	},
	target_branch = 'master',
})
