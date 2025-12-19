#!/bin/env python3

"""Formats a CSV file into a csvsimple file.

The formatted file is written to the same path.

Usage
-----
format_csv_to_csvsimple.py [file1.csv] [file2.csv]
"""

import csv
import sys


def format_file(path: str):
    """Formats a CSV file into a csvsimple file.

    The formatted file is written to the same path.

    Parameters
    ----------
    path : str
        The path to the CSV file
    """
    out = ""

    with open(path, newline="") as csvfile:
        spamreader = csv.reader(csvfile, delimiter=",", quotechar='"')

        for row in spamreader:
            out += "{" + row[0] + "}"
            for item in row[1:]:
                out += ",{" + item + "}"
            out += "\r\n"

    # Writes the file
    with open(path, "w") as text_file:
        text_file.write(out)


# Formats each file received as an argument
for i in range(1, len(sys.argv)):
    format_file(sys.argv[i])
