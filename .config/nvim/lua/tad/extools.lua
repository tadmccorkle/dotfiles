require('mason').setup()

local schemas = require('schemastore')

local langservers = {
	bashls = true,
	clangd = true,
	cssls = {
		server_capabilities = {
			documentFormattingProvider = false,
		},
	},
	cssmodules_ls = {
		server_capabilities = {
			documentFormattingProvider = false,
		},
	},
	gopls = true,
	html = {
		server_capabilities = {
			documentFormattingProvider = false,
		},
	},
	jsonls = {
		config = {
			settings = {
				json = {
					schemas = schemas.json.schemas(),
					validate = { enable = true },
				},
			},
		},
		server_capabilities = {
			documentFormattingProvider = false,
		},
	},
	lemminx = true,
	lua_ls = {
		config = {
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
		},
	},
	marksman = true,
	ocamllsp = {
		manual_install = {
			check = vim.fn.executable('opam') == 1,
		},
	},
	-- omnisharp = true,
	pyright = true,
	rust_analyzer = true,
	-- rust_analyzer = {
	-- 	on_attach = function(client, bufnr)
	-- 		require('inlayhints.rust').on_attach(client, bufnr)
	-- 	end,
	-- },
	svelte = true,
	tailwindcss = true,
	templ = true,
	ts_ls = true,
	yamlls = {
		config = {
			settings = {
				yaml = {
					schemas = schemas.json.schemas(),
					validate = { enable = true },
				},
			},
		},
	},
	zls = {
		config = {
			settings = {
				zls = {
					semantic_tokens = 'partial',
				},
			},
		},
		manual_install = {
			check = vim.fn.executable('zls') == 1,
		},
		setup = function()
			vim.g.zig_fmt_autosave = 0
		end,
	},
}

local ensure_installed = {
	'biome',
	'prettierd',
	'stylua',
	'sleek',
}

vim.list_extend(
	ensure_installed,
	vim.tbl_filter(function(name)
		local cfg = langservers[name]
		if type(cfg) == 'table' then
			return not cfg.manual_install
		else
			return cfg
		end
	end, vim.tbl_keys(langservers))
)

require('mason-tool-installer').setup({ ensure_installed = ensure_installed })

-- --------------------- --
-- language server setup --
-- --------------------- --
local lspconfig = require('lspconfig')
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local function ls_setup(name, settings)
	if settings == true then
		settings = {}
	end

	if settings.manual_install and not settings.manual_install.check then
		return
	end

	if vim.is_callable(settings.setup) then
		settings.setup()
	end

	local cfg = vim.tbl_deep_extend('force', {
		capabilities = capabilities,
	}, settings.config or {})

	lspconfig[name].setup(cfg)
end

for name, settings in pairs(langservers) do
	ls_setup(name, settings)
end

vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('tad-lspattach', { clear = true }),
	callback = function(args)
		local client =
			assert(vim.lsp.get_client_by_id(args.data.client_id), 'LSP client ID not provided in LspAttach args!')
		local bufnr = args.buf

		local settings = langservers[client.name]
		if type(settings) ~= 'table' then
			settings = {}
		end

		-- enable completion triggered by <c-x><c-o>
		vim.api.nvim_set_option_value('omnifunc', 'v:lua.vim.lsp.omnifunc', { buf = bufnr })

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

		if settings.server_capabilities then
			for k, v in pairs(settings.server_capabilities) do
				if v == vim.NIL then
					---@diagnostic disable-next-line: cast-local-type
					v = nil
				end

				client.server_capabilities[k] = v
			end
		end

		if vim.is_callable(settings.on_attach) then
			settings.on_attach(client, bufnr)
		end
	end,
})

-- ------------ --
-- linter setup --
-- ------------ --
-- vim.env.ESLINT_D_PPID = vim.fn.getpid()
-- local eslint_d = { 'eslint_d' }
-- require('lint').linters_by_ft = {
-- 	javascript = eslint_d,
-- 	javascriptreact = eslint_d,
-- 	['javascript.jsx'] = eslint_d,
-- 	typescript = eslint_d,
-- 	typescriptreact = eslint_d,
-- 	['typescript.tsx'] = eslint_d,
-- 	svelte = eslint_d,
-- }
--
-- vim.api.nvim_create_autocmd('BufWritePost', {
-- 	group = vim.api.nvim_create_augroup('tad-bufwritepost-lint', { clear = true }),
-- 	callback = function()
-- 		require('lint').try_lint()
-- 	end,
-- })

-- --------------- --
-- formatter setup --
-- --------------- --
local conform = require('conform')

local web_formatters = { 'prettierd', 'prettier', 'biome', stop_after_first = true }
conform.setup({
	format_on_save = function(bufnr)
		if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
			return
		end
		return { timeout_ms = 500 }
	end,
	formatters_by_ft = {
		lua = { 'stylua' },
		sql = { 'sleek' },
		css = web_formatters,
		scss = web_formatters,
		html = web_formatters,
		json = web_formatters,
		jsonc = web_formatters,
		graphql = web_formatters,
		javascript = web_formatters,
		javascriptreact = web_formatters,
		typescript = web_formatters,
		typescriptreact = web_formatters,
	},
	default_format_opts = {
		lsp_format = 'fallback',
	},
	formatters = {
		biome = {
			require_cwd = true,
		},
		prettier = {
			require_cwd = true,
		},
		prettierd = {
			require_cwd = true,
		},
	},
})

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
vim.keymap.set('n', '<Leader>gq', conform.format, { noremap = true, silent = true })

vim.api.nvim_create_user_command('FormatDisable', function(args)
	if args.bang then
		vim.b.disable_autoformat = true
		print('Disabled format-on-save for current buffer.')
	else
		vim.g.disable_autoformat = true
		print('Globally disabled format-on-save.')
	end
end, { desc = 'disable format-on-save', bang = true })
vim.api.nvim_create_user_command('FormatEnable', function()
	vim.b.disable_autoformat = false
	vim.g.disable_autoformat = false
end, { desc = 'enable format-on-save' })
