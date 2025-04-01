. "$HOME/.config/sh/env"

RED="\[\033[0;31m\]"
GREEN="\[\033[0;32m\]"
BLUE="\[\033[1;34m\]"
YELLOW="\[\033[1;33m\]"
VIOLET="\[\033[1;35m\]"
DARK_GRAY="\[\033[1;30m\]"
CYAN="\[\033[1;36m\]"
DEFCOL="\[\033[0m\]"

__prompt_info() {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ [\1]/'
}

PS1="$CYAN\u@\h$DEFCOL:$BLUE\w$YELLOW\$(__prompt_info)$DEFCOL $ "

if [[ -x "$(command -v nvim)" ]]; then
	export GIT_EDITOR=nvim
	export EDITOR=nvim
else
	export GIT_EDITOR=vim
	export EDITOR=vim
fi

eval "$(fzf --bash)"

path() { sed 's/:/\n/g' <<< $PATH; }

if [ -f "$HOME/.config/bash/_windows" ]; then
	. "$HOME/.config/bash/_windows"
fi

. "$HOME/.config/sh/alias"
alias reload=". $HOME/.bash_profile"

is_win="$(command -v cmd)"
if [ -n "$is_win" ]; then
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
		"$HOME/AppData/Local/Programs/Python/Python311"
		"$HOME/AppData/Local/Programs/Python/Python311/Scripts"
		"$HOME/AppData/Local/Programs/Microsoft VS Code/bin"
		"$HOME/AppData/Local/Microsoft/WindowsApps"
		"$HOME/AppData/Roaming/npm"
		"$HOME/.dotnet/tools"
	)

	for comp in "${comps[@]}"; do
		[[ ":$PATH:" != *":$comp:"* ]] && PATH="$PATH:$comp"
	done

	export PATH

	unset comps
fi
unset is_win
