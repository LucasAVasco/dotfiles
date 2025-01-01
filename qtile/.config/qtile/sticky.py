"""Sticky window feature.

You can set a window as stick with the :func:`enable_window_sticky`,
:func:`disable_window_sticky` and :func:`toggle_window_sticky` functions. There are a
lazy versions of these functions (see :class:`MyLazy`).
"""

from __future__ import annotations

from typing import TYPE_CHECKING

from libqtile import hook

if TYPE_CHECKING:
    from libqtile.backend.base import Window
    from libqtile.core.manager import Qtile
from libqtile.lazy import lazy as qtile_lazy

_enabled_windows: list[Window] = []


def enable_window_sticky(window: Window | None) -> None:
    """Enable window stick mode at the provided window.

    Parameters
    ----------
    window: Window | None
        This window will become sticky.

    """
    global _enabled_windows  # noqa: PLW0602

    if window is not None:
        _enabled_windows.append(window)


def disable_window_sticky(window: Window | None) -> None:
    """Disable window stick mode at the provided window.

    Parameters
    ----------
    window: Window | None
        This window will become non-sticky.

    """
    global _enabled_windows  # noqa: PLW0602

    if window in _enabled_windows:
        _enabled_windows.remove(window)


def toggle_window_sticky(window: Window | None) -> None:
    """Toggle window stick mode at the provided window.

    Parameters
    ----------
    window: Window | None
        This window will become sticky if it is non-stick, or it will become non-sticky
        if it is sticky.

    """
    global _enabled_windows  # noqa: PLW0602

    if window is not None:
        if window in _enabled_windows:
            _enabled_windows.remove(window)

        else:
            _enabled_windows.append(window)


class MyLazy:
    """Lazy functions to manage sticky windows."""

    @qtile_lazy.function
    @staticmethod
    def current_window_enable_sticky(qtile: Qtile) -> None:
        """Enable current window stick mode."""
        window = qtile.current_window
        enable_window_sticky(window)

    @qtile_lazy.function
    @staticmethod
    def current_window_disable_sticky(qtile: Qtile) -> None:
        """Disable current window stick mode."""
        window = qtile.current_window
        disable_window_sticky(window)

    @qtile_lazy.function
    @staticmethod
    def current_window_toggle_sticky(qtile: Qtile) -> None:
        """Toggle current window stick mode."""
        window = qtile.current_window
        toggle_window_sticky(window)


@hook.subscribe.setgroup
def _send_stick_window_to_current_group() -> None:
    """Send all stick windows to the current group."""
    global _enabled_windows  # noqa: PLW0602

    for window in _enabled_windows:
        window.togroup()


@hook.subscribe.client_killed
def _remove_window_enabled_list(killed_window: Window) -> None:
    """Remove the killed windows from the stick windows list.

    Parameters
    ----------
    killed_window: Window
        Window that has been killed and should be removed from the sticky windows list.

    """
    global _enabled_windows  # noqa: PLW0602

    if killed_window in _enabled_windows:
        _enabled_windows.remove(killed_window)
