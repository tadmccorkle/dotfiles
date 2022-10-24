local status1, mason = pcall(require, 'mason')
local status2, mason_lspconfig = pcall(require, 'mason-lspconfig')
local status3, cmp = pcall(require, 'cmp')
local status4, luasnip = pcall(require, 'luasnip')
local status5, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
local status6, lspconfig = pcall(require, 'lspconfig')
---@cast cmp -? (don't worry about nil check)

local status = status1 and status2 and status3
		and status4 and status5 and status6
if not status then return end


-- set up mason before lspconfig to handle language server installation
mason.setup()
mason_lspconfig.setup({
	automatic_installation = true,
})


-- set up completion
local types = require('cmp.types')
local context = require('cmp.config.context')

local function has_words_before()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	local before = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
	return col ~= 0 and before:sub(col, col):match("%s") == nil
end

cmp.setup({
	enabled = function()
		if vim.api.nvim_get_mode().mode == 'c' then
			return true
		else
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
		['<C-y>'] = cmp.mapping.confirm({ select = true }),
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
		{ name = 'buffer', keyword_length = 5 }
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
	diagnostic_goto_prev = { vim.diagnostic.goto_prev, '<Cmd>Lspsaga diagnostic_jump_prev<CR>' },
	diagnostic_goto_next = { vim.diagnostic.goto_next, '<Cmd>Lspsaga diagnostic_jump_next<CR>' },
	signature_help = { vim.lsp.buf.signature_help, '<Cmd>Lspsaga signature_help<CR>' },
	code_action = { vim.lsp.buf.code_action, '<Cmd>Lspsaga code_action<CR>' },
	rename = { vim.lsp.buf.rename, '<Cmd>Lspsaga rename<CR>' },
	hover = { vim.lsp.buf.hover, '<Cmd>Lspsaga hover_doc<CR>' },
}

map('n', '<Leader>do', vim.diagnostic.open_float, opts)
map('n', '<Leader>dl', vim.diagnostic.setloclist, opts)
map('n', '<Leader>dp', maps.diagnostic_goto_prev[i], opts)
map('n', '<Leader>dn', maps.diagnostic_goto_next[i], opts)
map('n', '<Leader>dP', function()
	maps.diagnostic[i].goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, opts)
map('n', '<Leader>dN', function()
	maps.diagnostic[i].goto_next({ severity = vim.diagnostic.severity.ERROR })
end, opts)

-- mappings when a language server has attached to buffer
local function map_buf(_, bufnr)
	-- enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	map({ 'n', 'i' }, '<C-h>', maps.signature_help[i], bufopts)
	map('n', 'K', maps.hover[i], bufopts)
	map('n', '<Leader>rn', maps.rename[i], bufopts)
	map('n', '<Leader>vca', maps.code_action[i], bufopts)
	map('n', '<Leader>vgD', vim.lsp.buf.declaration, bufopts)
	map('n', '<Leader>vgd', vim.lsp.buf.definition, bufopts)
	map('n', '<Leader>vgr', vim.lsp.buf.references, bufopts)
	map('n', '<Leader>vgi', vim.lsp.buf.implementation, bufopts)
	map('n', '<Leader>vgt', vim.lsp.buf.type_definition, bufopts)
	map('n', '<Leader>f', function()
		vim.lsp.buf.format({ async = true })
	end, bufopts)
	map('n', '<Leader>vwa', vim.lsp.buf.add_workspace_folder, bufopts)
	map('n', '<Leader>vwr', vim.lsp.buf.remove_workspace_folder, bufopts)
	map('n', '<Leader>vwl', function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, bufopts)

	if saga_diagnostic_status then
		map('n', '<Leader>vlf', '<Cmd>Lspsaga lsp_finder<CR>', bufopts)
		map('n', '<Leader>vpd', '<Cmd>Lspsaga peek_definition<CR>', bufopts)
		map('v', '<Leader>vca', '<Cmd>Lspsaga range_code_action<CR>', bufopts)
		map('n', '<Leader>vcd', '<Cmd>Lspsaga show_line_diagnostics<CR>', bufopts)
		map('n', '<Leader>vcd', '<Cmd>Lspsaga show_cursor_diagnostics<CR>', bufopts)
		map('n', '<Leader>o', '<Cmd>LSoutlineToggle<CR>', bufopts)
		map('n', '<A-d>', '<Cmd>Lspsaga open_floaterm<CR>', bufopts)
		map('t', '<A-d>', [[<C-\><C-n><Cmd>Lspsaga close_floaterm<CR>]], bufopts)
	end
end

-- common language server configuration
local function on_attach(client, bufnr)
	map_buf(client, bufnr)
end

local capabilities = cmp_nvim_lsp.default_capabilities()

local function config(cfg)
	return vim.tbl_deep_extend('force', {
		on_attach = on_attach,
		capabilities = capabilities,
	}, cfg or {})
end

-- language server configurations

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

local rust_inlayhints = require('inlayhints.rust')
lspconfig.rust_analyzer.setup(config({
	on_attach = function(client, bufnr)
		on_attach(client, bufnr)
		rust_inlayhints.on_attach(client, bufnr)
	end,
}))

lspconfig.tsserver.setup(config())
lspconfig.eslint.setup(config())
lspconfig.svelte.setup(config())
lspconfig.html.setup(config())
lspconfig.cssls.setup(config())
lspconfig.cssmodules_ls.setup(config())
lspconfig.tailwindcss.setup(config())
lspconfig.jsonls.setup(config())
