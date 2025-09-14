# Based on the official configuration at
# https://github.com/catppuccin/qutebrowser

from __future__ import annotations
from pathlib import Path
from urllib.request import urlopen

this_c = {}
theme_file = Path()


def set_config(c, config):
    """
    Configure the 'c' and 'config' variables to be used in this module.

    Must be called before any other function.
    """
    global theme_file
    global this_c
    this_c = c
    theme_file = Path(config.configdir / "downloads" / "catppuccin.py")


def download_theme():
    theme_url = "https://raw.githubusercontent.com/catppuccin/qutebrowser/" +\
        "main/setup.py"

    # Ensure the folder exists
    top_dir = theme_file.parent
    if not top_dir.exists():
        top_dir.mkdir()

    # Download the theme file
    with urlopen(theme_url) as remote_handler:
        with theme_file.open("a") as local_handler:
            local_handler.writelines(
                remote_handler.read().decode("utf-8"))


def ensure_theme_downloaded():
    if not theme_file.exists():
        download_theme()


def enable_theme(name: str = "none"):
    """
    Enable a catppuccin theme.

    Automatically downloads the theme files if necessary.

    Parameters
    ----------
    name : str
        The name of the theme to enable. One of 'mocha', 'macchiato', 'frappe',
        'latte' or 'none'.
    """
    ensure_theme_downloaded()

    if theme_file.exists():
        import downloads.catppuccin as theme
        theme.setup(this_c, name, True)  # noqa: FBT003
