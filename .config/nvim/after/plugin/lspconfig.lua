local status1, mason_lspconfig = pcall(require, 'mason-lspconfig')
local status2, cmp = pcall(require, 'cmp')
local status3, luasnip = pcall(require, 'luasnip')
local status4, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
local status5, lspconfig = pcall(require, 'lspconfig')
---@cast cmp -? (don't worry about nil check)

local status = status1 and status2 and status3 and status4 and status5
if not status then return end


-- set up mason before lspconfig to handle language server installation
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
		{ name = 'buffer', keyword_length = 5 }
	}, {
		{ name = 'luasnip' }
	}),
})

vim.opt.completeopt = 'menu,menuone,noselect'


-- global mappings
local map = require('tad.map')
local opts = { noremap = true, silent = true }

map('n', '<Leader>do', vim.diagnostic.open_float, opts)
map('n', '<Leader>dl', vim.diagnostic.setloclist, opts)
map('n', '<Leader>dp', vim.diagnostic.goto_prev, opts)
map('n', '<Leader>dn', vim.diagnostic.goto_next, opts)
map('n', '<Leader>dP', function()
	vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, opts)
map('n', '<Leader>dN', function()
	vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end, opts)

-- mappings when a language server has attached to buffer
local function map_buf(_, bufnr)
	-- enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	map({ 'n', 'i' }, '<C-h>', vim.lsp.buf.signature_help, bufopts)
	map('n', 'K', vim.lsp.buf.hover, bufopts)
	map('n', '<Leader>rn', vim.lsp.buf.rename, bufopts)
	map('n', '<Leader>ca', vim.lsp.buf.code_action, bufopts)
	map('n', '<Leader>gD', vim.lsp.buf.declaration, bufopts)
	map('n', '<Leader>gd', vim.lsp.buf.definition, bufopts)
	map('n', '<Leader>gr', vim.lsp.buf.references, bufopts)
	map('n', '<Leader>gi', vim.lsp.buf.implementation, bufopts)
	map('n', '<Leader>gt', vim.lsp.buf.type_definition, bufopts)
	map('n', '<Leader>f', vim.lsp.buf.format, bufopts)
	map('n', '<Leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
	map('n', '<Leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
	map('n', '<Leader>wl', function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, bufopts)
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

-- might configure C# LSP in future
--lspconfig.omnisharp.setup(config())

lspconfig.lua_ls.setup(config({
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
				checkThirdParty = false,
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
lspconfig.clangd.setup(config())


-- auto-formatting
local auto_format_enabled = true
vim.api.nvim_create_user_command('ToggleAutoFormat', function()
	auto_format_enabled = not auto_format_enabled
	print('Auto-formatting set to: ' .. tostring(auto_format_enabled))
end, {})

local augroups = {}
local get_augroup = function(client)
	if not augroups[client.id] then
		local group_name = 'lsp-format-' .. client.name
		local id = vim.api.nvim_create_augroup(group_name, { clear = true })
		augroups[client.id] = id
	end

	return augroups[client.id]
end

vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('lsp-attach-format', { clear = true }),
	callback = function(args)
		local client_id = args.data.client_id
		local client = vim.lsp.get_client_by_id(client_id)

		if not client.server_capabilities.documentFormattingProvider then
			return
		end

		if client.name == 'tsserver' then
			return
		end

		local bufnr = args.buf
		vim.api.nvim_create_autocmd('BufWritePre', {
			group = get_augroup(client),
			buffer = bufnr,
			callback = function()
				if not auto_format_enabled then
					return
				end

				vim.lsp.buf.format({
					async = false,
					filter = function(c)
						return c.id == client.id
					end,
				})
			end,
		})
	end,
})
