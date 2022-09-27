local _M = {}

local ok, null_ls = pcall(require, 'null-ls')
if not ok then return end

local with_root_file = function(...)
  local files = { ... }
  return function(utils)
    return utils.root_has_file(files)
  end
end

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics
local code_actions = null_ls.builtins.code_actions
local completion = null_ls.builtins.completion
local hover = null_ls.builtins.hover

_M.setup = function(on_attach)
  null_ls.setup {
    sources = {
      -- code actions
      code_actions.eslint_d.with({
        condition = with_root_file({ ".eslintrc", ".eslintrc.js", ".eslintrc.json" })
      }),
      -- formatting
      formatting.eslint_d.with({
        condition = with_root_file({ ".eslintrc", ".eslintrc.js", ".eslintrc.json" }),
      }),
      -- completion
      completion.luasnip,
      -- diagnostics
      diagnostics.eslint_d.with({
        condition = with_root_file({ ".eslintrc", ".eslintrc.js", ".eslintrc.json" }),
      }),

      -- hover
      hover.dictionary,
    },
    on_attach = on_attach,
  }
end

return _M
