# ~/.bashrc

declare -a sources=(
    "path"
    "gitcompletion"
    "alias"
    "editor"
    "func"
    "ps1"
)

for s in "${sources[@]}"; do
    source ~/bash/$s
done

unset sources
