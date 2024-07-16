return {
  {
    "tamago324/cmp-zsh",
    dependencies = { "Shougo/deol.nvim" },
    opts = { zshrc = true, filetypes = { "deoledit", "zsh" } },
  },
  {
    "David-Kunz/cmp-npm",
    dependencies = {
      "Mofiqul/dracula.nvim",
    },
    ft = "json",
    config = function()
      local colors = require("dracula").colors()
      require("cmp-npm").setup({
        ignore = {
          "beta",
          "rc",
        },
      })

      ---@diagnostic disable-next-line: undefined-field
      vim.api.nvim_set_hl(0, "CmpItemKindNpm", { fg = colors.purple })
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    enabled = false,
  },
  {
    "nvim-cmp",
    dependencies = { "hrsh7th/cmp-emoji", "David-Kunz/cmp-npm" },
    --@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.completion = { completeopt = vim.o.completeopt }
      opts.preselect = cmp.PreselectMode.None

      table.insert(opts.sources, { name = "emoji" })
      table.insert(opts.sources, 1, { name = "npm", keyword_length = 3, priority = 100, group_index = 1 })
      table.insert(opts.sources, { name = "zsh" })

      -- change copilot settings
      -- opts.sources = vim.tbl_filter(function(v)
      --   return not vim.tbl_contains({ "copilot" }, v.name)
      -- end, opts.sources)
      --
      -- table.insert(opts.sources, 1, { name = "copilot", priority = 99, group_index = 1 })

      -- change or add mappings
      -- opts.mapping = vim.tbl_filter(function(v)
      --   return not vim.equal(v, "<CR>")
      -- end, opts.mapping)
      --
      -- print(vim.inspect(opts.formatting))
      --
      opts.mapping["<CR>"] = vim.NIL
      opts.mapping["<Up>"] = vim.NIL
      opts.mapping["<Down>"] = vim.NIL
      opts.mapping["<TAB>"] = vim.NIL
      opts.mapping["<S-TAB>"] = vim.NIL
    end,
  },
}
