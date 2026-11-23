#!/bin/python3

import sys
import socket
import urllib.parse

sys.stdout.write(
    f"\033]7;file://{socket.gethostname()}{urllib.parse.quote(sys.argv[1])}\033\\"
)
