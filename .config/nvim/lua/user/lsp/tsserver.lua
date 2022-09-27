local _M = {}

_M.setup = function(on_attach, capabilities)
  local lspconfig = require "lspconfig"
  lspconfig.tsserver.setup {
    on_attach = function(client, bufnr)
      on_attach(client, bufnr)
    end,
    flags = {
      debounce_text_changes = 150,
    },
    capabilities = capabilities,
  }
end

return _M
