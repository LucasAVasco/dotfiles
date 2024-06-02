#!/bin/bash
#
#
# Configuration specific to non-root, non-sudo, non-admin users. If this file is executed by an invalid user, it will be ignored


#region Restrict access to non-root, non-sudo, non-admin users

# Prevent running as root (or sudo)
id | grep '^uid=0(root)' > /dev/null 2> /dev/null && return

# Prevent running as a user with sudo access
[[ "$(groups)" == *sudo* ]] && return

# Prevent running as the 'admin' user
[[ "$USER" == 'admin' ]] && return

#endregion


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
