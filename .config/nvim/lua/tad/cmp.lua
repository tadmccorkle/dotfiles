local cmp = require("cmp")
local types = require("cmp.types")

for _, ft_path in ipairs(vim.api.nvim_get_runtime_file("lua/tad/snippets/*.lua", true)) do
	loadfile(ft_path)()
end

cmp.setup({
	completion = {
		completeopt = "menu,menuone,noinsert",
	},
	enabled = function()
		if vim.bo.filetype == "prompt" then
			return false
		elseif vim.api.nvim_get_mode().mode == "c" then
			return true
		else
			local context = require("cmp.config.context")
			return not context.in_treesitter_capture("comment") and not context.in_syntax_group("Comment")
		end
	end,
	mapping = {
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-c>"] = cmp.mapping.abort(),
		["<Down>"] = cmp.mapping.select_next_item({ behavior = types.cmp.SelectBehavior.Select }),
		["<Up>"] = cmp.mapping.select_prev_item({ behavior = types.cmp.SelectBehavior.Select }),
		["<C-n>"] = cmp.mapping.select_next_item({ behavior = types.cmp.SelectBehavior.Insert }),
		["<C-p>"] = cmp.mapping.select_prev_item({ behavior = types.cmp.SelectBehavior.Insert }),
		["<C-y>"] = cmp.mapping.confirm({ select = true }),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.confirm({ select = true })
			else
				fallback()
			end
		end, { "i", "s" }),
		["<C-l>"] = cmp.mapping(function(fallback)
			local luasnip = require("luasnip")
			if luasnip.expand_or_locally_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<C-h>"] = cmp.mapping(function(fallback)
			local luasnip = require("luasnip")
			if luasnip.locally_jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	},
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	sources = cmp.config.sources({
		{ name = "lazydev", group_index = 0 },
	}, {
		{ name = "nvim_lsp" },
	}, {
		{ name = "buffer", keyword_length = 5 },
	}, {
		{ name = "luasnip" },
	}),
})
