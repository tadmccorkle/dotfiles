
# dotfiles by tad

This repo contains the dotfiles I use for my Windows configuration. I currently use:

* MSYS2
* git
* vim

The `./msys2/bash/path` file also showcases some of the other things I frequently use.

# to use

Fork and clone the repo. Make any necessary changes - probably a good idea to make sure `alias` and `path` will work on another machine.

Either run `msys.bat` (cmd) or `source msys` (msys2) to copy the files to your user directory.

If updates are made to any of the files in your user directory, run `update_msys.bat` or `source update_msys` to update the records in the local git repo.
