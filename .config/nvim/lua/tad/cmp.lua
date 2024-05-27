local cmp = require('cmp')
local types = require('cmp.types')
local context = require('cmp.config.context')
local luasnip = require('luasnip')

cmp.setup({
	completion = {
		completeopt = 'menu,menuone,noinsert',
	},
	enabled = function()
		if vim.bo.filetype == 'prompt' or vim.bo.filetype == 'TelescopePrompt' then
			return false
		elseif vim.api.nvim_get_mode().mode == 'c' then
			return true
		else
			return not context.in_treesitter_capture('comment')
					and not context.in_syntax_group('Comment')
		end
	end,
	mapping = {
		['<C-y>'] = cmp.mapping.scroll_docs(-1),
		['<C-u>'] = cmp.mapping.scroll_docs(-4),
		['<C-e>'] = cmp.mapping.scroll_docs(1),
		['<C-d>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-c>'] = cmp.mapping.abort(),
		['<Down>'] = cmp.mapping.select_next_item({ behavior = types.cmp.SelectBehavior.Select }),
		['<Up>'] = cmp.mapping.select_prev_item({ behavior = types.cmp.SelectBehavior.Select }),
		['<C-n>'] = cmp.mapping.select_next_item({ behavior = types.cmp.SelectBehavior.Insert }),
		['<C-p>'] = cmp.mapping.select_prev_item({ behavior = types.cmp.SelectBehavior.Insert }),
		['<Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.confirm({ select = true })
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { 'i', 's' }),
		['<S-Tab>'] = cmp.mapping(function(fallback)
			if luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { 'i', 's' }),
	},
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' }
	}, {
		{ name = 'buffer', keyword_length = 5 }
	}, {
		{ name = 'luasnip' }
	}),
})
