local _M = {
  'VonHeikemen/lsp-zero.nvim',
  dependencies = {
    -- LSP Support
    { 'neovim/nvim-lspconfig' },
    { 'williamboman/mason.nvim' },
    { 'williamboman/mason-lspconfig.nvim' },

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
  }
}

function _M.config()
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
      { name = 'npm', keyword_length = 4 },
      { name = 'nvim_lsp', keyword_length = 3 },
    }, {
      { name = 'path' },
      { name = 'buffer', keyword_length = 3 },
    }),
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
