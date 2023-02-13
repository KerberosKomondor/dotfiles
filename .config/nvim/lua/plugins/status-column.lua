local M = {
  name = 'status-column',
  'luukvbaal/statuscol.nvim',
  dependencies = {
    'gen740/SmoothCursor.nvim',
  },
}

function M.setup()
  require 'statuscol'.setup()
  require 'smoothcursor'.setup({
    fancy = {
      enable = false,
    },
    disable_float_win = true,
  })
end

return M
