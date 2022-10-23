local mason_ok, mason = pcall(require, 'mason') if not mason_ok then return end

local masonLsp_ok, masonLsp = pcall(require, 'mason-lspconfig') if not masonLsp_ok then return end

local servers = require('user.lsp').servers

mason.setup { ui = {
    icons = {
      package_installed = "✓", package_pending = "➜", package_uninstalled = "✗"
    }
  }
}

local on_attach = function(client, bufnr) local navic_ok, navic = pcall(require, 'nvim-navic') if navic_ok and 
  client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr) end

  local bufopts = { noremap=true, silent=true, buffer=bufnr } vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts) 
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts) vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts) 
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts) vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, 
  bufopts) vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts) vim.keymap.set('n', '<leader>wr', 
  vim.lsp.buf.remove_workspace_folder, bufopts) vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, bufopts) vim.keymap.set('n', '<leader>D', 
  vim.lsp.buf.type_definition, bufopts) vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts) vim.keymap.set('n', 
  '<leader>ca', vim.lsp.buf.code_action, bufopts) vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts) 
  vim.keymap.set('n', '<leader>o', vim.lsp.buf.formatting, bufopts) --select language server
end

local capabilities = vim.lsp.protocol.make_client_capabilities() capabilities = 
require("cmp_nvim_lsp").default_capabilities(capabilities)

masonLsp.setup { ensure_installed = servers, automatic_installation = true,
}

for _, server in ipairs(servers) do local ok, config = pcall(require, 'user.lsp.' .. server) if not ok then
    require('user.lsp.default_server').setup(on_attach, capabilities, server)
  else config.setup(on_attach, capabilities)
  end
end

local ok, null_ls = pcall(require, 'user.configs.null_ls') if not ok then return end

null_ls.setup(on_attach)
