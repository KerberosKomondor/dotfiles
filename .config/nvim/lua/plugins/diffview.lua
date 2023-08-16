local M = {
  "sindrets/diffview.nvim",
}

function M.config()
  require("diffview").setup()
end

return M
