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
}

local sources = require('cmp').config.sources({
        { name = 'npm',     keyword_length = 3 },
        { name = 'nvim_lsp' },
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
  M.mapping['<C-d>'] = cmp.mapping(function(fallback)
        if luasnip.jumpable(1) then
          luasnip.jump(1)
        else
          fallback()
        end
      end, { 'i', 's' })

  M.mapping['<C-b>'] = cmp.mapping(function(fallback)
        if luasnip.jumpable( -1) then
          luasnip.jump( -1)
        else
          fallback()
        end
      end, { 'i', 's' })
end


M.blended_config = config
M.mapping = cmp.mapping.preset.insert(mapping)
M.sources = sources

return M
