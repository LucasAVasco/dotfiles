#!/bin/bash


# Uses the hooks in the template directory instead of the default ones, so does not need to update the hooks in the local repositories
# every time the hooks in the template directory are updated
git config --global core.hooksPath ~/.config/git/template/hooks
