local function filenameFirst(_, path)
	local tail = vim.fs.basename(path)
	local parent = vim.fs.dirname(path)
	if parent == "." then
		return tail
	end
	return string.format("%s\t\t%s", tail, parent)
end

return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		-- or                              , branch = '0.1.x',
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{
				"<leader>f",
				"<cmd>Telescope find_files<cr>",
				desc = "Find Files",
			},
			{
				"<leader>F",
				"<cmd>Telescope live_grep<cr>",
				desc = "Find by Grep",
			},
			{
				"<leader>b",
				"<cmd>lua require('telescope.builtin').buffers()<cr>",
				desc = "Find Buffer",
			},
		},
		opts = function()
			local actions = require("telescope.actions")
			local action_layout = require("telescope.actions.layout")

			return {
				defaults = {
					mappings = {
						i = {
							["<esc>"] = actions.close, -- single esc to close
							["<C-u>"] = false, -- clear input
							["<M-p>"] = action_layout.toggle_preview, -- toggle preview screen
						},
					},
					prompt_prefix = " ",
					selection_caret = " ",
					path_display = { "smart" },
					dynamic_preview_title = true,
					winblend = 10,
					sorting_strategy = "descending",
					layout_strategy = "vertical",
					layout_config = {
						prompt_position = "bottom",
						height = 0.95,
					},
				},
				pickers = {
					find_files = {
						hidden = true,
						path_display = filenameFirst,
					},
					git_status = {
						path_display = filenameFirst,
					},
					buffers = {
						show_all_buffers = true,
						sort_lastused = true,
						theme = "dropdown",
						previewer = false,
						mappings = {
							i = {
								["<C-d>"] = actions.delete_buffer + actions.move_to_top,
							},
							n = {
								["d"] = actions.delete_buffer + actions.move_to_top,
							},
						},
					},
				},
				extensions = {
					fzf = {
						fuzzy = true,
						case_mode = "smart_case",
					},
					smart_open = {
						match_algorithm = "fzf",
						show_scores = true,
					},
				},
			}
		end,
	},
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "make",
		config = function()
			require("telescope").load_extension("fzf")
		end,
	},
}
