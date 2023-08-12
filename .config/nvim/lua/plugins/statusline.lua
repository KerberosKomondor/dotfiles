local M = {
	"nvim-lualine/lualine.nvim",
}

function M.config()
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
			},
		},
	})
end

return M
