local _M = {
  name = 'terminal',
  'akinsho/toggleterm.nvim',
}

function _M.config()
  require "toggleterm".setup()
end

return _M
