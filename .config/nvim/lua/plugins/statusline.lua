local _M = {
	"nvim-lualine/lualine.nvim",
	name = "lines",
}

function _M.config()
	require("lualine").setup({
		theme = "dracula",
		sections = {
			lualine_x = {
				{
					require("lazy.status").updates,
					cond = require("lazy.status").has_updates,
					color = { fg = "#BD93F9" },
				},
			},
		},
	})
end

return _M
