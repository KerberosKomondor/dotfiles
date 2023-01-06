local _M = {
  'barrett-ruth/import-cost.nvim',
  build = 'sh install.sh yarn'
}

function _M.config()
  require('import-cost').setup()
end

return _M
