local function filenameFirst(_, path)
  local tail = vim.fs.basename(path)
  local parent = vim.fs.dirname(path)
  if parent == "." then return tail end
  return string.format("%s\t\t%s", tail, parent)
end

return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "BurntSushi/ripgrep",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
    "rcarriga/nvim-notify",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local action_layout = require("telescope.actions.layout")

    local hasNotify = pcall(require, "notify")

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "TelescopeResults",
      callback = function(ctx)
        vim.api.nvim_buf_call(ctx.buf, function()
          vim.fn.matchadd("TelescopeParent", "\t\t.*$")
          vim.api.nvim_set_hl(0, "TelescopeParent", { link = "Comment" })
        end)
      end,
    })

    telescope.setup({
      defaults = {
        mappings = {
          i = {
            ["<esc>"] = actions.close,                -- single esc to close
            ["<C-u>"] = false,                        -- clear input
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
            }

          }
        }
      },
      extensions = {
        fzf = {
          fuzzy = true,
          case_mode = "smart_case",
        },
      },
    })

    telescope.load_extension("fzf")

    if hasNotify then
      telescope.load_extension("notify")
    end
  end,
}
