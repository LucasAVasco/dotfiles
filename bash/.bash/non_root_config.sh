#!/bin/bash
#
#
# Configuration specific to non-root, non-sudo, non-admin users. If this file is executed by an invalid user, it will be ignored


# Prevent root, admin and users with sudo to run this script
[[ "$ALLOW_EXTERNAL_SOFTWARE" != "y" ]] && return


# Enables Lesspipe and Lessfile
eval "$(lessfile)"
eval "$(lesspipe)"


# Bash aliases
source ~/.bash/aliases.sh


# Extra software (e.g. ASDF, Conda, etc.)
source ~/.bash/extra_software.sh


# Completion files
test -f /etc/bash_completion && source /etc/bash_completion
test -f /usr/share/bash-completion/bash_completion && source /usr/share/bash-completion/bash_completion
