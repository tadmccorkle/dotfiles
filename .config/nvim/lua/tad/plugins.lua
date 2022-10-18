local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
	Packer_Bootstrap = fn.system({
		'git', 'clone', '--depth', '1',
		'https://github.com/wbthomason/packer.nvim',
		install_path
	})
	vim.cmd [[packadd packer.nvim]]
end

-- grouping denotes where plugins are configured in 
-- `after/plugin/` unless otherwise noted
return require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'

	use 'lewis6991/impatient.nvim'

	use 'EdenEast/nightfox.nvim'
	use 'nvim-lualine/lualine.nvim'

	-- configured with `lspconfig`
	use 'williamboman/mason.nvim'

	use 'neovim/nvim-lspconfig'
	use 'williamboman/mason-lspconfig.nvim'
	use 'hrsh7th/cmp-nvim-lsp'
	use 'hrsh7th/cmp-buffer'
	use 'hrsh7th/nvim-cmp'
	use 'L3MON4D3/LuaSnip'

	use 'jose-elias-alvarez/null-ls.nvim'

	use 'glepnir/lspsaga.nvim'

	use 'MunifTanjim/prettier.nvim'

	use {
		'nvim-treesitter/nvim-treesitter',
		run = function()
			require('nvim-treesitter.install').update({ with_sync = true })
		end,
	}
	use 'windwp/nvim-ts-autotag'

	use 'windwp/nvim-autopairs'

	use 'lukas-reineke/indent-blankline.nvim'

	-- will try out in the future
	--use 'kyazdani42/nvim-tree.lua'

	use {
		'nvim-telescope/telescope.nvim',
		requires = { { 'nvim-lua/plenary.nvim' } },
	}

	use 'numToStr/Comment.nvim'

	use 'norcalli/nvim-colorizer.lua'

	use 'dinhhuy258/git.nvim'

	use 'lewis6991/gitsigns.nvim'

	use 'folke/zen-mode.nvim'

	if Packer_Bootstrap then
		require('packer').sync()
	end
end)
