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
  ----------------------------------

  local lsp = require('lsp-zero')
  local lspconfig = require('lspconfig')
  local ok_luasnip, luasnip = pcall(require, 'luasnip')

  lsp.extend_lspconfig({
      set_lsp_keymaps = false,
      on_attach = function(_, bufnr)
        local opts = { buffer = bufnr }

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

  local hasNpm, npm = pcall(require, 'cmp-npm')
  if hasNpm then
    npm.setup({
        ignore = {
            'beta', 'rc',
        },
    })
  end

  pcall(require, 'cmp-jira')

  vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

  local cmp = require('cmp')
  local cmp_config = require('lsp-zero').defaults.cmp_config({
          formatting = {
              format = require 'lspkind'.cmp_format {
                  with_text = true,
                  menu = {
                      buffer = "[buf]",
                      nvim_lsp = "[LSP]",
                      nvim_lua = "[api]",
                      path = "[path]",
                      jira = "[jira]",
                      npm = "[NPM]",
                  },
              },
          },
          experimental = {
              native_menu = false,
              ghost_text = true,
          },
      })

  local cmp_mapping = {
      ['<C-y>'] = cmp.mapping.confirm({ select = false }),
      ['<C-e>'] = cmp.mapping(function()
        if cmp.visible() then
          cmp.abort()
        else
          cmp.complete()
        end
      end),
      ['<C-b>'] = cmp.mapping.scroll_docs( -4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<Up>'] = vim.NIL,
      ['<Down>'] = vim.NIL,
  }

  if ok_luasnip then
    cmp_mapping['<C-d>'] = cmp.mapping(function(fallback)
          if luasnip.jumpable(1) then
            luasnip.jump(1)
          else
            fallback()
          end
        end, { 'i', 's' })

    cmp_mapping['<C-b>'] = cmp.mapping(function(fallback)
          if luasnip.jumpable( -1) then
            luasnip.jump( -1)
          else
            fallback()
          end
        end, { 'i', 's' })
  end

  cmp_config.mapping = cmp.mapping.preset.insert(cmp_mapping)

  cmp_config.sources = require('cmp').config.sources({
          { name = 'npm',     keyword_length = 3 },
          { name = 'nvim_lsp' },
          { name = 'nvim_lua' },
          { name = 'jira' },
      }, {
          { name = 'path' },
          { name = 'buffer', keyword_length = 5 },
      })
  cmp.setup(cmp_config)


  lsp.set_sign_icons()
  vim.diagnostic.config(lsp.defaults.diagnostics({}))


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
