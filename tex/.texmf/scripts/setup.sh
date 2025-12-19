#!/bin/bash
#
# Setups all dependencies required to build a document.

set -e

python -m venv .venv
source .venv/bin/activate
pip3 install pygments catppuccin # Required by my Minted setup
