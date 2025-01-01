"""Manage the width and height of Qtile layouts with the mouse.

Not all layouts implements the grow operation. In order to do it, the method must
implement the :func:`grow_down()`, :func:`grow_up()`, :func:`grow_left()`,
:func:`grow_right()`, methods.

Add two lazy functions that allows the user to manage the size of some tiling layouts
with the mouse. If you want to re-size floating windows, use the
:func:`lazy.window.set_size_floating()` function. The functions provided by this module
only re-sizes tilling windows.

Every time the user starts the re-sizing, the function :func:`reset_delta()` need to be
called. The function that effectively re-sizes the tilling window is the
:func:`resize_current_window()`.

You can configure these functions with the following snippet:

.. code-block:: python

    SUPER = 'mod4'
    MOUSE_RIGHT = 'Button3'

    mouse = [
        # Use the right button to grow the layouts
        Click([SUPER], MOUSE_RIGHT, mouse_grow.reset_delta),
        Drag([SUPER], MOUSE_RIGHT, mouse_grow.resize_current_window),
    ]


How it works
============

When re-sizing a tilled window, this module gets the difference between the current
position of the mouse and the last one that triggered a grow operation. This difference
is named *delta*. If this delta exceeds a maximum value, it will execute a grow in the
increased direction and save the last position to be used in the next comparison.

The maximum value is defined by the :param:`layout_deltas` that is a dictionary. It maps
the layout name to a tuple of type: (max_delta_x, max_delta_y). If the current layout
name is not in this map, uses the :param:`fallback_delta` pair. The user can override
these values after load the module.

The grow method in layouts does not receive a size, so it is not possible to define the
exact size of a grow operation. The only way I've found to manage the size of the grow
operation is to change the maximum value that triggers it. If the user increases the
value of :param:`layout_deltas` and :param:`fallback_delta`, there will be less growth
operation due to mouse position difference. The grow speed is inversely proportional to
the delta parameter.
"""


from libqtile.core.manager import Qtile
from libqtile.lazy import lazy

layout_deltas = {
    "Columns": (60, 30),
    "Bsp": (60, 30),
}

fallback_delta = (60, 30)


# Last delta that caused a grow operation. The values of X axis and Y axis are
# independent. So it is possible that occurs a grow operation that changes only the X
# axes dimension. This operation will update only the X axes in this variable
# (_last_delta[0]).
_last_delta = [0, 0]


class MyLazy:
    """Lazy functions to manage mouse grow operations."""

    @lazy.function
    @staticmethod
    def reset_delta(_qtile: Qtile) -> None:
        """Reset the last delta.

        Every time the user starts a new re-size operation, the provided values to
        'delta_x' and 'delta_y' in the :func:`resize_current_window` function are 0. So
        the last delta saved also need to be zero.
        """
        global _last_delta  # noqa: PLW0603

        _last_delta = [0, 0]

    @lazy.function
    @staticmethod
    def resize_current_window(qtile: Qtile, delta_x: int, delta_y: int) -> None:
        """Re-size the current tilled window.

        Receives the mouse position *delta_x* and *delta_y*, and calculates the
        difference of the received position and the last saved one. If this difference
        exceeds the maximum value, makes a growth operation and saves the current
        position as the last one (only saves the axes that triggered the growth
        operation).

        The received positions need to be relative to the first one provided.So the
        initial position (first received during the re-size operation) need to be zero.
        Because of this, do not add: 'start=lazy.window.get_position()' to the 'Drag()'
        object in the mouse configuration.

        Does not re-size floating windows. Use the
        :func:`lazy.window.set_size_floating()` function instead.
        """
        global _last_delta  # noqa: PLW0602
        global fallback_delta  # noqa: PLW0602

        # Difference between the current position and the last one that caused a grow
        delta = [delta_x - _last_delta[0], delta_y - _last_delta[1]]

        # Maximum values (x and y) of 'delta' before doing a grow in the window
        delta_before_grow: tuple[int, int] = fallback_delta

        layout_name = qtile.current_layout.name
        if isinstance(layout_name,
                      str) and qtile.current_layout.name in layout_deltas:
            delta_before_grow = layout_deltas[layout_name]

        # Checks the X axes. It it exceeds the maximum delta, makes a growth operation
        # and updates the X axes in the last delta variable
        if delta[0] > delta_before_grow[0]:
            if callable(qtile.current_layout.grow_right):
                qtile.current_layout.grow_right()
            _last_delta[0] = delta_x

        elif delta[0] < -delta_before_grow[0]:
            if callable(qtile.current_layout.grow_left):
                qtile.current_layout.grow_left()
            _last_delta[0] = delta_x

        # Checks the Y axes. If it exceeds the maximum delta, makes a growth operation
        # and updates the Y axes in the last delta variable
        if delta[1] > delta_before_grow[1]:
            if callable(qtile.current_layout.grow_down):
                qtile.current_layout.grow_down()
            _last_delta[1] = delta_y

        elif delta[1] < -delta_before_grow[1]:
            if callable(qtile.current_layout.grow_up):
                qtile.current_layout.grow_up()
            _last_delta[1] = delta_y
