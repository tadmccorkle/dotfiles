# dotfiles by tad

Dotfiles that support my Windows (PowerShell 7 or Git Bash) and macOS (Zsh) configurations -- they live on the [cfg](https://github.com/tadmccorkle/dotfiles/tree/cfg) branch.

## requirements

My PowerShell configuration requires [posh-git](https://github.com/dahlbyk/posh-git). It also requires the following line be added to one of the PowerShell profiles:

```pwsh
. $env:USERPROFILE\.config\powershell\profile.ps1
```

The Neovim command `:checkhealth` can be used to get an idea of other required dependencies (CMake, clang/gcc, 7z/gzip, etc.); otherwise, take a look at plugin docs.

## to use

Fork the repo. If any changes need to be made prior to applying the configuration, clone the repo, checkout the `cfg` branch, and make any necessary changes - probably a good idea to make sure aliases and path components will work on the target machine.

To apply the configuration:

1. Define the following function/alias for the current shell scope.

```pwsh
# pwsh
function dotfiles { git --git-dir=$env:USERPROFILE/.dotfiles/ --work-tree=$env:USERPROFILE $args }
```

```sh
# bash/zsh
alias dotfiles="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
```

2. Clone into a bare repository pointing to the `cfg` branch in a `.dotfiles` directory of `USERPROFILE`/`$HOME`.

```pwsh
# pwsh
git clone -b cfg --bare <repo-url> $env:USERPROFILE/.dotfiles
```

```sh
# bash/zsh
git clone -b cfg --bare <repo-url> $HOME/.dotfiles
```

3. Checkout the repo to your `USERPROFILE`/`$HOME` directory.

```sh
dotfiles checkout
```

> **Note**
>
> This won't overwrite any existing dotfiles also present in the repo. Either back up the existing files...
> ```pwsh
> # pwsh
> dotfiles checkout 2>&1 | Select-String -Pattern "\s+[._]" -Raw | %{ $_.Trim() } | %{
>   mkdir .dotfiles.bak/$(Split-Path -Path $_ -Parent) -ErrorAction SilentlyContinue
>   mv $_ .dotfiles.bak/$_ -ErrorAction SilentlyContinue
> }
> ```
> ```sh
> # bash/zsh
> dotfiles checkout 2>&1 | grep -E "\s+[._]" | awk {'print $1'} | \
>   xargs -I{} sh -c 'mkdir -p .dotfiles.bak/$(dirname {}) && mv {} .dotfiles.bak/{}'
> ```
> ...and run `dotfiles checkout` again or overwrite them with `dotfiles checkout -f`.

4. Set the remote as upstream.

```sh
dotfiles push -u origin cfg
```

5. Hide untracked files.

```sh
dotfiles config --local status.showUntrackedFiles no
```

Now manage the local git repo in your `USERPROFILE`/`$HOME` directory using `dotfiles` instead of `git` (e.g., `dotfiles status`, `dotfiles add .bashrc`, `dotfiles add -u`, `dotfiles commit`, etc.).

## to apply with one command

You can automate the process by making a gist with all the commands shown above. My dotfiles configuration can be applied with my [dotfiles-pwsh gist](https://gist.github.com/tadmccorkle/f57b24cdaf47ad4c999ab65c92db0244) or [dotfiles-bash gist](https://gist.github.com/tadmccorkle/93fc70287b30dd4e3985f8e8e41862a8) by calling:

```pwsh
# pwsh
curl -Ls https://gist.githubusercontent.com/tadmccorkle/f57b24cdaf47ad4c999ab65c92db0244/raw | pwsh -NoProfile
```

```sh
# bash/zsh
curl -Ls https://gist.githubusercontent.com/tadmccorkle/93fc70287b30dd4e3985f8e8e41862a8/raw | /bin/bash
```

# acknowledgements

- https://news.ycombinator.com/item?id=11071754
- https://www.atlassian.com/git/tutorials/dotfiles
