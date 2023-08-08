local _M = {
	"Mofiqul/dracula.nvim",
	name = "theme",
	dependencies = {
		"stevearc/dressing.nvim",
		"norcalli/nvim-colorizer.lua",
		{
			"folke/noice.nvim",
			event = "VimEnter",
			dependencies = {
				"MunifTanjim/nui.nvim",
				"rcarriga/nvim-notify",
				"hrsh7th/nvim-cmp",
			},
		},
		"petertriho/nvim-scrollbar",
		"karb94/neoscroll.nvim",
		"m4xshen/smartcolumn.nvim",
	},
}

function _M.config()
	local colors = require("dracula").colors()
	require("dracula").setup({
		overrides = {
			PackageInfoOutdatedVersion = { fg = colors.red },
			PackageInfoUptodateVersion = { fg = colors.green },
		},
	})

	require("dressing").setup()
	require("colorizer").setup()
	require("scrollbar").setup()
	require("neoscroll").setup()
	require("smartcolumn").setup({
		colorcolumn = "120",
	})
	require("noice").setup({
		lsp = {
			-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
				["cmp.entry.get_documentation"] = true,
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
	})

	vim.cmd([[highlight clear]])
	vim.cmd([[colorscheme dracula]])

	-- Set the color column (column 120) to purple
	vim.cmd([[highlight ColorColumn ctermbg=0 guibg=#bd93f9]])

	-- fix modified inactive visible buffer text color
	vim.cmd([[highlight BufferCurrent guibg=#44475a]])
	vim.cmd([[highlight BufferInactive guibg=#282a36]])
	vim.cmd([[highlight BufferVisible guibg=#282a36]])

	vim.cmd([[highlight BufferCurrentMod guifg=#bd93f9]])
	vim.cmd([[highlight BufferInactiveMod guifg=#bd93f9]])
	vim.cmd([[highlight BufferVisibleMod guifg=#bd93f9]])

	vim.cmd([[highlight link BufferCurrentIcon BufferCurrent]])
	vim.cmd([[highlight link BufferInactiveIcon BufferInactive]])
	vim.cmd([[highlight link BufferVisibleIcon BufferVisible]])
end

return _M
