local M = {}

local ok_cmp, cmp = pcall(require, 'cmp')
if not ok_cmp then
  return
end

local ok_luasnip, luasnip = pcall(require, 'luasnip')

pcall(require, 'cmp-jira')
local hasNpm, npm = pcall(require, 'cmp-npm')
if hasNpm then
  npm.setup({
      ignore = {
          'beta', 'rc',
      },
  })
end


local config = {
    window = {
        completion = cmp.config.window.bordered(),
    },
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
    snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body)
        end
    }
}

local sources = require('cmp').config.sources({
        { name = 'npm',    keyword_length = 3 },
        { name = 'luasnip' },
        { name = 'nvim_lsp', entry_filter = function(entry)
          return require('cmp').lsp.CompletionItemKind.Snippet ~= entry:get_kind()
        end },
        { name = 'nvim_lua' },
        { name = 'jira' },
    }, {
        { name = 'path' },
        { name = 'buffer', keyword_length = 5 },
    })

local mapping = {
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
  mapping['<C-d>'] = cmp.mapping(function(fallback)
        if luasnip.expand_or_jumpable() then
          luasnip.expand_or_jumpable()
        else
          fallback()
        end
      end, { 'i', 's' })

  mapping['<C-b>'] = cmp.mapping(function(fallback)
        if luasnip.jumpable( -1) then
          luasnip.jump( -1)
        else
          fallback()
        end
      end, { 'i', 's' })

  mapping['<C-l>'] = cmp.mapping(function()
        if luasnip.choice_active() then
          luasnip.change_choice(1)
        end
      end, { 'i' })

  -- to resource snippets
  -- vim.keymap.set('n', '<leader><leader>s', '<cmd>source put dir here<cr>')

  require('luasnip.loaders.from_vscode').lazy_load({ paths = { '~/.local/share/nvim/lazy/friendly-snippets' } })
end


M.blended_config = config
M.mapping = cmp.mapping.preset.insert(mapping)
M.sources = sources

return M
