function dotfiles { git --git-dir=$env:USERPROFILE/.dotfiles/ --work-tree=$env:USERPROFILE $args }

# nvim config
$env:XDG_CONFIG_HOME = "$env:USERPROFILE\.config"

# nvim data
$env:XDG_DATA_HOME = "$env:USERPROFILE\.local\share"

# nvim path components
$nvim_comps = @(
	"C:\Program Files\LLVM\bin"
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

# alias
Set-Alias vim nvim
Set-Alias ll ls
Set-Alias grep findstr
Set-Alias less 'C:\Program Files\Git\usr\bin\less.exe'
Set-Alias open start

# functions
function which ($command) {
	Get-Command -Name $command -ErrorAction SilentlyContinue |
	Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function .. { cd .. }
function ... { cd ..\.. }
function repos { cd $env:USERPROFILE\source\repos }

# path
$comps = @(
	"$env:PROGRAMFILES\7-Zip"
	"$env:USERPROFILE\.dotnet\tools"
	"$env:USERPROFILE\.dotnet\tools\docfx"
	"$env:USERPROFILE\.yarn\bin"
) + $nvim_comps

foreach ($comp in $comps) {
	if (!$env:PATH.Contains(";$comp")) {
		$env:PATH += ";$comp"
	}
}
