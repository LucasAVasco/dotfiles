#!/bin/bash
#
#
# Checkout all submodules to the first temporary branch found. Uses the '../checkout_tmp_branch.sh' script


set -e


top_dir=$(realpath -m -- "$0/../../")
git submodule foreach "${top_dir}/checkout_tmp_branch.sh"
