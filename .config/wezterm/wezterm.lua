local wezterm = require("wezterm")
local config = {}

config.font = wezterm.font("Cascadia Code")
config.font_size = 14

config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true

config.keys = {
	-- split vertical
	{
		key = "s",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitPane { direction = "Right" },
	},
	-- split horizontal
	{
		key = "h",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitPane { direction = "Down" },
	},
	-- split horizontal (small)
	{
		key = "h",
		mods = "ALT|SHIFT",
		action = wezterm.action.SplitPane {
			direction = "Down",
			size = { Percent = 15 },
		},
	},
}

config.inactive_pane_hsb = {
	saturation = 0.8,
	brightness = 0.8,
}

if wezterm.target_triple:find("windows") ~= nil then
	config.default_prog = { "pwsh", "-nol" }
end

return config
