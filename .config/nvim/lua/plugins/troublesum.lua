local M = {
	"ivanjermakov/troublesum.nvim",
}

function M.config()
	require("troublesum").setup()
end

return M
