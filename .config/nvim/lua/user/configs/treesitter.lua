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
    'rust',
    'sql',
    'tsx',
    'typescript',
    'vim',
    'yaml',
  },
  auto_install = true,

}
