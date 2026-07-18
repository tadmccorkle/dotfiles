local M = {}

---@type vim.lsp.util.open_floating_preview.Opts
M.hover_float_opts = {
	border = "rounded",
	max_width = 100,
	max_height = 35,
	winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
}

---@type vim.diagnostic.Opts.Float
M.diagnostic_float_opts = {
	border = "rounded",
	max_width = 120,
	max_height = 35,
	source = true,
	header = "",
	prefix = function(_, i, n)
		if n > 1 then
			return tostring(i) .. ". ", ""
		end
		return "", ""
	end,
}

return M
