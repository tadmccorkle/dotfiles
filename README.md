# dotfiles by tad

Dotfiles for my Windows and Ubuntu (WSL2) configurations. Requires bash shell.

## to use

Dotfiles live on the [cfg](https://github.com/tadmccorkle/dotfiles/tree/cfg) branch.

Fork the repo. If any changes need to be made prior to applying the configuration, clone the repo, checkout the `cfg` branch, and make any necessary changes - probably a good idea to make sure `alias` and `path` will work on the target machine.

To apply the configuration:

1. Define the following alias for the current shell scope.

```sh
alias config="git --git-dir=$HOME/.cfg/ --work-tree=$HOME"
```

2. Clone into a bare repository pointing to the `cfg` branch in a `.cfg` directory of `$HOME`.

```sh
git clone -b cfg --bare <repo-url> $HOME/.cfg
```

3. Checkout the repo to your `$HOME` directory.

```sh
config checkout
```

> **Note**
>
> This won't overwrite any existing dotfiles also present in the repo. Either back up the existing files...
> ```sh
> config checkout 2>&1 | grep -E "\s+[._]" | awk {'print $1'} | \
>   xargs -I{} sh -c 'mkdir -p .cfg.bak/$(dirname {}) && mv {} .cfg.bak/{}'
> ```
> ...and run `config checkout` again or overwrite them with `config checkout -f`.

4. Set the remote as upstream.

```sh
config push -u origin cfg
```

5. Hide untracked files.

```sh
config config --local status.showUntrackedFiles no
```

Now manage the local git repo in your `$HOME` directory using `config` instead of `git` (i.e. `config status`, `config add .bashrc`, `config commit`, etc.).

## to apply with one command

You can automate the process by making a gist with all the commands shown above. My dotfiles configuration can be applied with my [cfg gist](https://gist.github.com/tadmccorkle/93fc70287b30dd4e3985f8e8e41862a8) by calling:

```sh
curl -Ls https://gist.githubusercontent.com/tadmccorkle/93fc70287b30dd4e3985f8e8e41862a8/raw/94ecf85cee45126915364ef3f0931a3c68d340cc/cfg | /bin/bash
```

# acknowledgements

- https://news.ycombinator.com/item?id=11071754
- https://www.atlassian.com/git/tutorials/dotfiles
