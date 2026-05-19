return {
	{
		"ibhagwan/fzf-lua",
		opts = {
			"default-title",
			fzf_opts = { ["--cycle"] = true },
			winopts = {
				preview = {
					default = "builtin",
					treesitter = { enable = false },
				},
			},
			keymap = {
				builtin = {
					true,
					["<C-u>"] = "preview-page-up",
					["<C-d>"] = "preview-page-down",
				},
			},
		},
		config = function(_, opts)
			local fzf = require("fzf-lua")

			fzf.setup(opts)

			local map = vim.keymap.set

			map("n", "<Leader>ff", fzf.files)
			map("n", "<Leader>fg", fzf.live_grep)
			map("n", "<Leader>fl", fzf.global)
			map("n", "<Leader>ft", fzf.git_files)
			map("n", "<Leader>fb", fzf.buffers)
			map("n", "<Leader>fm", fzf.keymaps)
			map("n", "<leader>f.", fzf.oldfiles)
			map("n", "<Leader>fw", fzf.grep_cword)
			map("n", "<Leader>fh", fzf.helptags)
			map("n", "<Leader>fd", fzf.diagnostics_document)
			map("n", "<leader>fc", function()
				require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
			end)
			map("n", "<leader>/", function()
				require("fzf-lua").blines({
					winopts = {
						height = 0.6,
						width = 0.6,
						row = 0.5,
						preview = { hidden = "hidden" },
					},
				})
			end)
			map("n", "<Leader>fr", fzf.resume)
		end,
	},
}
