local M = {
  "aznhe21/actions-preview.nvim",
}

function M.config()
  require("actions-preview").setup({
    backend = { "nui", "telescope" },
  })
end

return M
