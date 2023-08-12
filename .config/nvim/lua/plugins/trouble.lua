local _M = {
	"folke/trouble.nvim",
}

function _M.config()
	local ok, trouble = pcall(require, "trouble")
	if not ok then
		return
	end

	trouble.setup({})
end

return _M
