local function add_fts(t, fts)
	for _, ft in pairs(fts) do
		table.insert(t, ft)
	end
end

local ocaml_file_types = {}
add_fts(ocaml_file_types, vim.treesitter.language.get_filetypes("ocaml"))
add_fts(ocaml_file_types, vim.treesitter.language.get_filetypes("ocaml_interface"))
vim.api.nvim_create_autocmd("FileType", {
	pattern = ocaml_file_types,
	callback = function()
		-- set fileformat to 'unix' in ocaml files due to some issues with ocamlformat
		if vim.api.nvim_get_option_value("modifiable", {}) then
			vim.cmd(":set fileformat=unix")
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	callback = function(args)
		vim.keymap.set("n", "<CR>", function()
			local context = vim.fn.getloclist(0, { context = true }).context
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, true, true), "nx", false)
			if context and context.markdown_nvim_toc then
				vim.cmd("lclose")
			end
			vim.cmd("normal! zt")
		end, { buffer = args.buf, silent = true })
	end,
})
