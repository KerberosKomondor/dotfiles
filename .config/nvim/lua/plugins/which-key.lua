local _M = {
  'folke/which-key.nvim',
  dependencies = {
    'mrjones2014/legendary.nvim',
  },
}

local opts = {
  mode = "n",
  prefix = "<leader>",
  buffer = nil,
  silent = true,
  noremap = true,
  nowait = true
}


function _M.config()
  local ok, wk = pcall(require, 'which-key')
  if not ok then return end

  local mappings = {
    b = { "<cmd>Telescope buffers<cr>", "Find Buffer" },
    e = { "<cmd>NvimTreeToggle<cr>", "File Browser" },
    f = { "<cmd>Telescope find_files<cr>", "Find File" },
    F = { "<cmd>Telescope live_grep<cr>", "Find File by Word" },
    ["]"] = { "<cmd>bnext<cr>", "Next Buffer" },
    ["["] = { "<cmd>bprevious<cr>", "Previous Buffer" },
    c = { "<cmd>bdelete<cr>", "Close Buffer" },
    --    g = {
    --      name = "Git",
    --      g = { "<cmd>!git pull<CR>", "Pull" },
    --      l = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", "Blame" },
    --      R = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer" },
    --      o = { "<cmd>Telescope git_status<cr>", "Open changed file" },
    --      b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
    --      c = { "<cmd>Telescope git_commits<cr>", "Checkout commit" },
    --      C = { "<cmd>!git close-branch<cr>", "Close branch" },
    --      d = { "<cmd>Gitsigns diffthis HEAD<cr>", "Diff" },
    --      t = { "<cmd>Neogit<cr>", "Commit" },
    --      p = { "<cmd>!git publish<cr>", "Publish" },
    --      P = { "<cmd>!git create-pull-request<cr>", "Pull Request" },
    --      u = { "<cmd>!git push<cr>", "Push" },
    --      B = { "<cmd>lua require('ujtils').createBranch()<cr>", "Branch" }
    --    },
    l = {
      name = "Lsp",
      a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
      d = {
        "<cmd>Telescope lsp_document_diagnostics<cr>",
        "Document Diagnostics"
      }, w = {
        "<cmd>Telescope lsp_workspace_diagnostics<cr>",
        "Workspace Diagnostics"
      },
      f = { "<cmd>lua vim.lsp.buf.format()<cr>", "Format" },
      i = { "<cmd>LspInfo<cr>", "Info" },
      I = { "<cmd>LspInstallInfo<cr>", "Installer Info" },
      j = { "<cmd>lua vim.diagnostic.goto_next()<CR>", "Next Diagnostic" },
      k = { "<cmd>lua vim.diagnostic.goto_prev()<cr>", "Prev Diagnostic" },
      l = { "<cmd>lua vim.lsp.codelens.run()<cr>", "CodeLens Action" },
      q = { "<cmd>lua vim.diagnostic.set_loclist()<cr>", "Quickfix" },
      r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
      s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
      S = {
        "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
        "Workspace Symbols"
      },
    },
    t = {
      e = {
        name = 'Telescope',
        n = { "<cmd>Telescope notify<cr>", "Notify" },
        r = { "<cmd>Telescope reloader<cr>", "Reloader" },
      },
      t = {
        name = 'Trouble',
        t = { "<cmd>TroubleToggle<cr>", "Toggle Trouble" },
        q = { "<cmd>Trouble quickfix<cr>", "Quickfix" },
        l = { "<cmd>Trouble loclist<cr>", "Loclist" },
        d = { "<cmd>Trouble document_diagnostics<cr>", "Document Diagnostics" },
        w = { "<cmd>Trouble workspace_diagnostics<cr>", "Workspace Diagnostics" },
        p = { "<cmd>Trouble lsp_references<cr>", "Lsp References" },
      },
      m = {
        name = 'Markdown',
        a = { "<cmd>MarkdownPreview<cr>", "Start" },
        o = { "<cmd>MarkdownPreviewStop<cr>", "Stop" },
        t = { "<cmd>MarkdownPreviewToggle<cr>", "Toggle" },
      },
    },
  }

  -- legendary needs to be first
  require('legendary').setup({
    keymaps = {
      { "<C-p>", "<cmd>Legendary<cr>", description = "Legendary", mode = { "n", "i", "x" } },
    },
    which_key = {
      auto_register = true,
      mappings = mappings,
    },
  })

  wk.register(mappings, opts)
  wk.setup()

end

return _M
