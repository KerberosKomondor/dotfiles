local function filenameFirst(_, path)
  local tail = vim.fs.basename(path)
  local parent = vim.fs.dirname(path)
  if parent == "." then
    return tail
  end
  return string.format("%s\t\t%s", tail, parent)
end

return {
  { "tsakirist/telescope-lazy.nvim"
 },
  {
    "nvim-telescope/telescope.nvim",
    opts = function()
      local actions = require("telescope.actions")
      local action_layout = require("telescope.actions.layout")

      require("telescope").load_extension("package_info")
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
          sorting_strategy = "descending",
          layout_strategy = "vertical",
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
          lazy = {
            theme = "ivy",
          },
          package_info = {
            theme = "ivy",
          },
        },
      }
    end,
  },
}
