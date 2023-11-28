return {
  'dmmulroy/tsc.nvim',
  lazy = false,
  cmd = "TSC",
  config = function()
    require('tsc').setup({
      auto_open_qflist = true,
      auto_close_qflist = true,
      auto_focus_qflist = false,
      auto_start_watch_mode = true,
      flags = {
        watch = true,
      },
    })
  end,
}
