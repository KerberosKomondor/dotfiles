local _M = {
  "folke/which-key.nvim",
}

local opts = {
  mode = "n",
  prefix = "<leader>",
  buffer = nil,
  silent = true,
  noremap = true,
  nowait = true,
}

function _M.config()
  local ok, wk = pcall(require, "which-key")
  if not ok then
    return
  end

  local normalMappings = {
    b = { "<cmd>Telescope buffers<cr>", "Find Buffer" },
    -- open in current buffer's directory
    e = { "<cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<cr>", "File Browser" },
    E = { "<cmd>SidebarNvimToggle<cr>", "Sidebar" },
    f = { "<cmd>Telescope find_files<cr>", "Find File" },
    F = { "<cmd>Telescope live_grep<cr>", "Find File by Word" },
    g = {
      name = "Git",
      C = { "<cmd>Git close-branch<cr>", "Close branch" },
      R = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer" },
      c = { "<cmd>Git add -A | Git commit<cr>", "Commit" },
      d = { "<cmd>Git diff<cr>", "Diff" },
      g = { "<cmd>Git pull<CR>", "Pull" },
      l = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", "Blame" },
      p = { "<cmd>Git publish<cr>", "Publish" },
      P = { "<cmd>Git create-pull-request<cr>", "Pull Request" },
      s = { "<cmd>Git status<cr>", "Status" },
      u = { "<cmd>Git push<cr>", "Push" },
      v = {
        name = "Diffview",
        o = { "<cmd>DiffviewOpen<cr>", "Open" },
        c = { "<cmd>DiffviewClose<cr>", "Close" },
        h = { "<cmd>DiffviewFileHistory<cr>", "File History" },
        l = { "<cmd>DiffviewLog<cr>", "Log" },
        f = { "<cmd>DiffviewFocusFiles<cr>", "Focus Files" },
        r = { "<cmd>DiffviewRefresh<cr>", "Refresh" },
        t = { "<cmd>DiffviewToggleFiles<cr>", "Toggle Files" },
      },
    },
    l = {
      name = "Lsp",
      d = {
        "<cmd>Telescope lsp_document_diagnostics<cr>",
        "Document Diagnostics",
      },
      f = {
        "<cmd>lua vim.lsp.buf.format({timeout_ms=2000})<cr>",
        "Format",
      },
      w = {
        "<cmd>Telescope lsp_workspace_diagnostics<cr>",
        "Workspace Diagnostics",
      },
      i = { "<cmd>LspInfo<cr>", "Info" },
      I = { "<cmd>LspInstallInfo<cr>", "Installer Info" },
      l = { "<cmd>lua vim.lsp.codelens.run()<cr>", "CodeLens Action" },
      q = { "<cmd>lua vim.diagnostic.set_loclist()<cr>", "Quickfix" },
      s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
      S = {
        "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
        "Workspace Symbols",
      },
      t = {
        name = "Typescript",
        a = { "<cmd>TSToolsAddMissingImports<cr>", "Add Missing Imports" },
        f = { "<cmd>TSToolsFixAll<cr>", "Fix All" },
        g = { "<cmd>TSToolsGoToSourceDefinition<cr>", "Go to Source Definition" },
        o = { "<cmd>TSToolsOrganizeImports<cr>", "Organize Imports" },
        r = { "<cmd>TSToolsRenameFile<cr>", "Rename File" },
        u = { "<cmd>TSToolsRemoveUnused<cr>", "Remove Unused" },
      }
    },
    t = {
      e = {
        name = "Telescope",
        n = { "<cmd>Telescope notify<cr>", "Notify" },
        r = { "<cmd>Telescope reloader<cr>", "Reloader" },
      },
      t = {
        name = "Trouble",
        t = { "<cmd>TroubleToggle<cr>", "Toggle Trouble" },
        q = { "<cmd>Trouble quickfix<cr>", "Quickfix" },
        l = { "<cmd>Trouble loclist<cr>", "Loclist" },
        d = { "<cmd>Trouble document_diagnostics<cr>", "Document Diagnostics" },
        w = { "<cmd>Trouble workspace_diagnostics<cr>", "Workspace Diagnostics" },
        p = { "<cmd>Trouble lsp_references<cr>", "Lsp References" },
      },
      m = {
        name = "Markdown",
        a = { "<cmd>MarkdownPreview<cr>", "Start" },
        o = { "<cmd>MarkdownPreviewStop<cr>", "Stop" },
        t = { "<cmd>MarkdownPreviewToggle<cr>", "Toggle" },
      },
    },
  }

  wk.register(normalMappings, opts)
  wk.setup()
end

return _M
