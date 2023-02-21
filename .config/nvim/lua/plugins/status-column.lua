local M = {
    name = 'status-column',
    'luukvbaal/statuscol.nvim',
}

function M.setup()
  require 'statuscol'.setup()
end

return M
