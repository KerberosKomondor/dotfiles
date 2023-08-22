local M = {
  "mfussenegger/nvim-lint",
}

function M.config()
  require("lint").linters_by_ft = {
    markdown = { 'vale' },
    typescriptreact = { 'eslint_d'},
    typescript = { 'eslint' },
    lua = { 'luacheck' },
  }

  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    callback = function()
      require("lint").try_lint()
    end,
  })
end

return M
