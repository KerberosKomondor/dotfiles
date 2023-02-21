local _M = {
    name = 'lsp',
    'VonHeikemen/lsp-zero.nvim',
    dependencies = {
        -- LSP Support
        { 'neovim/nvim-lspconfig' },
        { 'williamboman/mason.nvim' },
        { 'williamboman/mason-lspconfig.nvim' },
        { 'folke/neodev.nvim' },
        { 'jose-elias-alvarez/null-ls.nvim' },

        -- Autocompletion
        { 'hrsh7th/nvim-cmp' },
        { 'hrsh7th/cmp-buffer' },
        { 'hrsh7th/cmp-path' },
        { 'saadparwaiz1/cmp_luasnip' },
        { 'hrsh7th/cmp-nvim-lsp' },
        { 'hrsh7th/cmp-nvim-lua' },
        { 'David-Kunz/cmp-npm' },
        {
            'KerberosKomondor/cmp-jira.nvim',
            --dir = '/home/appa/code/cmp-jira.nvim/',
        },

        -- Snippets - disabled for now
        { 'L3MON4D3/LuaSnip' },
        --{ 'rafamadriz/friendly-snippets' },

        -- Display
        { 'onsails/lspkind.nvim' },
        { 'styled-components/vim-styled-components' },
    }
}

function _M.config()
  -- Needs to be before lsp is setup
  require('neodev').setup()
  ----------------------------------

  local lsp = require('lsp-zero')

  lsp.preset({
      name = 'minimal',
      set_lsp_keymaps = true,
      manage_nvim_cmp = true,
      suggest_lsp_servers = false,
  })

  local hasNpm, npm = pcall(require, 'cmp-npm')
  if hasNpm then
    npm.setup({
        ignore = {
            'beta', 'rc',
        },
    })
  end

  pcall(require, 'cmp-jira')

  lsp.setup_nvim_cmp({
      npm = "[NPM]",
      mapping = lsp.defaults.cmp_mappings({
          ['<Tab>'] = vim.NIL,
          ['<S-Tab>'] = vim.NIL,
          ['<CR>'] = vim.NIL,
          ['<Up>'] = vim.NIL,
          ['<Down>'] = vim.NIL,
      }),
      sources = require('cmp').config.sources({
          { name = 'npm',     keyword_length = 3 },
          { name = 'nvim_lsp' },
          { name = 'nvim_lua' },
          { name = 'jira' },
      }, {
          { name = 'path' },
          { name = 'buffer', keyword_length = 5 },
      }),
      formatting = {
          format = require 'lspkind'.cmp_format {
              with_text = true,
              menu = {
                  buffer = "[buf]",
                  nvim_lsp = "[LSP]",
                  nvim_lua = "[api]",
                  path = "[path]",
                  jira = "[jira]",
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

  local null_ls = require('null-ls')
  local null_opts = lsp.build_options('null-ls', {})

  null_ls.setup({
      on_attach = null_opts.on_attach,
      sources = {
          null_ls.builtins.formatting.eslint_d,
      },
  })
  lsp.nvim_workspace()

  lsp.setup()

  vim.cmd [[autocmd BufWritePre * LspZeroFormat]]
end

return _M
