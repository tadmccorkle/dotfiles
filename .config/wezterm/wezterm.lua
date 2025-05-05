local wezterm = require "wezterm"
local act = wezterm.action

wezterm.on("gui-startup", function(_)
	local _, _, window = wezterm.mux.spawn_window {}
	window:gui_window():maximize()
end)

wezterm.on("update-right-status", function(window, _)
	local status = ""
	if window:leader_is_active() then
		status = "LEADER"
	else
		local name = window:active_key_table()
		if name then
			status = name
		end
	end
	window:set_right_status(status)
end)

local config = {}

local theme = wezterm.color.get_default_colors()
theme.background = "#000000"
theme.ansi = {
	"#000000", -- black
	"#CC0000", -- red
	"#4E9A06", -- green
	"#C19C00", -- yellow
	"#3465A4", -- blue
	"#75507B", -- purple
	"#06989A", -- cyan
	"#D3D7CF", -- white
}
theme.brights = {
	"#555753", -- black
	"#E74856", -- red
	"#16C60C", -- green
	"#FCE94F", -- yellow
	"#729FCF", -- blue
	"#AD7FA8", -- purple
	"#61D6D6", -- cyan
	"#EEEEEC", -- white
}
theme.compose_cursor = "orange"

config.color_schemes = { ["tad default"] = theme }
config.color_scheme = "tad default"

config.inactive_pane_hsb = {
	saturation = 0.8,
	brightness = 0.8,
}

config.font = wezterm.font "Cascadia Code"
config.font_size = 12

config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true

config.leader = { key = "Space", mods = "CTRL|SHIFT", timeout_milliseconds = math.maxinteger }

local function leader_map(key, action)
	table.insert(config.keys, { key = key, action = action, mods = "LEADER" })
	table.insert(config.keys, { key = key, action = action, mods = "LEADER|CTRL|SHIFT" })
end

config.keys = {
	{ key = "Space",     mods = "CTRL|SHIFT", action = act.DisableDefaultAssignment },
	{ key = "UpArrow",   mods = "SHIFT",      action = act.ScrollByLine(-1) },
	{ key = "DownArrow", mods = "SHIFT",      action = act.ScrollByLine(1) },
	{ key = "UpArrow",   mods = "CTRL|SHIFT", action = act.ScrollByLine(-5) },
	{ key = "DownArrow", mods = "CTRL|SHIFT", action = act.ScrollByLine(5) },
}

leader_map("q", act.QuickSelect)
leader_map("\\", act.ShowLauncher)
leader_map("a", act.ActivateKeyTable { name = "activate_pane" })
leader_map("s", act.ActivateKeyTable { name = "split_pane" })
leader_map("r", act.ActivateKeyTable { name = "resize_pane", one_shot = false })

leader_map("LeftArrow", act.ActivatePaneDirection "Left")
leader_map("h", act.ActivatePaneDirection "Left")
leader_map("RightArrow", act.ActivatePaneDirection "Right")
leader_map("l", act.ActivatePaneDirection "Right")
leader_map("UpArrow", act.ActivatePaneDirection "Up")
leader_map("k", act.ActivatePaneDirection "Up")
leader_map("DownArrow", act.ActivatePaneDirection "Down")
leader_map("j", act.ActivatePaneDirection "Down")
leader_map("|", act.SplitPane { direction = "Right" })

