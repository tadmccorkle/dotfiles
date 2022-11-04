EDITOR=nvim

# pretty-print path components
path() { sed 's/:/\n/g' <<< $PATH; }

is_win="$(command -v cmd)"

declare -a sources

if [ -n "$is_win" ]; then
    sources+=("windows")
else
    sources+=("unix")
fi

sources+=(
    "gitcompletion"
    "alias"
    "ps1"
)

for s in "${sources[@]}"; do
    source ~/.config/bash/$s.bash
done

unset sources
unset is_win
