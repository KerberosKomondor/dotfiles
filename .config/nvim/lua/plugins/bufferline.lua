local _M = {
  'romgrk/barbar.nvim',
}

function _M.config()
  require 'bufferline'.setup({
    clickable = true,
  })
end

return _M
