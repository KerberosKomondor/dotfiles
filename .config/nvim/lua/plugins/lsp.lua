local settings = require("user.configuration").settings

return {
	name = "lsp",
	"neovim/nvim-lspconfig",
	dependencies = {
		-- LSP Support
		{ "williamboman/mason.nvim" },
		{ "williamboman/mason-lspconfig.nvim" },
		{ "jay-babu/mason-nvim-dap.nvim" },
		{ "folke/neodev.nvim" },
		"lvimuser/lsp-inlayhints.nvim",

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
		{
			"kevinhwang91/nvim-ufo",
			dependencies = "kevinhwang91/promise-async",
		},
		{
			"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
			opts = {},
		},
	},
	config = function()
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
				"yamlls",
			},
			automatic_installation = true,
		})

		local lspconfig = require("lspconfig")

		vim.diagnostic.config({ virtual_text = settings.show_diagnostic_virtual_text })

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
			require("lsp-inlayhints").on_attach(client, bufnr)
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

		lspconfig.yamlls.setup({
			capabilities = capabilities,
			handlers = handlers,
			on_attach = require("servers.yamlls").on_attach,
			settings = require("servers.yamlls").settings,
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

		lspconfig.emmet_language_server.setup({
			capabilities = capabilities,
			handlers = handlers,
			on_attach = on_attach,
			settings = require("servers.emmet").settings,
		})

		for _, server in ipairs({ "bashls", "graphql", "html" }) do
			lspconfig[server].setup({
				on_attach = on_attach,
				capabilities = capabilities,
				handlers = handlers,
			})
		end

		local cmp = require("cmp")
		cmp.setup(require("user.completion").config)

		require("ufo").setup({
			open_fold_hl_timeout = 400,
			enable_get_fold_virt_text = false,
			preview = {
				win_config = {
					border = require("user.configuration").settings.border_shape,
					winblend = 12,
					winhighlight = "Normal:Normal",
					maxheight = 20,
				},
			},
			fold_virt_text_handler = ufo_config_handler,
			---@diagnostic disable-next-line: assign-type-mismatch
			close_fold_kinds_for_ft = { default = { "imports", "comment" } },
		})
	end,
}
