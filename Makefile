# This Makefile is used to manage the dot files directory. It is a simple utility that allows the user to list, create, enable
# and disable packages
#
# The dot files are stored as packages in each folder of the current directory. The name of the folder is the name of the package.
# E.g. the folder 'package1' will contains the dot files of the package 'package1'. The user can list the packages with `make ls`
#
# When enabling a package with `make enable`, this Makefile will use Stow to reproduce the package contents in the home directory
# as symbolic links. To disable the packages, use `make disable`. These Makefile targets also allows to enable and disable only
# a specif package with `make enable-<package name>`. E.g. `make enable-package1` will enable the package 'package1'
#
# To create a new package, the user can just create the package in the current directory and the package name will be the name of
# the new folder. There are also the `make create-package` target. It can be used to create a new package, but it also prompts the
# user to create the scripts folder inside the package directory. See the SCRIPTS section for more details
#
# To add a dot file folder (or file) to a package, use the `make add` target. The user need to provide some environment variables
# that defines what file to save and where to save it. See the target description to more information. If the user does not provide
# any of these variables, the user will be prompted interactively with 'fzf' to select them
#
# Files that ends with '.stow' will not be reproduced in the home directory, but remains in the repository and are managed by git
#
# It is also possible to run a new shell in the dot files folder with `make cd`
#
# SCRIPTS
# -------
# Each package can have some scripts that will be executed before or after the package is enabled or disabled. These scripts need to
# be in the '<package name>/${SCRIPTS_SUB_FOLDER}/<script type>' sub folder. Where the script type can be:
#
# * 'before_enable': executed before the package is enabled
# * 'after_enable': executed after the package is enabled
# * 'before_disable': executed before the package is disabled
# * 'after_disable': executed after the package is disabled
# * 'once_before_enable': equivalent to 'before_enable' but only executed once in the current installation
# * 'once_after_enable': equivalent to 'after_enable' but only executed once in the current installation
# * 'once_before_disable': equivalent to 'before_disable' but only executed once in the current installation
# * 'once_after_disable': equivalent to 'after_disable' but only executed once in the current installation
#
# The scripts with 'once_*' type only will be executed once in the current installation. This means that 'once_*_enable' will not be
# executed if the package is already installed, and 'once_*_disable' will not be executed if the package is not installed. To hold the
# installation status, this Makefile will create a file named '.installed.ignore.stow' in the package directory. Packages with this file
# are installed, packages without this file are not installed.
#
# NOTE(LucasAVasco): : When manually manager the packages with Stow, the user need to manually update the '.installed.ignore.stow' file in
# the package directory. Otherwise, some installation scripts will not be executed when a package is enabled or disabled with this script.
#
# TIPS AND TRICKS
# ---------------
# To manage your dot files in any folder, you can add a alias to your shell like this (for bash):
#
# ```bash
# alias dotfiles='make -C ~/.local/dotfiles SD=$(pwd)'
# ```
#
# The '-C' option will change the current directory to the dot files directory to be able to manage them. The 'SD' variable sets the folder
# that the 'add' target will use to search for the source. With 'SD=$(pwd)', the 'add' command will add the dot files in the current
# directory
#
# DEPENDENCIES
# ------------
# - fzf
# - stow
# - find
# - Gmake


# #region Parameters (the user can change)

# Search directory. Where to search for the source when using the 'add' command
SD ?= ${HOME}

# Number of recursive directories to search when using the 'add' command. 1 will only search the current directory, 2 will
# search the current and the first sub directory and so on
SEARCH_DEPTH ?= 10

# Shell to be used with the 'cd' command
CD_SHELL ?= /bin/bash

# #endregion


# Default Stow command to be executed when enabling or disabling a package
STOW_CMD = stow --verbose --ignore='\.stow' --target=${HOME}

# Each file of the current directory (without starting with '.') is a package
PACKAGES = $(wildcard */)

