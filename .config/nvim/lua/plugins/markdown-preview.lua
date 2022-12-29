local _M = {
  "iamcco/markdown-preview.nvim",
  build = "cd app && npm install",
  ft = "markdown",
}

function _M.init()
  vim.g.mkdp_filetypes = { "markdown" }
end

return _M
