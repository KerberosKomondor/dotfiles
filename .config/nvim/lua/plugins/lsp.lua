local M = {
  name = "lsp",
  "VonHeikemen/lsp-zero.nvim",
  dependencies = {
    -- LSP Support
    { "neovim/nvim-lspconfig" },
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "folke/neodev.nvim" },
    { "jose-elias-alvarez/null-ls.nvim" },

    -- Autocompletion
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-nvim-lua" },
    { "David-Kunz/cmp-npm" },
    {
      "KerberosKomondor/cmp-jira.nvim",
      --dir = '/home/appa/code/cmp-jira.nvim/',
    },

    -- Snippets - disabled for now
    {
      'L3MON4D3/LuaSnip',
      build = 'make install_jsregexp'
    },
    { 'saadparwaiz1/cmp_luasnip' },
    { "rafamadriz/friendly-snippets" },

    -- Display
    { "onsails/lspkind.nvim" },
    { "styled-components/vim-styled-components" },
    { "glepnir/lspsaga.nvim" },
  },
}

function M.config()
  local keymap = vim.keymap.set

  -- Needs to be before lsp is setup
  require("neodev").setup()
  ----------------------------------

  local lsp = require("lsp-zero")
  local lspconfig = require("lspconfig")

  lsp.extend_lspconfig({
    set_lsp_keymaps = false,
    on_attach = function(_, bufnr)
      local opts = { buffer = bufnr }

      -- Keybinds for lsp servers
      -- LSP finder - Find the symbol's definition
      -- If there is no definition, it will instead be hidden
      -- When you use an action in finder like "open vsplit",
      -- you can use <C-t> to jump back
      keymap("n", "gh", "<cmd>Lspsaga lsp_finder<CR>")

      -- Code action
      keymap({ "n", "v" }, "<leader>ca", "<cmd>Lspsaga code_action<CR>")

      -- Rename all occurrences of the hovered word for the entire file
      keymap("n", "gr", "<cmd>Lspsaga rename<CR>")

      -- Rename all occurrences of the hovered word for the selected files
      keymap("n", "gr", "<cmd>Lspsaga rename ++project<CR>")

      -- Peek definition
      -- You can edit the file containing the definition in the floating window
      -- It also supports open/vsplit/etc operations, do refer to "definition_action_keys"
      -- It also supports tagstack
      -- Use <C-t> to jump back
      keymap("n", "gd", "<cmd>Lspsaga peek_definition<CR>")

      -- Go to definition
      keymap("n", "gd", "<cmd>Lspsaga goto_definition<CR>")

      -- Peek type definition
      -- You can edit the file containing the type definition in the floating window
      -- It also supports open/vsplit/etc operations, do refer to "definition_action_keys"
      -- It also supports tagstack
      -- Use <C-t> to jump back
      keymap("n", "gt", "<cmd>Lspsaga peek_type_definition<CR>")

      -- Go to type definition
      keymap("n", "gt", "<cmd>Lspsaga goto_type_definition<CR>")


      -- Show line diagnostics
      -- You can pass argument ++unfocus to
      -- unfocus the show_line_diagnostics floating window
      keymap("n", "<leader>sl", "<cmd>Lspsaga show_line_diagnostics<CR>")

      -- Show cursor diagnostics
      -- Like show_line_diagnostics, it supports passing the ++unfocus argument
      keymap("n", "<leader>sc", "<cmd>Lspsaga show_cursor_diagnostics<CR>")

      -- Show buffer diagnostics
      keymap("n", "<leader>sb", "<cmd>Lspsaga show_buf_diagnostics<CR>")

      -- Diagnostic jump
      -- You can use <C-o> to jump back to your previous location
      keymap("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>")
      keymap("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>")

      -- Diagnostic jump with filters such as only jumping to an error
      keymap("n", "[E", function()
        require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
      end)
      keymap("n", "]E", function()
        require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
      end)

      -- Toggle outline
      keymap("n", "<leader>o", "<cmd>Lspsaga outline<CR>")

      -- Hover Doc
      -- If there is no hover doc,
      -- there will be a notification stating that
      -- there is no information available.
      -- To disable it just use ":Lspsaga hover_doc ++quiet"
      -- Pressing the key twice will enter the hover window
      keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>")

      -- If you want to keep the hover window in the top right hand corner,
      -- you can pass the ++keep argument
      -- Note that if you use hover with ++keep, pressing this key again will
      -- close the hover window. If you want to jump to the hover window
      -- you should use the wincmd command "<C-w>w"
      keymap("n", "K", "<cmd>Lspsaga hover_doc ++keep<CR>")

      -- Call hierarchy
      keymap("n", "<Leader>ci", "<cmd>Lspsaga incoming_calls<CR>")
      keymap("n", "<Leader>co", "<cmd>Lspsaga outgoing_calls<CR>")

      -- Floating terminal
      keymap({ "n", "t" }, "<A-d>", "<cmd>Lspsaga term_toggle<CR>")
    end,
  })

  require("mason").setup()
  require("mason-lspconfig").setup({
    ensure_installed = {
      "tsserver",
      "eslint",
      "lua_ls",
    },
  })

  require("mason-lspconfig").setup_handlers({
    function(server_name)
      lspconfig[server_name].setup({})
    end,
    ["lua_ls"] = function()
      lspconfig.lua_ls.setup({
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
          },
        },
      })
    end,
  })

  require('lspsaga').setup({})

  --[[
  --      COMPLETION
  --]]
  local cmp_settings = require("user.cmp")

  -- Blend settings with default lsp-zero settings
  local cmp_config = require("lsp-zero").defaults.cmp_config(cmp_settings.blended_config)

  -- Override entire sections of cmp config
  cmp_config.mapping = cmp_settings.mapping
  cmp_config.sources = cmp_settings.sources

  require("cmp").setup(cmp_config)

  local ls = require 'luasnip'
  local types = require 'luasnip.util.types'

  ls.config.set_config {
    history = true,
    updateevents = "TextChanged, TextChangedI",
    enable_autosnippets = true,
  }

  --[[
  --      DIAGNOSTICS
  --]]
  lsp.set_sign_icons()
  vim.diagnostic.config(lsp.defaults.diagnostics({}))

  --[[
  --      NULL_LS
  --]]
  local null_ls = require("null-ls")
  local null_opts = lsp.build_options("null-ls", {})

  local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

  null_ls.setup({
    on_attach = function(client, bufnr)
      if client.supports_method("textDocument/formatting") then
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = augroup,
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({ bufnr = bufnr })
          end,
        })
      end

      return null_opts.on_attach
    end,
    sources = {
      null_ls.builtins.formatting.eslint_d,
      null_ls.builtins.formatting.stylua,
    },
  })

  lsp.nvim_workspace()
end

return M
