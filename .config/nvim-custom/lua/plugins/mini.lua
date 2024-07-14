-- https://github.com/echasnovski/mini.nvim/tree/main/readmes
return {
	"echasnovski/mini.nvim",
	dependencies = {
		"JoosepAlviste/nvim-ts-context-commentstring",
		"kyazdani42/nvim-web-devicons", -- optional, for file icons
	},
	version = false,
	config = function()
		-- require("mini.ai").setup()

		-- may need to run 'git config --system core.longpaths true' on windows
		require("mini.align").setup()

		require("mini.basics").setup()

		require("mini.bracketed").setup()

		require("mini.bufremove").setup()

		require("mini.comment").setup({
			options = {
				custom_commentstring = function()
					return require("ts_context_commentstring.internal").calculate_commentstring()
						or vim.bo.commentstring
				end,
			},
		})

		require("mini.cursorword").setup()

		require("mini.files").setup()

		require("mini.move").setup()

		require("mini.operators").setup()

		require("mini.pairs").setup()

		require("mini.sessions").setup()

		require("mini.splitjoin").setup()

		require("mini.surround").setup()
	end,
}
