#!/bin/bash
#
# Updates the permissions of the shared folder.

shared_folder=/home/shared_folder/

chgrp -R shared_folder "$shared_folder" 2> /dev/null
chmod -R u=rwX,g=rwXs,o= "$shared_folder" 2> /dev/null

exit 0  # Returns with a success code
