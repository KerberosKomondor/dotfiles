local M = {
  "mfussenegger/nvim-lint",
}

function M.config()
  require("lint").linters_by_ft = {
    markdown = { 'vale' },
    typescriptreact = { 'eslint_d'},
<<<<<<< Updated upstream
    typescript = { 'eslint_d' },
    lua = { 'luacheck' },
=======
    typescript = { 'eslint' },
    lua = { 'luacheck'},
    json = { 'jsonlint' },
    yaml = { 'yamllint' },
>>>>>>> Stashed changes
  }

  vim.diagnostic.config({
    virtual_text = {
      source = true,
    },
    float = {
      source = true,
    }
  })

  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    callback = function()
      require("lint").try_lint()
    end,
  })
end

return M
