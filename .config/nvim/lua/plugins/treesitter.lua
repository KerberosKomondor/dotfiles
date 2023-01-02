local _M = {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
}

function _M.config()
  local ok, treesitter = pcall(require, 'nvim-treesitter.configs')
  if not ok then return end

  treesitter.setup {
    ensure_installed = {
      'bash',
      'c_sharp',
      'go',
      'graphql',
      'html',
      'javascript',
      'json',
      'lua',
      'markdown',
      'markdown_inline',
      'regex',
      'rust',
      'sql',
      'tsx',
      'typescript',
      'vim',
      'yaml',
    },
    auto_install = true,
  }
end

return _M
