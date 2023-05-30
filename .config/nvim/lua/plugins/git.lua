local _M = {
	name = "git",
	"lewis6991/gitsigns.nvim",
	dependencies = {
		"tpope/vim-fugitive",
		"nvim-lua/plenary.nvim",
	},
}

function _M.config()
	require("gitsigns").setup()
end

return _M
