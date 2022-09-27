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
