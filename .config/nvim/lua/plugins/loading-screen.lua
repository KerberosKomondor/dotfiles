local _M = {
  'goolord/alpha-nvim',
  name = 'loading-screen',
  dependencies = {
    'kyazdani42/nvim-web-devicons'
  }
}

function _M.config()
  require 'alpha'.setup(require 'alpha.themes.startify'.config)
end

return _M
