local wezterm = require 'wezterm'
return {
  font = wezterm.font('FiraCode Nerd Font'),
  font_size = 13,
  enable_tab_bar = false,
  color_scheme = 'Dracula (Official)',
  tab_bar_at_bottom = false,
  use_fancy_tab_bar = false,
  window_decorations = 'RESIZE',
  keys = {
    { key = "c", mods="CTRL", action=wezterm.action{CopyTo="ClipboardAndPrimarySelection"}}
  }
}
