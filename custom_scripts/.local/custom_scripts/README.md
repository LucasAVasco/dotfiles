# Custom scripts

This folder contains custom scripts that I use in my projects and day-to-day tasks.

> [!WARNING]
> Scripts can have some external dependencies. It is recommended to check the scripts that you are using before execute it.

## Usage

To use a script, just execute it with:

```shell
make -C path/to/this/directory WORKING_DIR=$(pwd) SCRIPTS='path/to/script/relative/to/this/directory' run
```

It is possible to interactively select the script by omitting the `SCRIPTS` argument:

```shell
make -C path/to/this/directory WORKING_DIR=$(pwd) run
```

You can also create an alias to run the Makefile. Example:

```shell
alias custom-script='make -C path/to/this/directory WORKING_DIR=$(pwd)'

custom-script run
```
