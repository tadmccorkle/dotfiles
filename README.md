# dotfiles by tad

Dotfiles for my Windows and Ubuntu (WSL2) configurations. Requires PowerShell 7 or a Bash shell. PowerShell is assumed to be on Windows.

## requirements

My current PowerShell configuration requires [posh-git](https://github.com/dahlbyk/posh-git). It also requires the following line be added to one of the PowerShell profiles:

```pwsh
. $env:USERPROFILE\.config\powershell\profile.ps1
```

I also use Neovim, and my current configuration uses plugins that have other dependencies like CMake, clang/gcc, and 7z/gzip. The Neovim command `:checkhealth` can be used to get an idea of the dependencies that are needed; otherwise, take a look at plugin docs.

## to use

Dotfiles live on the [cfg](https://github.com/tadmccorkle/dotfiles/tree/cfg) branch.

Fork the repo. If any changes need to be made prior to applying the configuration, clone the repo, checkout the `cfg` branch, and make any necessary changes - probably a good idea to make sure aliases and path components will work on the target machine.

To apply the configuration:

1. Define the following function/alias for the current shell scope.

```pwsh
# pwsh
function dotfiles { git --git-dir=$env:USERPROFILE/.dotfiles/ --work-tree=$env:USERPROFILE $args }
```

```sh
# bash
alias dotfiles="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
```

2. Clone into a bare repository pointing to the `cfg` branch in a `.dotfiles` directory of `USERPROFILE`/`$HOME`.

```pwsh
# pwsh
git clone -b cfg --bare <repo-url> $env:USERPROFILE/.dotfiles
```

```sh
# bash
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
> # bash
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

Now manage the local git repo in your `USERPROFILE`/`$HOME` directory using `dotfiles` instead of `git` (i.e. `dotfiles status`, `dotfiles add .bashrc`, `dotfiles add -u`, `dotfiles commit`, etc.).

## to apply with one command

You can automate the process by making a gist with all the commands shown above. My dotfiles configuration can be applied with my [dotfiles-pwsh gist](https://gist.github.com/tadmccorkle/f57b24cdaf47ad4c999ab65c92db0244) or [dotfiles-bash gist](https://gist.github.com/tadmccorkle/93fc70287b30dd4e3985f8e8e41862a8) by calling:

```pwsh
curl -Ls https://gist.githubusercontent.com/tadmccorkle/f57b24cdaf47ad4c999ab65c92db0244/raw | pwsh -NoProfile
```

```sh
# bash
curl -Ls https://gist.githubusercontent.com/tadmccorkle/93fc70287b30dd4e3985f8e8e41862a8/raw | /bin/bash
```

# acknowledgements

- https://news.ycombinator.com/item?id=11071754
- https://www.atlassian.com/git/tutorials/dotfiles
