local wezterm = require "wezterm"

wezterm.on("gui-startup", function(_)
	local _, _, window = wezterm.mux.spawn_window {}
	window:gui_window():maximize()
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
config.color_schemes = { ["tad default"] = theme }
config.color_scheme = "tad default"

config.font = wezterm.font "Cascadia Code"
config.font_size = 12

config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true

config.keys = {
	-- show launcher
	{
		key = "l",
		mods = "ALT",
		action = wezterm.action.ShowLauncher,
	},
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
		mods = "CTRL|ALT|SHIFT",
		action = wezterm.action.SplitPane {
			direction = "Down",
			size = { Percent = 15 },
		},
	},
	-- activate to split left
	{
		key = "h",
		mods = "ALT|SHIFT",
		action = wezterm.action.ActivatePaneDirection "Left",
	},
	-- activate to split down
	{
		key = "j",
		mods = "ALT|SHIFT",
		action = wezterm.action.ActivatePaneDirection "Down",
	},
	-- activate to split up
	{
		key = "k",
		mods = "ALT|SHIFT",
		action = wezterm.action.ActivatePaneDirection "Up",
	},
	-- activate to split right
	{
		key = "l",
		mods = "ALT|SHIFT",
		action = wezterm.action.ActivatePaneDirection "Right",
	},
}

config.inactive_pane_hsb = {
	saturation = 0.8,
	brightness = 0.8,
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

	-- TODO: some issues with this, mainly with the spawn process args in each menu item
	-- local vswhere = "C:/Program Files (x86)/Microsoft Visual Studio/Installer/vswhere.exe"
	-- local success, vs_install_path = wezterm.run_child_process {
	-- 	vswhere,
	-- 	"-latest",
	-- 	"-property",
	-- 	"installationpath"
	-- }
	-- if success then
	-- 	local vs_dev_path = vs_install_path .. "\\Common7\\Tools\\"
	-- 	local vs_version = vs_install_path:gsub(".+(%d%d%d%d).+", "%1")
	--
	-- 	table.insert(config.launch_menu, {
	-- 		label = "test",
	-- 		args = { "cmd", "/k", 'echo "' .. vs_dev_path .. '"' }
	-- 	})
	--
	-- 	table.insert(config.launch_menu, {
	-- 		label = "Developer Command Prompt for VS " .. vs_version,
	-- 		args = {
	-- 			"cmd", "/k", 'echo "' .. vs_dev_path .. 'VsDevCmd.bat"',
	-- 			"-startdir=none", "-arch=x64", "-host_arch=x64"
	-- 		}
	-- 	})
	--
	-- 	local pwsh_dev_cmd = '"&{Import-Module """'
	-- 			.. vs_dev_path
	-- 			.. 'Microsoft.VisualStudio.DevShell.dll""";'
	-- 			.. 'Enter-VsDevShell -VsInstallPath '
	-- 			.. vs_install_path
	-- 			.. ' -SkipAutomaticLocation -DevCmdArguments """-arch=x64 -host_arch=x64"""}'
	-- 	table.insert(config.launch_menu, {
	-- 		label = "Developer PowerShell for VS " .. vs_version,
	-- 		args = {
	-- 			"pwsh", "-nol", "-NoExit",
	-- 			"-Command", pwsh_dev_cmd
	-- 		}
	-- 	})
	-- end
end

return config
