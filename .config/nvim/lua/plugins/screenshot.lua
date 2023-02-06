local M = {
  'krivahtoo/silicon.nvim',
  name = 'screenshot',
  build = './install.sh build',
}

function M.config()
  require 'silicon'.setup({
    theme = 'Dracula',
  })
end

return M
