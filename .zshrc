__rc_git() {
	GIT_OPTIONAL_LOCKS=0 command git "$@"
}

prompt_info() {
	local root
	if root=$(__rc_git rev-parse --show-toplevel 2> /dev/null); then
		local pre="/$(__rc_git rev-parse --show-prefix)"
		local ref=$(__rc_git symbolic-ref --quiet HEAD 2> /dev/null)
		if [[ ! -n $ref ]]; then
			ref=$(__rc_git rev-parse --short HEAD)
		fi
		echo "$root:t${pre%?} %F{yellow}‹${ref#refs/heads/}›"
	else
		echo "%~"
	fi
}

setopt prompt_subst
PROMPT='%F{cyan}%n@%m%B%F{blue}::%b%F{blue}$(prompt_info) %B%(0?.%F{blue}.%F{red})»%f%b '
RPROMPT='%F{245}[%*]%f'

autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit
zstyle ':completion:*:*:*:*:*' menu select

if [[ -x "$(command -v nvim)" ]]; then
	export GIT_EDITOR=vim
	export EDITOR=vim
else
	export GIT_EDITOR=nvim
	export EDITOR=nvim
fi

export PNPM_HOME="/Users/tad/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

HISTFILE=$HOME/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
unsetopt HIST_VERIFY

path() { sed 's/:/\n/g' <<< $PATH; }

. "$HOME/.config/sh/alias"
