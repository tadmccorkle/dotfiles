# set nvim environment variables
if [ -z "$XDG_CONFIG_HOME" ]; then
    export XDG_CONFIG_HOME=~/.config
fi
if [ -z "$XDG_DATA_HOME" ]; then
    export XDG_DATA_HOME=~/.local/share
fi

# alias
alias ps="ps --windows"
alias repos="cd ~/source/repos"

# functions
open() {
    [[ -z $1 ]] && { start "" . ; return; }
    [[ ! -e "./$1" && ! -e "$1" && ! $1 =~ (\/[cC]:|[cC]:) ]] && \
        echo "error: '$1' does not exist." && return
    start "" "${1//'/'/'\\'}"
}

# path
declare -a comps=(
    # typical windows path components
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
    "$HOME/.yarn/bin"
)

for comp in "${comps[@]}"; do
    [[ ":$PATH:" != *":$comp:"* ]] && PATH="$PATH:$comp"
done

if [ -f ~/.bash/_windows ]; then
    source ~/.bash/_windows.bash
fi

export PATH

unset comps