local wezterm = require 'wezterm'
return {
  font = wezterm.font('FiraCode Nerd Font'),
  font_size = 11,
  enable_tab_bar = false,
  color_scheme = 'Dracula (Official)',
  tab_bar_at_bottom = false,
  use_fancy_tab_bar = false,
  window_decorations = 'RESIZE',
  keys = {
    { key = "C", mods = "CTRL", action = wezterm.action { CopyTo = "ClipboardAndPrimarySelection" } }
  }
}
