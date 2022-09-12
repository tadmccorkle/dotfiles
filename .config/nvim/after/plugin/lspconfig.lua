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

vim.opt.completeopt = 'menu,menuone,noselect'


-- global mappings
local map = require('tad.map')
local opts = { noremap = true, silent = true }

local saga_diagnostic_status, saga_diagnostic = pcall(require, 'lspsaga.diagnostic')
local i = saga_diagnostic_status and 2 or 1
local maps = {
	diagnostic = { vim.diagnostic, saga_diagnostic },
	diagnostic_goto_prev = { vim.diagnostic.goto_prev, '<cmd>Lspsaga diagnostic_jump_prev<CR>' },
	diagnostic_goto_next = { vim.diagnostic.goto_next, '<cmd>Lspsaga diagnostic_jump_next<CR>' },
	signature_help = { vim.lsp.buf.signature_help, '<cmd>Lspsaga signature_help<CR>' },
	code_action = { vim.lsp.buf.code_action, '<cmd>Lspsaga code_action<CR>' },
	rename = { vim.lsp.buf.rename, '<cmd>Lspsaga rename<CR>' },
	hover = { vim.lsp.buf.hover, '<cmd>Lspsaga hover_doc<CR>' },
}

map('n', '<Leader>vdf', vim.diagnostic.open_float, opts)
map('n', '<Leader>vdl', vim.diagnostic.setloclist, opts)
map('n', '<Leader>vdp', maps.diagnostic_goto_prev[i], opts)
map('n', '<Leader>vdn', maps.diagnostic_goto_next[i], opts)
map('n', '<Leader>vdP', function()
	maps.diagnostic[i].goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, opts)
map('n', '<Leader>vdN', function()
	maps.diagnostic[i].goto_next({ severity = vim.diagnostic.severity.ERROR })
end, opts)

-- mappings when a language server has attached to buffer
---@diagnostic disable-next-line: unused-local
local on_attach = function(client, bufnr)
	-- enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	map({ 'n', 'i' }, '<C-h>', maps.signature_help[i], bufopts)
	map('n', 'K', maps.hover[i], bufopts)
	map('n', '<Leader>vca', maps.code_action[i], bufopts)
	map('n', '<Leader>vrn', maps.rename[i], bufopts)
	map('n', '<Leader>vgD', vim.lsp.buf.declaration, bufopts)
	map('n', '<Leader>vgd', vim.lsp.buf.definition, bufopts)
	map('n', '<Leader>vgr', vim.lsp.buf.references, bufopts)
	map('n', '<Leader>vgi', vim.lsp.buf.implementation, bufopts)
	map('n', '<Leader>vgt', vim.lsp.buf.type_definition, bufopts)
	map('n', '<Leader>f', vim.lsp.buf.formatting, bufopts)
	map('n', '<Leader>vwa', vim.lsp.buf.add_workspace_folder, bufopts)
	map('n', '<Leader>vwr', vim.lsp.buf.remove_workspace_folder, bufopts)
	map('n', '<Leader>vwl', function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, bufopts)

	if saga_diagnostic_status then
		map('n', 'gh', '<cmd>Lspsaga lsp_finder<CR>', bufopts)
		map('n', 'gd', '<cmd>Lspsaga preview_definition<CR>', bufopts)
		map('v', '<leader>ca', '<cmd>Lspsaga range_code_action<CR>', bufopts)
		map('n', '<leader>cd', '<cmd>Lspsaga show_line_diagnostics<CR>', bufopts)
		map('n', '<leader>cd', '<cmd>Lspsaga show_cursor_diagnostics<CR>', bufopts)
		map('n', '<leader>o', '<cmd>LSoutlineToggle<CR>', bufopts)
		map('n', '<A-d>', '<cmd>Lspsaga open_floaterm<CR>', bufopts)
		map('t', '<A-d>', [[<C-\><C-n><cmd>Lspsaga close_floaterm<CR>]], bufopts)
	end
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
