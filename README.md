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

3. Checkout the repo to your `$HOME` directory. Note that the `-f` flag will overwrite any existing files also present in the repo, so back those up ahead of time if you want to keep them.

```sh
config checkout -f
```

4. Set the remote as upstream.

```sh
config push -u origin cfg
```

5. Hide untracked files.

```sh
config config --local status.showUntrackedFiles no
```

Now manage the local git repo in your `$HOME` directory using `config` instead of `git` (i.e. `config status`, `config add .bashrc`, `config commit`, etc.).

# acknowledgements

- https://news.ycombinator.com/item?id=11071754
- https://www.atlassian.com/git/tutorials/dotfiles
