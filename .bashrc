EDITOR=nvim

# pretty-print path components
path() { sed 's/:/\n/g' <<< $PATH; }

is_win="$(command -v cmd)"

if [ -n "$is_win" ]; then
	# set nvim environment variables
	if [ -z "$XDG_CONFIG_HOME" ]; then
		export XDG_CONFIG_HOME=~/.config
	fi
	if [ -z "$XDG_DATA_HOME" ]; then
		export XDG_DATA_HOME=~/.local/share
	fi

	# alias
	alias ps="ps --windows"

	# functions
	open() {
		[[ -z $1 ]] && { start "" . ; return; }
		[[ ! -e "./$1" && ! -e "$1" && ! $1 =~ (\/[cC]:|[cC]:) ]] && \
			echo "error: '$1' does not exist." && return
		start "" "${1//'/'/'\\'}"
	}

	# path
	declare -a comps=(
		"/mingw64/bin"
		"/cmd"
		"/usr/bin/vendor_perl"
		"/usr/bin/core_perl"
		"/c/PROGRA~2/INTEGR~1/Toolkit/mksnt"
		"/c/WINDOWS/System32/OpenSSH"
		"/c/Program Files/PowerShell/7"
		"/c/Program Files/Git/cmd"
		"/c/Program Files/Git/usr/bin"
		"/c/Program Files/Git LFS"
		"/c/Program Files/nodejs"
		"/c/Program Files/dotnet"
		"/c/Program Files (x86)/GnuWin32/bin"
		"/c/Program Files/Neovim/bin"
		"/c/Program Files/LLVM/bin"
		"/c/Program Files/CMake/bin"
		"/c/Program Files/7-Zip"
		"$HOME/bin"
		"$HOME/AppData/Local/Programs/Python/Python311"
		"$HOME/AppData/Local/Programs/Python/Python311/Scripts"
		"$HOME/AppData/Local/Programs/Microsoft VS Code/bin"
		"$HOME/AppData/Local/Microsoft/WindowsApps"
		"$HOME/AppData/Roaming/npm"
		"$HOME/.dotnet/tools"
		"$HOME/.dotnet/tools/docfx"
	)

	for comp in "${comps[@]}"; do
		[[ ":$PATH:" != *":$comp:"* ]] && PATH="$PATH:$comp"
	done

	export PATH

	unset comps
fi

unset is_win

# pnpm
export PNPM_HOME="/Users/tad/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

RED="\[\033[0;31m\]"
GREEN="\[\033[0;32m\]"
BLUE="\[\033[1;34m\]"
YELLOW="\[\033[1;33m\]"
VIOLET="\[\033[1;35m\]"
DARK_GRAY="\[\033[1;30m\]"
CYAN="\[\033[1;36m\]"
DEFCOL="\[\033[0m\]"

git_branch() {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ [\1]/'
}

PS1="$DARK_GRAY[\t] $CYAN\u@\h$DEFCOL:$BLUE\w$YELLOW\$(git_branch)$DEFCOL $ "

if [ -f "$HOME/.cargo/env" ]; then
	. "$HOME/.cargo/env"
fi
if [ -f "$HOME/.config/bash/_windows" ]; then
	. "$HOME/.config/bash/_windows"
fi
. "$HOME/.config/sh/alias"

alias reload=". $HOME/.bash_profile"
