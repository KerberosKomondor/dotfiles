local M = {
  name = "formatting",
  'nvimdev/guard.nvim',
}

function M.config()
  local ft = require('guard.filetype')

  ft('lua'):fmt('stylua')

  ft('typescript,javascript,typescriptreact')
    :fmt('prettier')
    :lint({
      cmd = "eslint",
      args = { '--fix' },
      fname = true,
    })

  require('guard').setup({
    fmt_on_save = true,
    lsp_as_default_formatter = true,
  })
end

return M
