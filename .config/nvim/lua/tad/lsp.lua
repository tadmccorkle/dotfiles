-- set up mason before lspconfig to handle language server installation
require('mason').setup()
require('mason-lspconfig').setup({
	ensure_installed = {},
	automatic_installation = {
		exclude = {
			"ocamllsp",
			"zls",
		},
	},
})

-- formatting
local conform = require('conform')
conform.setup({
	formatters_by_ft = {
		sql = { 'sleek' },
	},
	default_format_opts = {
		lsp_format = "fallback",
	},
})

vim.keymap.set('n', '<Leader>gq', conform.format, { noremap = true, silent = true })

local auto_format_enabled = true
vim.api.nvim_create_user_command('ToggleAutoFormat', function()
	auto_format_enabled = not auto_format_enabled
	print('Auto-formatting set to: ' .. tostring(auto_format_enabled))
end, {})

vim.api.nvim_create_autocmd('BufWritePre', {
	group = vim.api.nvim_create_augroup('', { clear = true }),
	callback = function(args)
		if not auto_format_enabled then
			return
		end

		conform.format({
			bufnr = args.buf,
			timeout_ms = 500,
		})
	end,
})

-- common language server configuration
local function on_attach(_, bufnr)
	-- enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

	-- mappings when a language server has attached to buffer
	local map = vim.keymap.set
	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	map('n', 'K', vim.lsp.buf.hover, bufopts)
	map('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
	map('n', '<Leader>rn', vim.lsp.buf.rename, bufopts)
	map('n', '<Leader>ca', vim.lsp.buf.code_action, bufopts)
	map('n', '<Leader>gD', vim.lsp.buf.declaration, bufopts)
	map('n', '<Leader>gd', vim.lsp.buf.definition, bufopts)
	map('n', '<Leader>gr', vim.lsp.buf.references, bufopts)
	map('n', '<Leader>gi', vim.lsp.buf.implementation, bufopts)
	map('n', '<Leader>gt', vim.lsp.buf.type_definition, bufopts)
	map('n', '<Leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
	map('n', '<Leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
	map('n', '<Leader>wl', function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, bufopts)
end

-- language server configurations
local lspconfig = require('lspconfig')
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local function config(cfg)
	return vim.tbl_deep_extend('force', {
		on_attach = on_attach,
		capabilities = capabilities,
	}, cfg or {})
end

lspconfig.bashls.setup(config())
lspconfig.clangd.setup(config())
lspconfig.cssls.setup(config())
lspconfig.cssmodules_ls.setup(config())
lspconfig.eslint.setup(config())
lspconfig.gopls.setup(config())
lspconfig.html.setup(config())
lspconfig.jsonls.setup(config())
lspconfig.lemminx.setup(config())
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
				checkThirdParty = false, -- disable luassert prompt
			},
			telemetry = { enable = false },
		},
	},
}))
lspconfig.marksman.setup(config())
lspconfig.pyright.setup(config())
lspconfig.rust_analyzer.setup(config({
	on_attach = function(client, bufnr)
		on_attach(client, bufnr)
		require('inlayhints.rust').on_attach(client, bufnr)
	end,
}))
lspconfig.svelte.setup(config())
lspconfig.tailwindcss.setup(config())
lspconfig.ts_ls.setup(config())
lspconfig.yamlls.setup(config())

vim.g.zig_fmt_autosave = 0
lspconfig.zls.setup(config({
	settings = {
		zls = {
			semantic_tokens = "partial",
		},
	},
}))

-- might configure C# LSP in future
--lspconfig.omnisharp.setup(config())

if vim.fn.executable("opam") == 1 then
	lspconfig.ocamllsp.setup(config())
end

-- vim.cmd([[
-- 	if executable("opam")
-- 		let g:opamshare = substitute(system('opam var share'), '\n$', '', '''')
-- 		execute "set rtp+=" . g:opamshare . "/merlin/vim"
-- 		execute "helptags " . g:opamshare . "/merlin/vim/doc"
-- 	endif
-- ]])

vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('lsp-attach-format', { clear = true }),
	callback = function(args)
		local client_id = args.data.client_id
		local client = vim.lsp.get_client_by_id(client_id)
		if client == nil then
			return
		end

		if not client.server_capabilities.documentFormattingProvider then
			return
		end

		if client.name == 'tsserver' then
			return
		end

		local bufnr = args.buf
	end,
})
