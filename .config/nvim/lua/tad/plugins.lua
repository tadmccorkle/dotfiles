local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({
			'git', 'clone', '--depth', '1',
			'https://github.com/wbthomason/packer.nvim',
			install_path
		})
		vim.cmd [[packadd packer.nvim]]
		return true
	end
	return false
end

local packer_bootstrap = ensure_packer()

-- grouping denotes where plugins are configured in
-- `after/plugin/` unless otherwise noted
return require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'

	use 'nvim-lua/plenary.nvim'

	use 'EdenEast/nightfox.nvim'
	use 'nvim-lualine/lualine.nvim'

	use {
		'williamboman/mason.nvim',
		config = function() require('mason').setup() end,
	}

	use 'neovim/nvim-lspconfig'
	use 'williamboman/mason-lspconfig.nvim'
	use 'hrsh7th/cmp-nvim-lsp'
	use 'hrsh7th/cmp-buffer'
	use 'hrsh7th/nvim-cmp'
	use 'L3MON4D3/LuaSnip'
	-- might configure if writing C# outside Visual Studio
	-- use 'Hoffs/omnisharp-extended-lsp.nvim'

	use 'mfussenegger/nvim-dap'
	use 'theHamsta/nvim-dap-virtual-text'

	use {
		'nvim-treesitter/nvim-treesitter',
		run = function()
			require('nvim-treesitter.install').update({ with_sync = true })()
		end,
		requires = {
			{ 'windwp/nvim-ts-autotag' },
			{ 'nvim-treesitter/playground' },
		}
	}

	use 'windwp/nvim-autopairs'

	use 'lukas-reineke/indent-blankline.nvim'

	--use 'kyazdani42/nvim-tree.lua'

	use {
		'nvim-telescope/telescope.nvim', tag = '0.1.1',
		requires = 'nvim-lua/plenary.nvim',
	}
	use {
		'nvim-telescope/telescope-fzf-native.nvim',
		run =
		'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
	}

	use 'numToStr/Comment.nvim'

	use 'norcalli/nvim-colorizer.lua'

	use {
		'NeogitOrg/neogit',
		requires = 'nvim-lua/plenary.nvim',
	}
	use 'lewis6991/gitsigns.nvim'
	use 'sindrets/diffview.nvim'

	use 'folke/zen-mode.nvim'

	use '~/source/repos/markdown.nvim'

	if packer_bootstrap then
		require('packer').sync()
	end
end)