# Name of the sub folder where to search by scripts. Each package will have its own sub folder. E.g. The package 'package1' will rave the
# 'package1/${SCRIPTS_SUB_FOLDER}/<script_folder>' sub folder. Where <script_folder> can be: 'before_enable', 'after_enable',
# 'before_disable', 'after_disable', 'once_before_enable', 'once_after_enable', 'once_before_disable', 'once_after_disable'
SCRIPTS_SUB_FOLDER = scripts.stow


#region Useful canned recipes

# Run some scripts of the package. The user need to provide the package name as $(1) and the script type as $(2).
# This recipe will run all the scripts of this package that are of the specified type
#
# This function is named 'no_once' because it will run the script independently if it has already been executed and should not be executed
# any more. Script types that starts with 'once_' should be run only once, buts this recipe will run the script regardless if it has been
# executed or not
#
# Parameters
# ----------
# $(1): The name of the package
# $(2): The type of the scripts to run
define run_package_no_once_scripts =
	$(eval scripts = $(wildcard $(strip $(1))/${SCRIPTS_SUB_FOLDER}/$(strip $(2))/*))
	$(foreach script,$(scripts), ./$(script); )
endef

# Run some script of the package if the package is installed (it has the '.installed.ignore.stow' file)
#
# Parameters
# ----------
# $(1): The name of the package
# $(2): The type of the script to run
define run_script_if_package_is_installed =
	$(if $(wildcard $(strip $(1))/.installed.ignore.stow), $(call run_package_no_once_scripts, $(1), $(2)))
endef

# Run some script of the package if the package is not installed (it does not have the '.installed.ignore.stow' file)
#
# Parameters
# ----------
# $(1): The name of the package
# $(2): The type of the script to run
define run_script_if_package_is_not_installed =
	$(if $(wildcard $(strip $(1))/.installed.ignore.stow), , $(call run_package_no_once_scripts, $(1), $(2)))
endef

# Run some script of the package. The user need to provide the package name as $(1) and the script type as $(2)
#
# This recipe is equivalent to the 'run_package_no_once_scripts', but only runs the script if it has not been executed in the current
# installation This means that if the user installed a software, the 'once_*_enable' scripts will not be run anymore. And, if the user
# uninstalled the software, the 'once_*_disable' scripts will not be run anymore
#
# Parameters
# ----------
# $(1): The name of the package
# $(2): The type of the script to run
define run_package_once_scripts =
	$(if $(findstring disable, $(2)),
		$(call run_script_if_package_is_installed, $(1), $(2))
		,
		$(call run_script_if_package_is_not_installed, $(1), $(2))
	)
endef


# Run some scripts of the package. The user need to provide the package name as $(1) and the script type as $(2).
#
# This recipe will run the script with 'run_package_once_scripts' if it is a 'once_*' script, otherwise it will run the script with
# 'run_package_no_once_scripts'. This recipe is a generic form of these other two recipes and works for any type of script
#
# $(1): The name of the package
# $(2): The type of the scripts to run
define run_package_scripts =
	$(if $(findstring once_, $(2)), $(call run_package_once_scripts, $(1), $(2)), $(call run_package_no_once_scripts, $(1), $(2)))
endef


# Run the provided scripts types of the provided packages. The user need to provide the list of package names as $(1) and the list of
# script types as $(2). recipe will run all the provided script types of all the provided packages
#
# Parameters
# ----------
# $(1): The list of package names (space separated)
# $(2): The list of the scripts types to run (space separated)
define run_package_scripts_list =
	$(foreach package, $1,
		$(foreach script, $2, $(call run_package_scripts, $(package), $(script)))
	)
endef


# Enable the packages. The user need to provide the list of package names as $(1)
#
# These packaged will be 'restown' in the home directory. Also run all the enable scripts of the provided packages in the correct order
#
# Parameters
# ----------
# $(1): The list of package names (space separated)
define enable_packages =
	$(call run_package_scripts_list, $(1), once_before_enable before_enable)

	$(STOW_CMD) --restow $(1);

	$(call run_package_scripts_list, $(1), once_after_enable after_enable)

	$(foreach package, $(1), > $(package)/.installed.ignore.stow;)
endef


# Disable the packages. The user need to provide the list of package names as $(1)
#
# These packaged will be 'deleted' with Stow from the home directory. Also run all the disable scripts of the provided packages in the
# correct order
#
# Parameters
# ----------
# $(1): The list of package names (space separated)
define disable_packages =
	$(call run_package_scripts_list, $(1), once_before_disable before_disable)

	$(STOW_CMD) --delete $(1);

	$(call run_package_scripts_list, $(1), once_after_disable after_disable)

	$(foreach package, $(1),
		$(if $(wildcard $(package)/.installed.ignore.stow), rm $(package)/.installed.ignore.stow)
	)
endef


# Show a prompt message and get the user input
#
# Parameters
# ----------
# $(1): The prompt message
#
# Returns
# -------
# The user input as a string
get_user_input = $(shell read -p $(strip $(1)) input && echo -n $$input)


# Show a prompt message and get the user input and convert it to a boolean. Its is required to provide the true value. A string that defines
# if the user selected true or false. If this is string can be found in the user response, it will be returned by this recipe. Otherwise, it
# will return a empty string. It is possible to use this recipe with the $(if) command:
#
# $(if $(call get_user_input_bool, 'print true? [y/N] ',y), echo true, echo false)
#
# Parameters
# ----------
# $(1): The prompt message
# $(2): The true string to search in the response and return the value
#
# Returns
# -------
# $(1) if it can be found in the response, otherwise an empty string
get_user_input_bool = $(findstring $(2), $(call get_user_input,$(strip $(1))))


# Interactive prompt to create the scripts folder in the package directory. The user need to provide the package name as $(1) and
# the script type as $(2)
#
# If the user responds 'y', it will create the scripts folder '<package name>/${SCRIPTS_SUB_FOLDER}/<script type>'
#
# Parameters
# ----------
# $(1): The package name (as string)
# $(2): The script type (as string)
define create_script_folder =
	$(if $(call get_user_input_bool, 'Create "$(strip $(2))" scripts folder? [y/N] ',y), mkdir -p '$(strip $(1))/${SCRIPTS_SUB_FOLDER}/$(strip $(2))',)
endef

#endregion


# List all the packages in the dot files directory. List one file per line
ls:
	@find . -maxdepth 1 -type d -regex './\w*' -printf '%f\n'


# Enable all packages
enable: FORCE
	$(call enable_packages, ${PACKAGES})


# Disable all packages
disable: FORCE
	$(call disable_packages, ${PACKAGES})


# Enable a specif package
enable-%: FORCE
	@$(eval PACKAGE=$(patsubst enable-%, %, $@))  # Removes 'enable-' prefix from the target

	$(call enable_packages, ${PACKAGE})


# Disable a specif package
disable-%: FORCE
	@$(eval PACKAGE=$(patsubst disable-%, %, $@))  # Removes 'disable-' prefix from the target

	$(call disable_packages, ${PACKAGE})


# Add a file or directory to a package in the dot files directory. The user need to provide to environment variables:
#
# - SOURCE: The path to the file or directory to be added
# - PACKAGE: The name of the package in which the file or directory will be added
#
# If the user does not provide any of these variables, the user will be prompted interactively with 'fzf' to select them
#
# The dot files will be copied to the new package in the dot files directory. The source folder or file will be renamed
# to '<package name>.dotfiles.bkp'. So the user can enable the package with `make enable-<package name>` afterwards.
# If some error occurred in the process, the source can be restored by renaming it back to its original name
add: FORCE
	@# Gets the SOURCE directory to be added. If a max depth of 10 to find is to low, you can change it wit SEARCH_DEPTH argument
	$(if $(SOURCE), , $(eval SOURCE=$(shell cd '${SD}' && FZF_DEFAULT_COMMAND='find . -maxdepth ${SEARCH_DEPTH}' fzf)))
	$(if $(SOURCE), , $(error Does not provided SOURCE))

	@# Get the PACKAGE directory name
	$(if $(PACKAGE), , $(eval PACKAGE=$(shell FZF_DEFAULT_COMMAND='find . -maxdepth 1 -type d -regex "./\\w*" -printf "%f\\n"' fzf)))
	$(if $(PACKAGE), , $(error Does not provided PACKAGE))

	@# Gets the absolute path of the SOURCE
	$(if ${SOURCE:0:1} != /, $(eval ABS_SRC=${SD}/${SOURCE}), $(eval ABS_SRC=${SOURCE}))

	@# Source directory or file relative to '${HOME}'. Removes the user home from the SOURCE path
	$(eval REL_SRC=$(patsubst ${HOME}/%, %, ${ABS_SRC}))

	@# Where to install the added files (and directory). Is the parent path of the destination of SOURCE. E.g. if SOURCE is
	@# $HOME/.config/software1, and PACKAGE is 'software1', PKG_DIR will be 'software1/.config/'. It is a relative path.
	@# Uses the 'patsubst' function to remove the trailing '/', because the 'dir' function will not return the parent of a directory
	@# with a trailing '/'
	$(eval PKG_DIR=${PACKAGE}/$(dir $(patsubst %/, %, ${REL_SRC})))

	@# Creates the directory to hold the new files and move the SOURCE to its respective place in this directory
	mkdir -p '${PKG_DIR}'
	cp -RL '${ABS_SRC}' '${PKG_DIR}'
	mv '${ABS_SRC}' '${ABS_SRC}.dotfiles.bkp'
	@echo -e 'Added $(strip $(REL_SRC))'
	@echo -e '\033[1;33mThe "$(ABS_SRC)" has been renamed to "$(ABS_SRC).dotfiles.bkp".\033[0;39m'
	@echo -e '\033[1;33mIf the dotfiles are correctly added, "$(ABS_SRC).dotfiles.bkp" can be removed.\033[0;39m'


# Create a package in the dot files directory. The user need to provide to environment variables:
#
# - PACKAGE: The name of the package to be created
#
# If the user does not provide any of these variables, the user will be prompted interactively to add them
#
# Prompt the user if need to automatically create the scripts folder. The user can manually create the directories and scripts files
#
# Prompt the user if the package already exists, but does not stop the process. So the user can run this command to create the script
# folder even if the package already exists
create-package: FORCE
	@# Get the PACKAGE directory name. If not provided, interactively asks for it
	$(if $(PACKAGE), , $(eval PACKAGE=$(call get_user_input, 'Package name: ')))
	$(if $(PACKAGE), , $(error Does not provided PACKAGE))

	@# Shows if the package already exists
	$(if $(wildcard ${PACKAGE}), @echo -e '\033[1;33mPackage already exists\033[0;39m')

	@# Creates the target directory to hold the new files
	mkdir -p '${PACKAGE}'

	@# Creates the scripts folders in the package directory
	$(call create_script_folder, ${PACKAGE}, once_before_enable)
	$(call create_script_folder, ${PACKAGE}, once_after_enable)
	$(call create_script_folder, ${PACKAGE}, once_before_disable)
	$(call create_script_folder, ${PACKAGE}, once_after_disable)
	$(call create_script_folder, ${PACKAGE}, before_enable)
	$(call create_script_folder, ${PACKAGE}, after_enable)
	$(call create_script_folder, ${PACKAGE}, before_disable)
	$(call create_script_folder, ${PACKAGE}, after_disable)


# Shows the base dot files directory
#
# May be used in automation scripts
get-root-dir:
	@pwd


# Run a new instance of the specified shell in the dot files directory
#
# The user can change the shell by setting the 'CD_SHELL' variable
cd:
	@cd $(shell pwd) && ${CD_SHELL}


FORCE:
.PHONY: FORCE
