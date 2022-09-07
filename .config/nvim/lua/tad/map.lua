return function(mode, lhs, rhs, opts)
	vim.keymap.set(mode, lhs, rhs, opts or {})
end
