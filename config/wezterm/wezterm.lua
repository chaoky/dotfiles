local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.enable_wayland = false
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
config.colors = {
	background = "#282c34",
	foreground = "silver",
}
config.color_scheme = 'One Dark (Gogh)'
config.cursor_blink_rate = 500
config.animation_fps = 1

return config
