return {
	"dmmulroy/tsc.nvim",
	lazy = false,
	cmd = "TSC",
	enabled = false,
	config = function()
		require("tsc").setup({
			auto_open_qflist = true,
			auto_close_qflist = true,
			auto_focus_qflist = false,
			auto_start_watch_mode = true,
			flags = {
				watch = true,
			},
			formatters = {
				filename = function(filename)
					return vim.fn.pathshorten(filename)
				end,
				text = function(text)
					return string.gsub(text, "error TS", "TS")
				end,
			},
		})
	end,
}
