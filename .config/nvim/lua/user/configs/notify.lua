local ok, notify = pcall(require, 'notify')
if not ok then return end

notify.setup {
  stages = 'fade_in_slide_out',
  background_colour = '#bd93f9',
}



-- This should be the last line
vim.notify = notify
