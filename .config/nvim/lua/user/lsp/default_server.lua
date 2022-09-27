local _M = {}

_M.setup = function(on_attach, capabilities, client)
  local lspconfig = require 'lspconfig'

  lspconfig[client].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    },
    capabilities = capabilities,
  }
end

return _M
