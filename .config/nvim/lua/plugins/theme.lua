local _M = {
  "dracula/vim",
  name = 'theme',
  dependencies = {
    'stevearc/dressing.nvim',
    'norcalli/nvim-colorizer.lua',
    {
      "folke/noice.nvim",
      event = "VimEnter",
      dependencies = {
        "MunifTanjim/nui.nvim",
        "rcarriga/nvim-notify",
        "hrsh7th/nvim-cmp",
      }
    },
    'petertriho/nvim-scrollbar',
    'karb94/neoscroll.nvim',
  }
}

function _M.config()
  require 'dressing'.setup()
  require 'colorizer'.setup()
  require 'scrollbar'.setup()
  require 'neoscroll'.setup()
  require("noice").setup({
    lsp = {
      -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
      },
      ["cmp.entry.get_documentation"] = true,
    },
    -- you can enable a preset for easier configuration
    presets = {
      bottom_search = true, -- use a classic bottom cmdline for search
      command_palette = true, -- position the cmdline and popupmenu together
      long_message_to_split = true, -- long messages will be sent to a split
      inc_rename = false, -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = false, -- add a border to hover docs and signature help
    },
  })

  vim.cmd [[highlight clear]]
  vim.cmd [[ colorscheme dracula]]
  -- Set the color column (column 120) to purple
  vim.cmd [[highlight ColorColumn ctermbg=0 guibg=#6272a4]]

end

return _M
