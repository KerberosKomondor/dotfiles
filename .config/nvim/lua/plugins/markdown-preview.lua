local M = {
  "iamcco/markdown-preview.nvim",
  build = "cd app && npm install",
  ft = "markdown",
}

function M.init()
  vim.g.mkdp_filetypes = { "markdown" }
end

return M
