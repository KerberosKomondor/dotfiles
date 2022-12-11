local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()
vim.cmd [[packadd packer.nvim]]

local ok, packer = pcall(require, 'packer')
if not ok then return end

return packer.startup(function(use)
  use "wbthomason/packer.nvim"
  use "dracula/vim"

  use {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
    "jose-elias-alvarez/null-ls.nvim",
  }

  use {
    "L3MON4D3/LuaSnip",
    "rafamadriz/friendly-snippets",
    config = function()
      require('user.configs.luasnip')
    end
  }

  use {
    'rcarriga/nvim-notify',
    config = function()
      require('user.configs.notify')
    end
  }

  --use {
  --  'nvim-telescope/telescope-fzf-native.nvim',
  --  run = 'make'
  --}

  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      'nvim-lua/plenary.nvim',
      'BurntSushi/ripgrep',
      'nvim-telescope/telescope-fzf-native.nvim',
    },
    config = function()
      require('user.configs.telescope')
    end,
  }

  use {
    'folke/which-key.nvim',
    config = function()
      require('user.configs.which-key')
    end,
  }

  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
      'kyazdani42/nvim-web-devicons', -- optional, for file icons
    },
    config = function()
      require('user.configs.nvim-tree')
    end
  }

  use {
    "rebelot/terminal.nvim",
    config = function()
      require "terminal".setup()
    end
  }
  use {
    "rebelot/heirline.nvim",
    config = function()
      require('user.configs.heirline')
    end
  }
  use {
    "SmiteshP/nvim-navic",
    requires = "neovim/nvim-lspconfig",
    config = function()
      require('user.configs.navic')
    end
  }

  use {
    'folke/trouble.nvim',
    config = function()
      require('user.configs.trouble')
    end
  }

  use 'jbyuki/one-small-step-for-vimkind'

  use {
    'mfussenegger/nvim-dap',
    config = function()
      require('user.configs.dap')
    end
  }

  use {
    'hrsh7th/nvim-cmp',
    config = function()
      require('user.configs.cmp')
    end,
    requires = {
      { "David-Kunz/cmp-npm", config = function() require("cmp-npm").setup() end },
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-path' },
      { 'hrsh7th/cmp-emoji' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-git', config = function() require('cmp_git').setup() end },
      { 'hrsh7th/cmp-nvim-lua' },
      { 'hrsh7th/cmp-cmdline' },
      { 'hrsh7th/cmp-omni' },
    }
  }

  use { 'TimUntersberger/neogit',
    requires = 'nvim-lua/plenary.nvim',
    config = function() require('neogit').setup() end
  }
  use {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('user.configs.gitsigns')
    end,
  }

  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function()
      require('user.configs.treesitter')
    end,
  }

  use {
    'stevearc/dressing.nvim',
    config = function()
      require('dressing').setup()
    end,
  }

  use {
    'goolord/alpha-nvim',
    requires = { 'kyazdani42/nvim-web-devicons' },
    config = function()
      require 'alpha'.setup(require 'alpha.themes.startify'.config)
    end
  }

  use {
    'norcalli/nvim-colorizer.lua',
    config = function()
      require 'colorizer'.setup()
    end
  }

  use({
    "folke/noice.nvim",
    event = "VimEnter",
    config = function()
      require("noice").setup({
        lsp = {
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        -- you can enable a preset for easier configuration
        presets = {
          bottom_search = true, -- use a classic bottom cmdline for search
          command_palette = true, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = false, -- add a border to hover docs and signature help
        },
      })
    end,
    requires = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
      "hrsh7th/nvim-cmp",
    }
  })

  if packer_bootstrap then
    require('packer').sync()
  end
end)
