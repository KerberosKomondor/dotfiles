local M = {
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
        { 'hrsh7th/cmp-nvim-lsp' },
        { 'hrsh7th/cmp-nvim-lua' },
        { 'David-Kunz/cmp-npm' },
        {
            'KerberosKomondor/cmp-jira.nvim',
            --dir = '/home/appa/code/cmp-jira.nvim/',
        },

        -- Formatters
        { 'lukas-reineke/lsp-format.nvim' },
        -- Snippets - disabled for now
        { 'rafamadriz/friendly-snippets' },

        -- Display
        { 'onsails/lspkind.nvim' },
        { 'styled-components/vim-styled-components' },
    }
}

function M.config()
  -- Needs to be before lsp is setup
  require('neodev').setup()
  require('lsp-format').setup()
  ----------------------------------

  local lsp = require('lsp-zero')
  local lspconfig = require('lspconfig')

  lsp.extend_lspconfig({
      set_lsp_keymaps = false,
      on_attach = function(client, bufnr)
        require('lsp-format').on_attach(client)

        local opts = { buffer = bufnr }

        -- Keybinds for lsp servers
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<Ctrl-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gl', vim.diagnostic.open_float, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
      end
  })

  require('mason').setup()
  require('mason-lspconfig').setup({
      ensure_installed = {
          'tsserver',
          'eslint',
          'lua_ls',
      }
  })

  require('mason-lspconfig').setup_handlers({
      function(server_name)
        lspconfig[server_name].setup({})
      end,
      ['lua_ls'] = function()
        lspconfig.lua_ls.setup {
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { 'vim' },
                    },
                },
            },
        }
      end,
  })

  --[[
  --      COMPLETION
  --]]
  local cmp_settings = require('user.cmp')

  -- Blend settings with default lsp-zero settings
  local cmp_config = require('lsp-zero').defaults.cmp_config(cmp_settings.blended_config)

  -- Override entire sections of cmp config
  cmp_config.mapping = cmp_settings.mapping
  cmp_config.sources = cmp_settings.sources

  require 'cmp'.setup(cmp_config)

  --[[
  --      DIAGNOSTICS
  --]]
  lsp.set_sign_icons()
  vim.diagnostic.config(lsp.defaults.diagnostics({}))


  --[[
  --      NULL_LS
  --]]
  local null_ls = require('null-ls')
  local null_opts = lsp.build_options('null-ls', {})

  null_ls.setup({
      on_attach = null_opts.on_attach,
      sources = {
          null_ls.builtins.formatting.eslint_d,
      },
  })

  lsp.nvim_workspace()
end

return M
