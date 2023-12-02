local function add_fts(t, fts)
	for _, ft in pairs(fts) do
		table.insert(t, ft)
	end
end

-- set fileformat to 'unix' in ocaml files due to some issues with ocamlformat
local ocaml_file_types = {}
add_fts(ocaml_file_types, vim.treesitter.language.get_filetypes("ocaml"))
add_fts(ocaml_file_types, vim.treesitter.language.get_filetypes("ocaml_interface"))
vim.api.nvim_create_autocmd("FileType", {
	pattern = ocaml_file_types,
	callback = function()
		if vim.api.nvim_get_option_value("modifiable", {}) then
			vim.cmd(":set fileformat=unix")
		end
	end,
})
