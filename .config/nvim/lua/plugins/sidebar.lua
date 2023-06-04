local M = {
	"sidebar-nvim/sidebar.nvim",
}

function M.config()
	require("sidebar-nvim").setup({
		open = false,
	})
end

return M
