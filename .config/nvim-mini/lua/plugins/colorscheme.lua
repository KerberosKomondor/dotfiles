return {
	{
		"Mofiqul/dracula.nvim",
		opts = function(_, opts)
			local colors = require("dracula").colors()
			opts.overrides = opts.overrides or {}

			vim.list_extend(opts.overrides, {
				PackageInfoOutdatedVersion = { fg = colors.red },
				PackageInfoUptodateVersion = { fg = colors.green },
			})
		end,
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			lsp = {
				-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
				},
			},
			-- you can enable a preset for easier configuration
			presets = {
				bottom_search = true, -- use a classic bottom cmdline for search
				command_palette = true, -- position the cmdline and popupmenu together
				long_message_to_split = true, -- long messages will be sent to a split
				inc_rename = false, -- enables an input dialog for inc-rename.nvim
				lsp_doc_border = false, -- add a border to hover docs and signature help
			},
		},
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			"rcarriga/nvim-notify",
		},
	},
	{
		"m4xshen/smartcolumn.nvim",
		opts = function()
			-- Set the color column (column 120) to purple
			vim.cmd([[highlight ColorColumn ctermbg=0 guibg=#bd93f9]])

			return {
				colorcolumn = "121",
			}
		end,
	},
}
