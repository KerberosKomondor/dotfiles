---@diagnostic disable-next-line: unused-local, unused-function
local is_public_project = function()
	local current_dir = vim.fn.getcwd()
	local home_dir = os.getenv("HOME") or os.getenv("USERPROFILE")
	local repos_path = home_dir .. "/code/"
	local is_work = string.find(current_dir, repos_path) == 1

	if is_work then
		return false
	else
		return true
	end
end

return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
	dependencies = {
		"zbirenbaum/copilot-cmp",
		after = { "copilot.lua" },
	},
	enabled = true,
	config = function()
		require("copilot").setup({
			panel = {
				enabled = true,
				auto_refresh = true,
			},
			suggestion = {
				enabled = true,
				-- use the built-in keymapping for "accept" (<M-l>)
				auto_trigger = true,
				accept = false, -- disable built-in keymapping
			},
		})

		require("copilot_cmp").setup()
		local colors = require("dracula").colors()
		vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = colors.green })
	end,
}
