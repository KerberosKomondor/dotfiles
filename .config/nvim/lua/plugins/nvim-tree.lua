local _M = {
  'kyazdani42/nvim-tree.lua',
  dependencies = {
    'kyazdani42/nvim-web-devicons', -- optional, for file icons
  },
}

function _M.config()
  local ok, tree = pcall(require, 'nvim-tree')
  if not ok then return end

  tree.setup {
    sort_by = "case_sensitive",
    view = {
      adaptive_size = true,
    },
    update_focused_file = {
      enable = true,
      update_cwd = true,
      ignore_list = {},
    },
  }
end

return _M
