#!/bin/sh

set -eu

repo_url="${1:-git@github.com:tadmccorkle/dotfiles.git}"
dotfiles_dir="$HOME/.dotfiles"

cd "$HOME"

dotfiles() {
	git --git-dir="$dotfiles_dir" --work-tree="$HOME" "$@"
}

if [ -e "$dotfiles_dir" ] || [ -L "$dotfiles_dir" ]; then
	if ! git --git-dir="$dotfiles_dir" rev-parse --is-bare-repository >/dev/null 2>&1; then
		echo "error: '$dotfiles_dir' exists but is not a bare git repository" >&2
		exit 1
	fi
else
	echo "Cloning $repo_url into '$dotfiles_dir'..."
	if ! git clone -b cfg --bare "$repo_url" "$dotfiles_dir"; then
		echo "error: failed to clone $repo_url" >&2
		exit 1
	fi
fi

if ! dotfiles rev-parse --verify --quiet refs/heads/cfg >/dev/null; then
	if dotfiles rev-parse --verify --quiet refs/remotes/origin/cfg >/dev/null; then
		if ! dotfiles branch cfg origin/cfg; then
			echo "error: failed to create the 'cfg' branch" >&2
			exit 1
		fi
	else
		echo "error: '$dotfiles_dir' does not contain a 'cfg' branch" >&2
		exit 1
	fi
fi

checkout_output=""
if ! checkout_output=$(dotfiles checkout 2>&1); then
	printf '%s\n' "$checkout_output" >&2

	case "$checkout_output" in
	*"would be overwritten by checkout"* | *"would be removed by checkout"* | *"already exists in working directory"*) ;;
	*)
		echo "error: failed to check out dotfiles" >&2
		exit 1
		;;
	esac

	conflicts=$(printf '%s\n' "$checkout_output" | sed -n 's/^[[:space:]][[:space:]]*//p' | sed '/^$/d' | sort -u)

	if [ -z "$conflicts" ]; then
		echo "error: failed to check out dotfiles" >&2
		exit 1
	fi

	backup_dir="$HOME/.dotfiles.bak"
	suffix=0
	while [ -e "$backup_dir" ] || [ -L "$backup_dir" ]; do
		suffix=$((suffix + 1))
		backup_dir="$HOME/.dotfiles.bak.$suffix"
	done

	echo "Backing up pre-existing dotfiles to '$backup_dir'..." >&2
	if ! mkdir -p -- "$backup_dir"; then
		echo "error: failed to create '$backup_dir'" >&2
		exit 1
	fi

	while IFS= read -r file; do
		[ -n "$file" ] || continue

		src="$HOME/$file"
		if [ ! -e "$src" ] && [ ! -L "$src" ]; then
			continue
		fi

		dest="$backup_dir/$file"
		if ! mkdir -p -- "$(dirname -- "$dest")"; then
			echo "error: failed to create backup directory for '$file'" >&2
			exit 1
		fi

		if ! mv -- "$src" "$dest"; then
			echo "error: failed to back up '$src'" >&2
			exit 1
		fi
	done <<EOF
$conflicts
EOF

	if ! dotfiles checkout; then
		echo "error: failed to check out dotfiles after backing up conflicts" >&2
		exit 1
	fi
fi

if ! dotfiles config --local status.showUntrackedFiles no; then
	echo "warning: failed to hide untracked files" >&2
fi

if ! dotfiles config branch.cfg.remote origin; then
	echo "error: failed to configure upstream tracking for 'cfg'" >&2
	exit 1
fi

if ! dotfiles config branch.cfg.merge refs/heads/cfg; then
	echo "error: failed to configure upstream tracking for 'cfg'" >&2
	exit 1
fi

echo "Dotfiles applied."
echo ""
echo "To use the 'dotfiles' command immediately, define it in your shell:"
echo ""
echo "  dotfiles() { git --git-dir=\"\$HOME/.dotfiles/\" --work-tree=\"\$HOME\" \"\$@\" }"
echo ""
echo "Recommended: reload your shell config or restart your session."
