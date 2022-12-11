local ok, telescope = pcall(require, 'telescope')
if not ok then return end

local actions = require('telescope.actions')
local action_layout = require('telescope.actions.layout')

local utils = require('user.utils')

local hasNotify = pcall(require, 'notify')

telescope.setup {
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = actions.close, -- single esc to close
        ["<C-u>"] = false, -- clear input
        ["<C-p>"] = action_layout.toggle_preview, -- toggle preview screen
      },
    },
  },
  pickers = {
    find_files = {
      hidden = true,
    },
  },
}

local hasFzf = pcall(require, 'telescope-fzf-native')--'fzf-lib')
if (hasFzf) then
  telescope.load_extension('fzf')
else
  utils.error('fzf has not been installed')
end

if (hasNotify) then
  telescope.load_extension('notify')
end
