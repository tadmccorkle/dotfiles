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
    "editor"
    "func"
    "ps1"
)

for s in "${sources[@]}"; do
    source ~/.config/bash/$s
done

unset sources
unset is_win
