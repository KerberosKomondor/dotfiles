local keymap = vim.keymap.set

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP actions",
  callback = function(event)
    local opts = function(desc)
      return { buffer = event.bufnr, desc = desc }
    end

    -- Keybinds for lsp servers

    -- navigation
    keymap("n", "gr", "<cmd>Telescope lsp_references<cr>", opts('references'))
    keymap("n", "gD", vim.lsp.buf.declaration, opts('declaration'))
    keymap("n", "gd", "<cmd>Telescope lsp_definitions<cr>", opts('definition'))
    keymap("n", "gi", vim.lsp.buf.implementation, opts('implementation'))
    keymap("n", "<leader>D", "<cmd>Telescope lsp_type_definitions<cr>", opts('type definition'))
    keymap("n", "<C-k>K", vim.lsp.buf.signature_help, opts('signature help'))
    keymap("n", "K", vim.lsp.buf.hover, opts('hover'))
    keymap("n", "<F2>", vim.lsp.buf.rename, opts('rename'))
    keymap("n", "<leader>ci", "<cmd>Telescope lsp_incoming_calls<cr>", opts('incoming calls'))
    keymap("n", "<leader>co", "<cmd>Telescope lsp_outgoing_calls<cr>", opts('outgoing calls'))

    -- workspaces
    keymap("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts('add workspace folder'))
    keymap("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts('remove workspace folder'))
    keymap("n", "<space>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts('list workspace folders'))

    -- diagnostics
    keymap("n", "[d", vim.diagnostic.goto_next, opts('next diagnostic'))
    keymap("n", "]d", vim.diagnostic.goto_prev, opts('previous diagnostic'))
    keymap("n", "<leader>dd", "<cmd>Telescope diagnostics<cr>", opts('diagnostics'))
    keymap("n", "<space>ca", vim.lsp.buf.code_action, opts('code action'))
  end,
})
