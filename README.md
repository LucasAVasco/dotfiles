# Personal dot files

This repository contains my personal dot files. I manage then with [GNU Stow](https://www.gnu.org/software/stow/) and a
[Makefile](Makefile) with simple commands.


## Installation

To install these dot files, you can use git:

```sh
git clone https://github.com/LucasAVasco/dotfiles ~/.local/dotfiles
```

## Usage

Each folder in the current directory is a package, and the files in it are the dot files of that package. To enable some package, just use
the `make enable-<package>`. To disable some package, just use `make disable-<package>`. Running `make enable` will enable all packages.
And `make disable` will disable all packages. Full information can be found in the [Makefile](Makefile).

[GNU Stow](https://www.gnu.org/software/stow/) will create symbolic links in you home directory. The real file will be in this repository,
so do not remove it.

To easily access the dot files management, you can create an alias. E.g. If you use bash:

```bash
alias dotfiles='make -C ~/.local/dotfiles SD=$(pwd)'
```

The description of this alias can be found in the [Makefile](Makefile).
