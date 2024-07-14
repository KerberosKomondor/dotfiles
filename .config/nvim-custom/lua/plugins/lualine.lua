return {
	"nvim-lualine/lualine.nvim",
	config = function()
		local colors = require("dracula").colors()

		require("lualine").setup({
			theme = "dracula-nvim",
			sections = {
				lualine_x = {
					{
						require("lazy.status").updates,
						cond = require("lazy.status").has_updates,
						color = { fg = colors.purple },
					},
					{
						function()
							return require("package-info").get_status()
						end,
						color = { fg = colors.purple },
					},
				},
			},
		})
	end,
}
