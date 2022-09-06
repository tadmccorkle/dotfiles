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
