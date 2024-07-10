return {
  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      print(vim.inspect(opts))
      -- opts.icons.kinds["Npm"] = " "
    end,
  },
}
