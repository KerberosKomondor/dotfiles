local _M = {
  'barrett-ruth/import-cost.nvim',
  build = 'sh install.sh npm'
}

function _M.config()
  require('import-cost').setup()
end

return _M
