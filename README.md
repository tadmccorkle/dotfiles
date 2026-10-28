# dotfiles by tad

Dotfiles that support my Windows (PowerShell 7 or Git Bash) and macOS (zsh) configurations -- they live on the [cfg](https://github.com/tadmccorkle/dotfiles/tree/cfg) branch.

## requirements

### macOS

- [Homebrew](https://brew.sh/) — required to apply the `.Brewfile`, which installs the rest of the CLI tools (Neovim, Node.js, fzf, ripgrep, etc.).
- [Rust](https://www.rust-lang.org/tools/install) — provides `cargo`, which the `.Brewfile` uses to install `ripgrep`.

### Windows

- [PowerShell 7](https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-windows).
- [Git for Windows](https://gitforwindows.org/) — provides Git and Git Bash.
- [posh-git](https://github.com/dahlbyk/posh-git#installation) — required by the PowerShell profile: `Install-Module posh-git -Scope CurrentUser`
- [Neovim](https://neovim.io/).
- Neovim's external tools:
  - [fzf](https://github.com/junegunn/fzf#installation) and [ripgrep](https://github.com/BurntSushi/ripgrep#installation) for `fzf-lua`.
  - [LLVM](https://llvm.org/) and the [tree-sitter CLI](https://github.com/tree-sitter/tree-sitter/tree/master/crates/cli#installation) for Tree-sitter parsers.
  - [Node.js](https://nodejs.org/) for Node-based Mason packages.
  - [7-Zip](https://www.7-zip.org/) for Mason.
  - [CMake](https://cmake.org/download/) for native plugin builds.
  - [MSYS2](https://www.msys2.org/) for `gdb` when debugging C/C++ (optional).

The PowerShell profile must contain:

```powershell
. $env:USERPROFILE\.config\powershell\profile.ps1
```

## setup

Installation scripts are in [`scripts/`](scripts/). Both scripts default to SSH (`git@github.com:tadmccorkle/dotfiles.git`) and accept an optional remote URL as the first argument.

- zsh/bash - [`dotfiles.sh`](scripts/dotfiles.sh)

  ```sh
  curl -fsSL https://raw.githubusercontent.com/tadmccorkle/dotfiles/master/scripts/dotfiles.sh | /bin/sh -s
  ```

  ```sh
  # or substitute your custom $DOTFILES_REPO
  curl -fsSL https://raw.githubusercontent.com/tadmccorkle/dotfiles/master/scripts/dotfiles.sh | /bin/sh -s -- $DOTFILES_REPO
  ```

- PowerShell - [`dotfiles.ps1`](scripts/dotfiles.ps1)

  ```powershell
  curl -fsSL https://raw.githubusercontent.com/tadmccorkle/dotfiles/master/scripts/dotfiles.ps1 | pwsh -NoProfile -Command -
  ```

  ```powershell
  # or substitute your custom $env:DOTFILES_REPO
  curl -fsSL https://raw.githubusercontent.com/tadmccorkle/dotfiles/master/scripts/dotfiles.ps1 | pwsh -NoProfile -Command - $env:DOTFILES_REPO
  ```

### manual setup

Run these commands from your home directory (`cd "$HOME"`/`Set-Location $env:USERPROFILE`) so relative paths resolve consistently.

1. Define the following function for the current shell scope.

   ```sh
   # sh
   dotfiles() { git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@" }
   ```

   ```powershell
   # pwsh
   function dotfiles { & git "--git-dir=$env:USERPROFILE/.dotfiles" "--work-tree=$env:USERPROFILE" @args }
   ```

2. Clone into a bare repository pointing to the `cfg` branch in a `.dotfiles` directory of `$HOME`/`$env:USERPROFILE`.

   Use the HTTPS URL (`https://github.com/tadmccorkle/dotfiles.git`) instead when SSH is unavailable.

   ```sh
   # sh
   git clone -b cfg --bare git@github.com:tadmccorkle/dotfiles.git "$HOME/.dotfiles"
   ```

   ```powershell
   # pwsh
   git clone -b cfg --bare git@github.com:tadmccorkle/dotfiles.git "$env:USERPROFILE/.dotfiles"
   ```

3. Checkout the repo to your `$HOME`/`$env:USERPROFILE` directory.

   ```sh
   dotfiles checkout
   ```

   > **Note**
   >
   > This won't overwrite any existing dotfiles also present in the repo. Either back up the existing files...
   > ```sh
   > # sh
   > dotfiles checkout 2>&1 | grep -E '^[[:space:]]+[._]' | sed -E 's/^[[:space:]]+//' | \
   >   while IFS= read -r file; do
   >     [ -e "$HOME/$file" ] || [ -L "$HOME/$file" ] || continue
   >     mkdir -p "$HOME/.dotfiles.bak/$(dirname -- "$file")"
   >     mv -- "$HOME/$file" "$HOME/.dotfiles.bak/$file"
   >   done
   > ```
   >
   > ```powershell
   > # pwsh
   > dotfiles checkout 2>&1 | Select-String -Pattern '^\s+[._]' | %{ $_.Line.Trim() } | %{
   >   $src = Join-Path $env:USERPROFILE $_
   >   if (Test-Path -LiteralPath $src) {
   >     $dest = Join-Path $env:USERPROFILE ".dotfiles.bak/$_"
   >     New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dest) | Out-Null
   >     Move-Item -LiteralPath $src -Destination $dest
   >   }
   > }
   > ```
   > ...and run `dotfiles checkout` again or overwrite them with `dotfiles checkout -f`.

4. Hide untracked files.

   ```sh
   dotfiles config --local status.showUntrackedFiles no
   ```

5. Set up upstream tracking.

   ```sh
   dotfiles config branch.cfg.remote origin
   dotfiles config branch.cfg.merge refs/heads/cfg
   ```

Now manage the local git repo in your `$HOME`/`$env:USERPROFILE` directory using `dotfiles` instead of `git` (e.g., `dotfiles status`, `dotfiles add .bashrc`, `dotfiles add -u`, `dotfiles commit`, etc.).

# acknowledgements

- https://news.ycombinator.com/item?id=11071754
- https://www.atlassian.com/git/tutorials/dotfiles
