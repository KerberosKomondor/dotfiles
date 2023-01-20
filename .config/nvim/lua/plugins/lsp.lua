local _M = {
  name = 'lsp',
  'VonHeikemen/lsp-zero.nvim',
  dependencies = {
    -- LSP Support
    { 'neovim/nvim-lspconfig' },
    { 'williamboman/mason.nvim' },
    { 'williamboman/mason-lspconfig.nvim' },
    { 'folke/neodev.nvim' },

    -- Autocompletion
    { 'hrsh7th/nvim-cmp' },
    { 'hrsh7th/cmp-buffer' },
    { 'hrsh7th/cmp-path' },
    { 'saadparwaiz1/cmp_luasnip' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/cmp-nvim-lua' },
    { 'David-Kunz/cmp-npm' },

    -- Snippets - disabled for now
    { 'L3MON4D3/LuaSnip' },
    --{ 'rafamadriz/friendly-snippets' },

    -- Display
    { 'onsails/lspkind.nvim' },
  }
}

function _M.config()
  -- Needs to be before lsp is setup
  require('neodev').setup()
  ----------------------------------

  local lsp = require('lsp-zero')

  lsp.preset('recommended')

  local hasNpm, npm = pcall(require, 'cmp-npm')
  if hasNpm then
    npm.setup({
      ignore = {
        'beta', 'rc',
      },
    })
  end

  lsp.setup_nvim_cmp({
    sources = require('cmp').config.sources({
      { name = 'npm', keyword_length = 3 },
      { name = 'nvim_lsp' },
      { name = 'nvim_lua' },
    }, {
      { name = 'path' },
      { name = 'buffer', keyword_length = 5 },
    }),
    formatting = {
      format = require 'lspkind'.cmp_format {
        with_text = true,
        menu = {
          npm = "[NPM]",
          buffer = "[buf]",
          nvim_lsp = "[LSP]",
          nvim_lua = "[api]",
          path = "[path]",
          gh_issues = "[issues]",
        },
      },
    },
    experimental = {
      native_menu = false,
      ghost_text = true,
    },
  })

  lsp.use('sumneko_lua', {
    settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim' },
        },
      },
    },
  })

  lsp.nvim_workspace()

  lsp.setup()

  vim.cmd [[autocmd BufWritePre * LspZeroFormat]]
end

return _M
