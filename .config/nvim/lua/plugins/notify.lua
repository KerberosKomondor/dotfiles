local _M = {
	"rcarriga/nvim-notify",
}

function _M.config()
	local ok, notify = pcall(require, "notify")
	if not ok then
		return
	end

	local colors = require("dracula").colors()
	notify.setup({
		stages = "fade_in_slide_out",
		background_colour = colors.purple,
	})

	-- This should be the last line
	vim.notify = notify
end

return _M
