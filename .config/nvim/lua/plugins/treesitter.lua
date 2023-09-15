local _M = {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  dependencies = {
    {
      'windwp/nvim-autopairs',
      event = "InsertEnter",
      opts = {}
    },
    {
      'windwp/nvim-ts-autotag',
      event = "InsertEnter",
      opts = {}
    },
  },
}

function _M.config()
  local ok, treesitter = pcall(require, "nvim-treesitter.configs")
  if not ok then
    return
  end

  treesitter.setup({
    ensure_installed = {
      "bash",
      "c_sharp",
      "go",
      "graphql",
      "html",
      "javascript",
      "json",
      "lua",
      "markdown",
      "markdown_inline",
      "regex",
      "rust",
      "sql",
      "tsx",
      "typescript",
      "vim",
      "yaml",
    },
    auto_install = true,
    context_commentstring = {
      enabled = true,
      enable_autocmd = false,
    },
    autotag = {
      enabled = true,
      enable_rename = true,
      enable_close_on_slash = false,
    },
  })
end

return _M
