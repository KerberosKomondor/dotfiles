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
	enabled = false,
	config = function()
		require("copilot").setup({
			panel = {
				enabled = false,
			},
			suggestion = {
				enabled = false,
			},
		})

		require("copilot_cmp").setup()
	end,
}
