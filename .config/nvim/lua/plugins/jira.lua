local M = {
  name = 'jira',
  dir = '/home/appa/code/jira.nvim/',
}

function M.config()
  require 'jira'.setup()
end

return M
