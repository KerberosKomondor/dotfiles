local _M = {
  'nvim-lualine/lualine.nvim',
  name = 'lines',
}

function _M.config()
  require'lualine'.setup({
    theme = 'dracula',
  })
end

return _M
