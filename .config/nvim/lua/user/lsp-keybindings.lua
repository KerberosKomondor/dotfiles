local keymap = vim.keymap.set

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP actions",
  callback = function(event)
    local opts = { buffer = event.bufnr }

    -- Keybinds for lsp servers

    -- navigation
    keymap("n", "gr", vim.lsp.buf.references, opts)
    keymap("n", "gD", vim.lsp.buf.declaration, opts)
    keymap("n", "gd", vim.lsp.buf.definition, opts)
    keymap("n", "gi", vim.lsp.buf.implementation, opts)
    keymap("n", "gr", vim.lsp.buf.references, opts)
    keymap("n", "<leader>D", vim.lsp.buf.type_definition, opts)
    keymap("n", "<C-k>", vim.lsp.buf.signature_help, opts)
    keymap("n", "K", vim.lsp.buf.hover, opts)
    keymap("n", "<F2>", vim.lsp.buf.rename, opts)
    keymap("n", "<leader>ci", vim.lsp.buf.incoming_calls, opts)
    keymap("n", "<leader>co", vim.lsp.buf.outgoing_calls, opts)

    -- workspaces
    keymap("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
    keymap("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
    keymap("n", "<space>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)

    -- diagnostics
    keymap("n", "[d", vim.diagnostic.goto_next, opts)
    keymap("n", "]d", vim.diagnostic.goto_prev, opts)
    keymap("n", "<leader>do", vim.diagnostic.goto_prev, opts)
    keymap("n", "<leader>dd", "<cmd>Telescope diagnostics<cr>", opts)
    keymap("n", "<space>ca", vim.lsp.buf.code_action, opts)
  end,
})
