local M = {
  name = 'jira',
  'KerberosKomondor/jira.nvim',
  --dir = '/home/appa/code/jira.nvim/',
}

function M.config()
  require 'jira'.setup()
end

return M
