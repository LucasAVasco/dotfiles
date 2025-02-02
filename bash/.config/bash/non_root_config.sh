#!/bin/bash
#
#
# Configuration specific to non-root, non-sudo, non-admin users. If this file is executed by an invalid user, it will be ignored


# Only runs this script if the user is allowed to install external software
[[ "$ALLOW_EXTERNAL_SOFTWARE" != "y" ]] && return


# Extra software (e.g. ASDF, Conda, etc.)
source ~/.config/bash/extra_software.sh


# Completion files
test -f /etc/bash_completion && source /etc/bash_completion
test -f /usr/share/bash-completion/bash_completion && source /usr/share/bash-completion/bash_completion
