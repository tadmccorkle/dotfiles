-- set up mason before lspconfig to handle language server installation
local mason = require('mason')
local mason_lspconfig = require('mason-lspconfig')

mason.setup()
mason_lspconfig.setup({
	automatic_installation = true,
})


-- set up completion
local cmp = require('cmp')
local types = require('cmp.types')
---@cast cmp -?
local luasnip = require('luasnip')

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	local before = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
  return col ~= 0 and before:sub(col, col):match("%s") == nil
end

cmp.setup({
	enabled = function()
		if vim.api.nvim_get_mode().mode == 'c' then
			return true
		else
			local context = require('cmp.config.context')
			return not context.in_treesitter_capture('comment')
				and not context.in_syntax_group('Comment')
		end
	end,
	mapping = {
		['<C-u>'] = cmp.mapping.scroll_docs(-4),
		['<C-d>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<Down>'] = cmp.mapping.select_next_item({ behavior = types.cmp.SelectBehavior.Select }),
		['<Up>'] = cmp.mapping.select_prev_item({ behavior = types.cmp.SelectBehavior.Select }),
		['<C-n>'] = cmp.mapping.select_next_item({ behavior = types.cmp.SelectBehavior.Insert }),
		['<C-p>'] = cmp.mapping.select_prev_item({ behavior = types.cmp.SelectBehavior.Insert }),
		['<CR>'] = cmp.mapping.confirm({ select = true }),
		['<Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.confirm({ select = true })
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			elseif has_words_before() then
				cmp.complete()
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
		end
	},
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' }
	}, {
		{ name = 'buffer' }
	}, {
		{ name = 'luasnip' }
	}),
})

local SelectItem = { Next = 1, Prev = 2 }
local cmp_select = {
	[SelectItem.Next] = cmp.select_next_item,
	[SelectItem.Prev] = cmp.select_prev_item,
}

local function cmp_select_item_or_fallback(item)
	return function(fallback)
		if cmp.visible() then
			cmp_select[item]({ behavior = types.cmp.SelectBehavior.Insert })
		else
			fallback()
		end
	end
end

cmp.setup.cmdline('/', {
	mapping = {
		['<Tab>'] = cmp.mapping(cmp_select_item_or_fallback(SelectItem.Next), { 'c' }),
		['<Down>'] = cmp.mapping(cmp_select_item_or_fallback(SelectItem.Next), { 'c' }),
		['<C-n>'] = cmp.mapping(cmp_select_item_or_fallback(SelectItem.Next), { 'c' }),
		['<S-Tab>'] = cmp.mapping(cmp_select_item_or_fallback(SelectItem.Prev), { 'c' }),
		['<Up>'] = cmp.mapping(cmp_select_item_or_fallback(SelectItem.Prev), { 'c' }),
		['<C-p>'] = cmp.mapping(cmp_select_item_or_fallback(SelectItem.Prev), { 'c' }),
		['<C-e>'] = cmp.mapping.close(),
	},
	sources = {
		{ name = 'buffer' }
	}
})

vim.opt.completeopt = 'menu,menuone,noselect'
vim.cmd('highlight! default link CmpItemKind CmpItemMenuDefault')


-- global mappings
local map = require('tad.map')

local opts = { noremap = true, silent = true }
map('n', '<Leader>e', vim.diagnostic.open_float, opts)
map('n', '[d', vim.diagnostic.goto_prev, opts)
map('n', ']d', vim.diagnostic.goto_next, opts)
map('n', '<Leader>q', vim.diagnostic.setloclist, opts)

-- mappings when a language server has attached to buffer
---@diagnostic disable-next-line: unused-local
local on_attach = function(client, bufnr)
	-- enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	map('n', 'gD', vim.lsp.buf.declaration, bufopts)
	map('n', 'gd', vim.lsp.buf.definition, bufopts)
	map('n', 'gr', vim.lsp.buf.references, bufopts)
	map('n', 'gi', vim.lsp.buf.implementation, bufopts)
	map('n', 'K', vim.lsp.buf.hover, bufopts)
	map('n', '<Leader>rn', vim.lsp.buf.rename, bufopts)
	map('n', '<Leader>ca', vim.lsp.buf.code_action, bufopts)
	map('n', '<Leader>D', vim.lsp.buf.type_definition, bufopts)
	map('n', '<Leader>f', vim.lsp.buf.formatting, bufopts)
	map('n', '<C-h>', vim.lsp.buf.signature_help, bufopts)
	map('n', '<Leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
	map('n', '<Leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
	map('n', '<Leader>wl', function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, bufopts)
end


-- lsp client capabilities
local cmp_nvim_lsp = require('cmp_nvim_lsp')
local capabilities = vim.lsp.protocol.make_client_capabilities()
cmp_nvim_lsp.update_capabilities(capabilities)


-- common language server configuration
local function config(cfg)
	return vim.tbl_deep_extend('force', {
		on_attach = on_attach,
		capabilities = capabilities,
	}, cfg or {})
end


-- language server configurations
local lspconfig = require('lspconfig')

lspconfig.bashls.setup(config())

lspconfig.csharp_ls.setup(config())

lspconfig.sumneko_lua.setup(config({
	settings = {
		Lua = {
			runtime = {
				version = 'LuaJIT',
			},
			diagnostics = {
				globals = { 'vim' },
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file('', true),
			},
		},
	},
}))

lspconfig.pyright.setup(config())

lspconfig.rust_analyzer.setup(config())

lspconfig.tsserver.setup(config())
lspconfig.eslint.setup(config())
lspconfig.svelte.setup(config())
lspconfig.html.setup(config())
lspconfig.cssls.setup(config())
lspconfig.cssmodules_ls.setup(config())
lspconfig.tailwindcss.setup(config())
lspconfig.jsonls.setup(config())