local pop_key_table = { key = "Escape", action = "PopKeyTable" }
config.key_tables = {
	activate_pane = {
		{ key = "LeftArrow",  action = act.ActivatePaneDirection "Left" },
		{ key = "h",          action = act.ActivatePaneDirection "Left" },
		{ key = "RightArrow", action = act.ActivatePaneDirection "Right" },
		{ key = "l",          action = act.ActivatePaneDirection "Right" },
		{ key = "UpArrow",    action = act.ActivatePaneDirection "Up" },
		{ key = "k",          action = act.ActivatePaneDirection "Up" },
		{ key = "DownArrow",  action = act.ActivatePaneDirection "Down" },
		{ key = "j",          action = act.ActivatePaneDirection "Down" },
		pop_key_table,
	},
	resize_pane = {
		{ key = "LeftArrow",  action = act.AdjustPaneSize { "Left", 1 } },
		{ key = "h",          action = act.AdjustPaneSize { "Left", 1 } },
		{ key = "RightArrow", action = act.AdjustPaneSize { "Right", 1 } },
		{ key = "l",          action = act.AdjustPaneSize { "Right", 1 } },
		{ key = "UpArrow",    action = act.AdjustPaneSize { "Up", 1 } },
		{ key = "k",          action = act.AdjustPaneSize { "Up", 1 } },
		{ key = "DownArrow",  action = act.AdjustPaneSize { "Down", 1 } },
		{ key = "j",          action = act.AdjustPaneSize { "Down", 1 } },
		{ key = "LeftArrow",  action = act.AdjustPaneSize { "Left", 5 },  mods = "SHIFT" },
		{ key = "h",          action = act.AdjustPaneSize { "Left", 5 },  mods = "SHIFT" },
		{ key = "RightArrow", action = act.AdjustPaneSize { "Right", 5 }, mods = "SHIFT" },
		{ key = "l",          action = act.AdjustPaneSize { "Right", 5 }, mods = "SHIFT" },
		{ key = "UpArrow",    action = act.AdjustPaneSize { "Up", 5 },    mods = "SHIFT" },
		{ key = "k",          action = act.AdjustPaneSize { "Up", 5 },    mods = "SHIFT" },
		{ key = "DownArrow",  action = act.AdjustPaneSize { "Down", 5 },  mods = "SHIFT" },
		{ key = "j",          action = act.AdjustPaneSize { "Down", 5 },  mods = "SHIFT" },
		pop_key_table,
	},
	split_pane = {
		{ key = "LeftArrow",  action = act.SplitPane { direction = "Left" } },
		{ key = "h",          action = act.SplitPane { direction = "Left" } },
		{ key = "RightArrow", action = act.SplitPane { direction = "Right" } },
		{ key = "l",          action = act.SplitPane { direction = "Right" } },
		{ key = "UpArrow",    action = act.SplitPane { direction = "Up" } },
		{ key = "k",          action = act.SplitPane { direction = "Up" } },
		{ key = "DownArrow",  action = act.SplitPane { direction = "Down" } },
		{ key = "j",          action = act.SplitPane { direction = "Down" } },
		{ key = "LeftArrow",  action = act.SplitPane { direction = "Left", size = { Percent = 15 } },  mods = "SHIFT" },
		{ key = "h",          action = act.SplitPane { direction = "Left", size = { Percent = 15 } },  mods = "SHIFT" },
		{ key = "RightArrow", action = act.SplitPane { direction = "Right", size = { Percent = 15 } }, mods = "SHIFT" },
		{ key = "l",          action = act.SplitPane { direction = "Right", size = { Percent = 15 } }, mods = "SHIFT" },
		{ key = "UpArrow",    action = act.SplitPane { direction = "Up", size = { Percent = 15 } },    mods = "SHIFT" },
		{ key = "k",          action = act.SplitPane { direction = "Up", size = { Percent = 15 } },    mods = "SHIFT" },
		{ key = "DownArrow",  action = act.SplitPane { direction = "Down", size = { Percent = 15 } },  mods = "SHIFT" },
		{ key = "j",          action = act.SplitPane { direction = "Down", size = { Percent = 15 } },  mods = "SHIFT" },
		pop_key_table,
	}
}

if wezterm.target_triple:find("windows") ~= nil then
	local pwsh = { "pwsh", "-nol" }
	config.default_prog = pwsh

	config.launch_menu = {
		{
			label = "PowerShell",
			args = pwsh,
		},
		{
			label = "Bash",
			args = { "C:/Program Files/Git/bin/bash.exe", "-li" },
		},
		{
			label = "Command Prompt",
			args = { "cmd" },
		},
	}

	local vswhere = "C:/Program Files (x86)/Microsoft Visual Studio/Installer/vswhere.exe"
	local success, vs_install_path = wezterm.run_child_process {
		vswhere,
		"-latest",
		"-property",
		"installationpath"
	}
	if success then
		vs_install_path = vs_install_path:gsub("^%s*(.-)%s*$", "%1")

		local vs_dev_path = vs_install_path .. "\\Common7\\Tools"
		local vs_version = vs_install_path:gsub(".+(%d%d%d%d).+", "%1")

		table.insert(config.launch_menu, {
			label = "Developer Command Prompt for VS " .. vs_version,
			args = {
				"cmd", "/k", vs_dev_path .. "\\VsDevCmd.bat",
				"-startdir=none", "-arch=x64", "-host_arch=x64"
			}
		})

		local pwsh_dev_cmd = '&{Import-Module "'
				.. vs_dev_path
				.. '\\Microsoft.VisualStudio.DevShell.dll";'
				.. 'Enter-VsDevShell -VsInstallPath "'
				.. vs_install_path
				.. '" -SkipAutomaticLocation -DevCmdArguments "-arch=x64 -host_arch=x64"}'
		table.insert(config.launch_menu, {
			label = "Developer PowerShell for VS " .. vs_version,
			args = {
				"pwsh", "-nol", "-NoExit",
				"-Command", pwsh_dev_cmd
			}
		})
	end
end

return config
