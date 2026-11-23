#!/bin/env python3

"""Gets the names of all keyboards devices separated by new lines."""

import subprocess
import json

# Gets the devices as a JSON
result = subprocess.run(
    ["hyprctl", "devices", "-j"], capture_output=True, text=True, check=True
)

# Reads the output
data = json.loads(result.stdout)
for keyboad in data["keyboards"]:
    # Extracts the name
    name = keyboad["name"]
    name = name.split(":")[0]  # Removes the PID (everything after the ':')
    print(name)
