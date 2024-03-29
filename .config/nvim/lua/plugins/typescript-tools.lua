local settings = require("user.configuration").settings

return {
  "pmizio/typescript-tools.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  config = function()
    local baseDefinitionHandler = vim.lsp.handlers["textDocument/definition"]

    local filter = require("utils.filter").filter
    local filterReactDTS = require("utils.filterReactDTS").filterReactDTS
    local api = require("typescript-tools.api")

    local handlers = {
      ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        silent = true,
        border = settings.border_shape,
      }),
      ["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help,
        { border = settings.border_shape }
      ),
      ["textDocument/publishDiagnostics"] = api.filter_diagnostics({
        6133,
        6196,
      }),
      ["textDocument/definition"] = function(err, result, method, ...)
        if vim.tbl_islist(result) and #result > 1 then
          local filtered_result = filter(result, filterReactDTS)
          return baseDefinitionHandler(err, filtered_result, method, ...)
        end

        baseDefinitionHandler(err, result, method, ...)
      end,
    }

    require("typescript-tools").setup({
      -- figure out why this double errors on client and singles on _client
      on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        require("lsp-inlayhints").on_attach(client, bufnr)
      end,
      handlers = handlers,
      settings = {
        separate_diagnostic_server = true,
        composite_mode = "separate_diagnostic",
        publish_diagnostic_on = "insert_leave",
        -- https://github.com/microsoft/TypeScript/blob/v5.0.4/src/server/protocol.ts#L3439
        tsserver_file_preferences = {
          includeCompletionsForModuleExports = true,
          includeCompletionsForImportStatements = true,
          includeInlayParameterNameHints = "all",
          quotePreference = "auto",
        },
        tsserver_plugins = {
          "@styled/typescript-styled-plugin",
        }
      },
    })

    local colors = require("dracula").colors()
    vim.cmd("highlight LspInlayHint guifg=" .. colors.pink)
  end,
}
