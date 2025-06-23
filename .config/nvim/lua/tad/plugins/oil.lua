return {
	{
		'stevearc/oil.nvim',
		opts = {
			skip_confirm_for_simple_edits = true,
			view_options = {
				show_hidden = true,
			},
			win_options = {
				winbar = '%!v:lua.oilwinbar()',
			},
		},
		init = function()
			function _G.oilwinbar()
				local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
				local dir = require('oil').get_current_dir(bufnr)
				if dir then
					return vim.fn.fnamemodify(dir, ':~')
				else
					return vim.api.nvim_buf_get_name(0)
				end
			end

			vim.keymap.set('n', '-', '<Cmd>Oil<CR>')
			vim.keymap.set('n', '<Leader>-', '<Cmd>Oil --float<CR>')
		end,
	},
}
