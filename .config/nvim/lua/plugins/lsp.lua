local settings = require("user.configuration").settings

local M = {
	name = "lsp",
	"neovim/nvim-lspconfig",
	dependencies = {
		-- LSP Support
		{ "williamboman/mason.nvim" },
		{ "williamboman/mason-lspconfig.nvim" },
		{ "jay-babu/mason-nvim-dap.nvim" },
		{ "folke/neodev.nvim" },

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
			"L3MON4D3/LuaSnip",
			-- Comment if fails.  Ensure jsregexp-luarock is install
			-- build = 'make install_jsregexp'
		},
		{ "saadparwaiz1/cmp_luasnip" },
		{ "rafamadriz/friendly-snippets" },

		-- Display
		{ "onsails/lspkind.nvim" },
		{ "glepnir/lspsaga.nvim" },
		{
			"kevinhwang91/nvim-ufo",
			dependencies = "kevinhwang91/promise-async",
		},
	},
}

function M.config()
	-- needs setup before lspconfig
	require("neodev").setup()

	-- Setup installer & lsp configs
	local mason_ok, mason = pcall(require, "mason")
	local mason_lsp_ok, mason_lsp = pcall(require, "mason-lspconfig")
	local ufo_config_handler = require("user.nvim-ufo").handler

	if not mason_ok or not mason_lsp_ok then
		return
	end

	mason.setup({
		ui = {
			border = settings.border_shape,
			-- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
		},
	})

	mason_lsp.setup({
		-- A list of servers to automatically install if they're not already installed
		ensure_installed = {
			"bashls",
			"cssls",
			"eslint",
			"graphql",
			"html",
			"jsonls",
			"lua_ls",
		},
		-- Whether servers that are set up (via lspconfig) should be automatically installed if they're not already installed.
		-- This setting has no relation with the `ensure_installed` setting.
		-- Can either be:
		--   - false: Servers are not automatically installed.
		--   - true: All servers set up via lspconfig are automatically installed.
		--   - { exclude: string[] }: All servers set up via lspconfig, except the ones provided in the list, are automatically installed.
		--       Example: automatic_installation = { exclude = { "rust_analyzer", "solargraph" } }
		automatic_installation = true,
	})

	local lspconfig = require("lspconfig")

	local handlers = {
		["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
			silent = true,
			border = settings.border_shape,
		}),
		["textDocument/signatureHelp"] = vim.lsp.with(
			vim.lsp.handlers.signature_help,
			{ border = settings.border_shape }
		),
		["textDocument/publishDiagnostics"] = vim.lsp.with(
			vim.lsp.diagnostic.on_publish_diagnostics,
			{ virtual_text = settings.show_diagnostic_virtual_text }
		),
	}

	local function on_attach(client, bufnr)
		-- set up buffer keymaps, etc.
	end

	local capabilities = require("cmp_nvim_lsp").default_capabilities()

	capabilities.textDocument.foldingRange = {
		dynamicRegistration = false,
		lineFoldingOnly = true,
	}

	-- Order matters

	lspconfig.cssls.setup({
		capabilities = capabilities,
		handlers = handlers,
		on_attach = require("servers.cssls").on_attach,
		settings = require("servers.cssls").settings,
	})

	lspconfig.eslint.setup({
		capabilities = capabilities,
		handlers = handlers,
		on_attach = require("servers.eslint").on_attach,
		settings = require("servers.eslint").settings,
	})

	lspconfig.jsonls.setup({
		capabilities = capabilities,
		handlers = handlers,
		on_attach = on_attach,
		settings = require("servers.jsonls").settings,
	})

	lspconfig.lua_ls.setup({
		capabilities = capabilities,
		handlers = handlers,
		on_attach = on_attach,
		settings = require("servers.lua_ls").settings,
	})

	for _, server in ipairs({ "bashls", "emmet_ls", "graphql", "html" }) do
		lspconfig[server].setup({
			on_attach = on_attach,
			capabilities = capabilities,
			handlers = handlers,
		})
	end

	local cmp = require("cmp")
	cmp.setup(require("user.completion").config)

	require("ufo").setup({
		fold_virt_text_handler = ufo_config_handler,
		close_fold_kinds = { "imports" },
	})

	require("lspsaga").setup({})
end

return M
