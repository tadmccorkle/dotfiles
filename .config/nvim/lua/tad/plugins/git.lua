return {
	{
		'NeogitOrg/neogit',
		dependencies = {
			'nvim-lua/plenary.nvim',
			{
				'sindrets/diffview.nvim',
				config = function()
					require('diffview').setup({
						use_icons = false,
						enhanced_diff_hl = true,
					})
					vim.keymap.set('n', '<Leader>dv', '<Cmd>DiffviewOpen<CR>')
				end
			},
		},
		opts = {
			integrations = {
				diffview = true
			},
		},
	},
	{
		'lewis6991/gitsigns.nvim',
		opts = {
			current_line_blame = true,
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = 'eol',
			},
			on_attach = function(bufnr)
				local gs = require('gitsigns')

				local function map(m, l, r)
					vim.keymap.set(m, l, r, { buffer = bufnr })
				end

				map('n', ']h', function()
					if vim.wo.diff then
						vim.cmd.normal({ ']h', bang = true })
					else
						gs.nav_hunk('next')
					end
				end)

				map('n', '[h', function()
					if vim.wo.diff then
						vim.cmd.normal({ '[h', bang = true })
					else
						gs.nav_hunk('prev')
					end
				end)

				map('n', '<leader>hs', gs.stage_hunk)
				map('n', '<leader>hr', gs.reset_hunk)
				map('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
				map('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
				map('n', '<leader>hS', gs.stage_buffer)
				map('n', '<leader>hu', gs.undo_stage_hunk)
				map('n', '<leader>hR', gs.reset_buffer)

				map('n', '<leader>hp', gs.preview_hunk)
				map('n', '<leader>hb', function() gs.blame_line { full = true } end)
				map('n', '<leader>hd', gs.diffthis)
				map('n', '<leader>hD', function() gs.diffthis('~') end)
				map('n', '<leader>tb', gs.toggle_current_line_blame)
				map('n', '<leader>td', gs.toggle_deleted)
			end
		},
	},
}
