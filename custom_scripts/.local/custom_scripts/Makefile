# This Makefile is used to run custom scripts in the current repository. It allows the user to list and interactively select
# a script to run.
#
# The scripts are in the 'scripts' directory. Files inside a 'lib' directory are not considered scripts to run. So the user
# can place common modules in 'lib/' directories inside the 'scripts/' directory.
#
# To run a script, use the `run` target. The less friendly examples is the following:
#
# ```shell
# make -C path/to/this/directory WORKING_DIR=$(pwd) run
# ```
#
# You can also create an alias to run the script. Example:
#
# ```shell
# alias custom_script='make -C path/to/this/directory WORKING_DIR=$(pwd)'
#
# custom_script run
# ````
#
# To list the scripts, use the `ls` target. You can also open a shell in the scripts base directory with the `cd` target


WORKING_DIR ?= $(shell pwd)
SELECTOR_CMD ?= fzf --preview="bat --color=always '{1}'"
CD_SHELL ?= /bin/bash


g_base_dir = $(shell pwd)


# Run the specified script in the specified working directory
#
# The user need to provide to environment variable:
#
# - SCRIPT: The name of the script to run
# - WORKING_DIR: The working directory in which the script will be run
#
# If the user does not provide the script, this target will be prompted interactively with 'fzf' to select it. But this scripts
# will not prompt the user to provide the working directory. If not provided, the target will use the directory of the Makefile.
#
# After the script is run, this target will show a command that user can use to automatically run the selected script again
run:
	$(if ${SCRIPT}, , ${eval need_show_cmd=1} $(eval SCRIPT=$(shell cd 'scripts/' && find * -type f -not -regex '.*/lib/.*' | ${SELECTOR_CMD})))

	$(if ${SCRIPT}, , $(error Does not provided SCRIPT))

	cd "${WORKING_DIR}" && WORKING_DIR="${WORKING_DIR}" REPO_DIR="${g_base_dir}/" "${g_base_dir}/scripts/${SCRIPT}"
	$(if ${need_show_cmd}, @echo Equivalent command: make -C "'$(shell pwd)'" WORKING_DIR="'${WORKING_DIR}'" SCRIPT="'${SCRIPT}'")


# Shows the base scripts directory
#
# May be used in automation scripts
get-root-dir:
	@pwd


# Run a new instance of the specified shell in the scripts base directory
#
# The user can change the shell with by setting the 'CD_SHELL' variable
cd:
	@cd $(shell pwd) && ${CD_SHELL}


# List all the scripts in the scripts directory. List one script per line
ls:
	@cd scripts && find * -type f -not -regex '.*/lib/.*'


FORCE:
.PHONY: FORCE, Makefile
