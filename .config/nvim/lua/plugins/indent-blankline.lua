return {
  "lukas-reineke/indent-blankline.nvim",
  main = 'ibl',
  opts = {},
  config = function()
    local highlight = {
      "RainbowRed",
      "RainbowYellow",
      "RainbowBlue",
      "RainbowOrange",
      "RainbowGreen",
      "RainbowViolet",
      "RainbowCyan",
    }

    local hooks = require "ibl.hooks"
    local colors = require("dracula").colors()

    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      -- vim.api.nvim_set_hl(0, "RainbowRed", { fg = colors.red })
      -- vim.api.nvim_set_hl(0, "RainbowYellow", { fg = colors.yellow })
      -- vim.api.nvim_set_hl(0, "RainbowBlue", { fg = colors.blue })
      -- vim.api.nvim_set_hl(0, "RainbowOrange", { fg = colors.orange })
      -- vim.api.nvim_set_hl(0, "RainbowGreen", { fg = colors.green })
      -- vim.api.nvim_set_hl(0, "RainbowViolet", { fg = colors.purple })
      -- vim.api.nvim_set_hl(0, "RainbowCyan", { fg = colors.cyan })

      vim.api.nvim_set_hl(0, "RainbowRed", { fg = colors.pink })
      vim.api.nvim_set_hl(0, "RainbowYellow", { fg = colors.purple })
      vim.api.nvim_set_hl(0, "RainbowBlue", { fg = colors.cyan })
      vim.api.nvim_set_hl(0, "RainbowOrange", { fg = colors.green })
      vim.api.nvim_set_hl(0, "RainbowGreen", { fg = colors.yellow })
      vim.api.nvim_set_hl(0, "RainbowViolet", { fg = colors.orange })
      vim.api.nvim_set_hl(0, "RainbowCyan", { fg = colors.red })
    end)
    require 'ibl'.setup { indent = { highlight = highlight } }
  end,
}
