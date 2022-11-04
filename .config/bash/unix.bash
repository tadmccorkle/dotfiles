# path
declare -a comps=(
    # typical unix path components
)

for comp in "${comps[@]}"; do
    [[ ":$PATH:" != *":$comp:"* ]] && PATH="$PATH:$comp"
done

if [ -f ~/.bash/_unix ]; then
    source ~/.bash/_unix.bash
fi

export PATH

unset comps
