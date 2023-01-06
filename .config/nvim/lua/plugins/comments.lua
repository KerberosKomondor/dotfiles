local _M = {
  'terrortylor/nvim-comment',
  dependencies = {
    -- makes commentstring work for multilang files
    'JoosepAlviste/nvim-ts-context-commentstring',
  },
}

function _M.config()
  require('nvim_comment').setup({
    comment_empty = false,
    hook = function()
      require('ts_context_commentstring.internal').update_commentstring()
    end,
  })
end

return _M
