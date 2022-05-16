# ~/.bashrc

declare -a sources=(
    "path"
    "gitcompletion"
    "alias"
    "editor"
    "func"
    "ps1"
)

declare -a ignores=(
    # files not to source in ~/bash directory
)

for s in "${sources[@]}"; do
    source ~/bash/$s
done

for f in ~/bash/*; do
    [[ " ${sources[*]} " != *" $(basename -- $f) "* ]] && \
    [[ " ${ignores[*]} " != *" $(basename -- $f) "* ]] && \
    source $f
done

unset sources
unset ignores
