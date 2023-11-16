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


require 'lspkind'.init({
  mode = 'symbol',
  symbol_map = {
    Copilot = "",
  }
})

local colors = require("dracula").colors()
vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = colors.pink })

local config = {
  window = {
    completion = cmp.config.window.bordered(),
  },
  experimental = {
    native_menu = false,
    ghost_text = true,
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end
  },
  sources = require('cmp').config.sources({
    { name = 'npm',    keyword_length = 3 },
    {
      name = 'nvim_lsp',
      entry_filter = function(entry)
        return require('cmp').lsp.CompletionItemKind.Snippet ~= entry:get_kind()
      end
    },
    { name = 'nvim_lua' },
    { name = 'copilot' },
    { name = 'jira' },
  }, {
    { name = 'luasnip', keyword_length = 1 },
    { name = 'path' },
    { name = 'buffer',  keyword_length = 5 },
  }),
  mapping = cmp.mapping.preset.insert({
    ['<C-y>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.confirm({ select = false })
      elseif require 'copilot.suggestion'.is_visible() then
        require 'copilot.suggestion'.accept()
      else
        fallback()
      end
    end, { "i", "s" }),
    ['<C-e>'] = cmp.mapping(function()
      if cmp.visible() then
        cmp.abort()
      else
        cmp.complete()
      end
    end),
    ['<Up>'] = vim.NIL,
    ['<Down>'] = vim.NIL,
    ['<C-d>'] = cmp.mapping(function(fallback)
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jumpable()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<C-b>'] = cmp.mapping(function(fallback)
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<C-l>'] = cmp.mapping(function()
      if luasnip.choice_active() then
        luasnip.change_choice(1)
      end
    end, { 'i' }),
  }),
}

if ok_luasnip then
  -- to resource snippets
  -- vim.keymap.set('n', '<leader><leader>s', '<cmd>source put dir here<cr>')

  require('luasnip.loaders.from_vscode').lazy_load({ paths = { '~/.local/share/nvim/lazy/friendly-snippets' } })
end

M.config = config

return M
