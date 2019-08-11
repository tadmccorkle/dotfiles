
# dotfiles by tad

This repo contains the dotfiles I use for my Windows configuration. I currently use:

* MSYS2
* git
* vim

The `./msys2/bash/path` file also showcases some of the other things I frequently use.

# to use

Fork and clone the repo. Make any necessary edits to the dotfiles. The files that likely must be edited on another machine are `alias` and `path`.

Either run `msys.bat` or `source msys` to copy the files to your user directory.

If updates are made to any of the files in your user directory, run `update_msys.bat` or `source update_msys` to update the records in the local git repository.
