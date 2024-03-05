return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = "BufReadPre",
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
    { "nvim-treesitter/nvim-treesitter-textobjects" },
  },
  config = function()
    local ok, treesitter = pcall(require, "nvim-treesitter.configs")
    if not ok then
      return
    end

    ---@diagnostic disable-next-line: missing-fields
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
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
      },
      auto_install = true,
      sync_install = false,
      context_commentstring = {
        enabled = true,
        enable_autocmd = false,
      },
      autotag = {
        enabled = true,
        enable_rename = true,
        enable_close_on_slash = false,
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ab"] = { query = "@braces.around", query_group = "surroundings" },
            ["ib"] = { query = "@braces.inner", query_group = "surroundings" },
            ["aq"] = { query = "@quotes.around", query_group = "surroundings" },
            ["iq"] = { query = "@quotes.inner", query_group = "surroundings" },
          },
        },
      },
      query_linter = {
        enable = true,
        use_virtual_text = true,
        lint_events = { "BufWrite", "CursorHold" },
      },
    })
  end,
}
