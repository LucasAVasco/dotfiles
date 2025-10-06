"""Library to manage dark mode."""

from typing import Any, cast

from qutebrowser.api import cmdutils, message  # type: ignore[import-untyped]

from .completion import bool_completion

this_c: Any = None


def config(c: object) -> None:
    """Configure the 'c' variable to be used in this module."""
    global this_c  # noqa: PLW0603
    this_c = c


def get_dark_mode() -> bool:
    """Get the dark mode."""
    return cast("bool", this_c.colors.webpage.darkmode.enabled)


def set_dark_mode(*, enabled: bool) -> None:
    """Set the dark mode.

    Parameters
    ----------
    enabled : bool
        True to enable dark mode, False to disable it.

    """
    this_c.colors.webpage.darkmode.enabled = enabled


def toggle_dark_mode() -> None:
    """Toggle dark mode."""
    set_dark_mode(enabled=not get_dark_mode())


def create_commands() -> None:
    """Create the user commands.

    Create the `set-darkmode` and `toggle-darkmode` commands.
    """

    @cmdutils.register(name="set-darkmode")  # type: ignore[misc]
    @cmdutils.argument("enabled", choices=["true", "false"], completion=bool_completion)  # type: ignore[misc]
    def set_darkmode_command(enabled: str) -> None:
        """Toggle dark mode."""
        if enabled not in ("true", "false"):
            message.error(f"Invalid value: {enabled}")

        set_dark_mode(enabled=enabled == "true")

    @cmdutils.register(name="toggle-darkmode")  # type: ignore[misc]
    def toggle_darkmode_command() -> None:
        """Toggle dark mode."""
        toggle_dark_mode()
