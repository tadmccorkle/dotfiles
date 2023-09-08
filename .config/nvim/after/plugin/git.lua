local neogit_status, neogit = pcall(require, 'neogit')
local diffview_status, diffview = pcall(require, 'diffview')

local map = require('tad.map')

if neogit_status then
	neogit.setup({
		integrations = {
			diffview = diffview_status
		},
	})
end

if diffview_status then
	diffview.setup({
		use_icons = false,
		enhanced_diff_hl = true,
	})
	map('n', '<Leader>dv', '<Cmd>DiffviewOpen<CR>')
	map('n', '<Leader>DV', ':DiffviewOpen ')
end


local gitsigns_status, gitsigns = pcall(require, 'gitsigns')
if gitsigns_status then
	gitsigns.setup({
		current_line_blame = true,
		current_line_blame_opts = {
			virt_text = true,
			virt_text_pos = 'eol',
		},
	})
end
