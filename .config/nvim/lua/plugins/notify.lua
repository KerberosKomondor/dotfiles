return {
  "rcarriga/nvim-notify",
  config = function()
    local colors = require("dracula").colors()

    local notify = require('notify')
    notify.setup({
      stages = "fade_in_slide_out",
      background_colour = colors.purple,
    })

    -- This should be the last line
    vim.notify = function(message, level, opts)
      return notify(message, level, opts)
    end
  end,
}
