#
# functions
#
dotfiles() { git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME "$@" }
path() { sed 's/:/\n/g' <<< $PATH; }

#
# aliases
#
. "$HOME/.config/sh/alias"

#
# prompt
#
__rc_git() {
	GIT_OPTIONAL_LOCKS=0 command git "$@"
}

__prompt_info() {
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
PROMPT='%F{cyan}%n@%m%B%F{blue}::%b%F{blue}$(__prompt_info) %B%(0?.%F{blue}.%F{red})»%f%b '
RPROMPT='%F{245}[%*]%f'

#
# completion
#
fpath=("$HOME/.config/zsh/completions" $fpath)
autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:descriptions' format '%B%U%d%u%b'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ''

#
# history
#
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

#
# key bindings
#
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line
bindkey ' ' magic-space

#
# other setup
#
if [ -x "$(command -v nvim)" ]; then
	export GIT_EDITOR=nvim
	export EDITOR=nvim
else
	export GIT_EDITOR=vim
	export EDITOR=vim
fi

if [[ -x "$(command -v fzf)" ]]; then
	source <(fzf --zsh)
fi

# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
[[ ! -r "$HOME/.opam/opam-init/init.zsh" ]] || source "$HOME/.opam/opam-init/init.zsh" > /dev/null 2> /dev/null
# END opam configuration

# bun completions
[ -s "/Users/tad/.bun/_bun" ] && source "/Users/tad/.bun/_bun"
