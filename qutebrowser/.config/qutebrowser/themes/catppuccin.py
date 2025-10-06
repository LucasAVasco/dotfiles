"""Installer of Catppuccin theme for Qutebrowser.

Based on the official configuration at
https://github.com/catppuccin/qutebrowser
"""

from __future__ import annotations

import importlib
from pathlib import Path
from typing import Any
from urllib.request import urlopen

this_c: Any = {}
theme_file = Path()


def set_config(c: object, config_dir: Path) -> None:
    """Configure the 'c' and 'config' variables to be used in this module.

    Must be called before any other function.
    """
    global theme_file  # noqa: PLW0603
    global this_c  # noqa: PLW0603
    this_c = c
    theme_file = Path(config_dir / "downloads" / "catppuccin.py")


def download_theme() -> None:
    """Download the catppuccin theme file."""
    # Ensure the folder exists
    top_dir = theme_file.parent
    if not top_dir.exists():
        top_dir.mkdir()

    # Download the theme file
    with (
        urlopen(
            "https://raw.githubusercontent.com/catppuccin/qutebrowser/main/setup.py",
        ) as remote_handler,
        theme_file.open("a") as local_handler,
    ):
        local_handler.writelines(remote_handler.read().decode("utf-8"))


def ensure_theme_downloaded() -> None:
    """Download the catppuccin theme file if necessary."""
    if not theme_file.exists():
        download_theme()


def enable_theme(name: str = "none", *, same_color_rows: bool = True) -> None:
    """Enable a catppuccin theme.

    Automatically downloads the theme files if necessary.

    Parameters
    ----------
    name : str
        The name of the theme to enable. One of 'mocha', 'macchiato', 'frappe',
        'latte' or 'none'.

    same_color_rows : bool
        If True, use the same color for all rows in the command palette.

    """
    ensure_theme_downloaded()

    if theme_file.exists():
        mod = importlib.import_module("downloads.catppuccin")
        mod.setup(this_c, name, same_color_rows)
