local neogit_status, neogit = pcall(require, 'neogit')
local diffview_status, diffview = pcall(require, 'diffview')

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
	})
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
