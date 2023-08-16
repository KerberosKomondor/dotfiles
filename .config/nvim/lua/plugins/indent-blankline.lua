local M = {
  "lukas-reineke/indent-blankline.nvim",
}

function M.config()
  local colors = require'dracula'.colors()

  vim.cmd('highlight IndentBlanklineIndent1 guifg=' .. colors.purple .. ' gui=nocombine')
  vim.cmd('highlight IndentBlanklineIndent2 guifg=' .. colors.cyan .. ' gui=nocombine')
  vim.cmd('highlight IndentBlanklineIndent3 guifg=' .. colors.yellow .. ' gui=nocombine')
  vim.cmd('highlight IndentBlanklineIndent4 guifg=' .. colors.pink .. ' gui=nocombine')
  vim.cmd('highlight IndentBlanklineIndent5 guifg=' .. colors.orange .. ' gui=nocombine')
  vim.cmd('highlight IndentBlanklineIndent6 guifg=' .. colors.red .. ' gui=nocombine')

  vim.opt.list = true
  vim.opt.listchars:append("space:⋅")
  vim.opt.listchars:append("eol:↴")

  require("indent_blankline").setup({
    space_char_blankline = " ",
    char_highlight_list = {
      "IndentBlanklineIndent1",
      "IndentBlanklineIndent2",
      "IndentBlanklineIndent3",
      "IndentBlanklineIndent4",
      "IndentBlanklineIndent5",
      "IndentBlanklineIndent6",
    },
  })
end

return M
