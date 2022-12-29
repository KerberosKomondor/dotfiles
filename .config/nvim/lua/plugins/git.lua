local _M = {
  name = 'git',
  'lewis6991/gitsigns.nvim',
  dependencies = {
    'TimUntersberger/neogit',
    'nvim-lua/plenary.nvim'
  }
}

function _M.config()
  require 'gitsigns'.setup()
  require 'neogit'.setup()
end

return _M
