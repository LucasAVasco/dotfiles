"""Manage the margin size of layouts."""

from typing import cast

from libqtile import qtile as __qtile_indefined
from libqtile.core.manager import Qtile
from libqtile.lazy import lazy

qtile: Qtile = cast("Qtile", __qtile_indefined)


LAYOUTS_MARGIN_DIFF = 10


def set_layout_margin(new_size: int) -> None:
    """Set the current layout margin in pixels.

    Only applies to the current layout of the current group.

    Parameters
    ----------
    new_size: int
        New layout margin size.

    """
    layout = qtile.current_layout

    # Do not hard coded "margin" because of a type checking error. Not all
    # layouts have the margin property. This triggers the following error:
    # "Layout" has no attribute "margin" mypy (attr-defined)
    margin_str = "margin"

    if hasattr(layout, margin_str):
        setattr(layout, margin_str, new_size)

    layout.cmd_reset()


def add_layout_margin(size_diff: int) -> None:
    """Add some value to the current layout margin.

    Only applies to the current layout of the current group.

    Parameters
    ----------
    size_diff: int
        Difference to be applied to the current layout. A positive value decreases the
        margin size. A negative value decreases the margin size.

    """
    layout = qtile.current_layout
    set_layout_margin(max(0, layout.margin + size_diff))


class MyLazy:
    """Lazy functions to manage windows margin."""

    @lazy.function
    @staticmethod
    def add_margin(_qtile: Qtile) -> None:
        """Add `LAYOUTS_MARGIN_DIFF` pixels to the layout margin.

        Only applies to the current layout of the current group.
        """
        add_layout_margin(LAYOUTS_MARGIN_DIFF)

    @lazy.function
    @staticmethod
    def remove_margin(_qtile: Qtile) -> None:
        """Remove `LAYOUTS_MARGIN_DIFF` pixels from the layout margin.

        Only applies to the current layout of the current group.
        """
        add_layout_margin(-LAYOUTS_MARGIN_DIFF)
