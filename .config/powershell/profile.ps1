function dotfiles { git --git-dir=$env:USERPROFILE/.dotfiles/ --work-tree=$env:USERPROFILE $args }

# nvim config
$env:XDG_CONFIG_HOME = "$env:USERPROFILE\.config"

# nvim data
$env:XDG_DATA_HOME = "$env:USERPROFILE\.local\share"

# nvim path components
$nvim_comps = @(
	"$env:PROGRAMFILES\LLVM\bin"
	"$env:PROGRAMFILES\CMake\bin"
	"$env:PROGRAMFILES\7-Zip"
)

# posh git
Import-Module posh-git
$GitPromptSettings.EnableFileStatus = $false
$GitPromptSettings.DefaultPromptAbbreviateHomeDirectory = $true
$GitPromptSettings.DefaultPromptAbbreviateGitDirectory = $true
$GitPromptSettings.DefaultPromptPrefix.Text = "[$(Get-Date -f 'HH:mm:ss')] "
$GitPromptSettings.DefaultPromptPrefix.ForegroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BeforePath = "$env:USERNAME@$($env:COMPUTERNAME.ToLower()) "
$GitPromptSettings.BeforePath.ForegroundColor = [ConsoleColor]::Cyan
$GitPromptSettings.DefaultPromptPath.ForegroundColor = [ConsoleColor]::Blue

# color preferences
$PSStyle.FileInfo.Directory = "`e[36;1m"
$PSStyle.FileInfo.SymbolicLink = "`e[36;3m"

# alias
Set-Alias vim nvim
Set-Alias ll ls
Set-Alias grep findstr
Set-Alias less 'C:\Program Files\Git\usr\bin\less.exe'
Set-Alias open start

# functions
function which ($Command) {
	Get-Command -Name $Command -ErrorAction SilentlyContinue |
	Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

# use like `sh ls` or `sh "ls -l"`
function sh ($Command) {
	& "$env:PROGRAMFILES\Git\bin\sh.exe" --login -c "$Command"
}

# use like `With-Env "RUST_BACKTRACE" 1 "cargo run"`
function With-Env {
	Param($Variable, $Value, $Command)
@"
[Environment]::SetEnvironmentVariable("$Variable", "$Value")
Invoke-Expression "$Command"
"@ | pwsh -Command -
}

# use like `With-Envs @{RUST_BACKTRACE=1;CUSTOM_VAR="custom_value"} "cargo run"`
function With-Envs {
	Param([Hashtable] $EnvPairs, $Command)
	$SetEnvironment = $EnvPairs.GetEnumerator() | %{
		"[Environment]::SetEnvironmentVariable(`"{0}`", `"{1}`");" -f $_.Key, $_.Value
	}
@"
$SetEnvironment
Invoke-Expression "$Command"
"@ | pwsh -Command -
}

function .. { cd .. }
function ... { cd ..\.. }
function repos { cd $env:USERPROFILE\source\repos }

# path
$comps = @(
	"$env:USERPROFILE\bin"
	"${env:ProgramFiles(x86)}\GnuWin32\bin"
	"$env:USERPROFILE\.dotnet\tools"
	"$env:USERPROFILE\.dotnet\tools\docfx"
	"$env:USERPROFILE\.yarn\bin"
) + $nvim_comps

foreach ($comp in $comps) {
	if (!$env:PATH.Contains(";$comp")) {
		$env:PATH += ";$comp"
	}
}
