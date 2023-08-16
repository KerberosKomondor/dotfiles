local settings = require("user.configuration").settings

local M = {
  "pmizio/typescript-tools.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
}

function M.config()
  local baseDefinitionHandler = vim.lsp.handlers["textDocument/definition"]

  local filter = require("utils.filter").filter
  local filterReactDTS = require("utils.filterReactDTS").filterReactDTS

  local handlers = {
    ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
      silent = true,
      border = settings.border_shape,
    }),
    ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = settings.border_shape }),
    ["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics,
      { virtual_text = settings.show_diagnostic_virtual_text }
    ),
    ["textDocument/definition"] = function(err, result, method, ...)
      if vim.tbl_islist(result) and #result > 1 then
        local filtered_result = filter(result, filterReactDTS)
        return baseDefinitionHandler(err, filtered_result, method, ...)
      end

      baseDefinitionHandler(err, result, method, ...)
    end,
  }

  require("typescript-tools").setup({
    on_attach = function(client, bufnr)
      print(client.name .. " was attached")
      if client.server_capabilities.documentFormattingProvider then
        vim.cmd([[
        augroup lsp_formatting
        autocmd!
          autocmd BufWritePre <buffer> :lua vim.lsp.buf.format()
        augroup END
      ]])
      end
      if vim.fn.has("nvim-0.10") then
        -- Enable inlay hints
        vim.lsp.inlay_hint(bufnr, true)
      end
    end,
    handlers = handlers,
    settings = {
      separate_diagnostic_server = true,
      tsserver_file_preferences = {
        includeInlayParameterNameHints = "all",
        includeCompletionsForModuleExports = true,
        quotePreference = "auto",
      },
    },
  })

  local colors = require("dracula").colors()
  vim.cmd("highlight LspInlayHint guifg=" .. colors.pink)
end

return M
