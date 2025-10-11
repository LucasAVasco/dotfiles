"""Qtile configuration."""

# NOTE(LucasAVasco):  In order to use Qtile with wayland, the user need to be
# in the "seat" group, and `seatd` must to be running: `systemctl enable seatd`

# Copyright message from the original QTile configuration file. {{{

# I based my configuration on the original Qtile configuration file, so I'm
# leaving its copyright message here:
#
# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# end_marker }}}

from __future__ import annotations

import os
import subprocess
from typing import TYPE_CHECKING, cast

from libqtile import bar, hook, layout
from libqtile import qtile as __qtile_indefined
from libqtile.config import Click, Drag, Group, Key, Match, Screen

import margin
import mouse_grow
import sticky

if TYPE_CHECKING:
    from libqtile.core.manager import Layout

if TYPE_CHECKING:
    from libqtile.core.manager import Qtile

from libqtile.lazy import lazy

qtile: Qtile = cast("Qtile", __qtile_indefined)


GROUPS_NAMES = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
GROUPS_KEYS = ["1", "2", "3", "4", "5", "F1", "F2", "F3", "F4", "F5"]
START_TEMPERATURE_FILTER_GROUP = 6
SCREEN_GAPS = 15
VIRTUAL_TERM_MAX = 6  # Wayland only


HOME = os.environ["HOME"]
SUPER = "mod4"
SHIFT = "shift"
CONTROL = "control"
ALT = "mod1"

groups = []
keys = []

# If is running a Wayland session
is_running_in_wayland = False
if os.environ.get("WAYLAND_DISPLAY") is not None:
    is_running_in_wayland = True

# Enables CONTROL + ALT + 1..`VIRTUAL_TERM_MAX` to change to TTY. Place this
# in the beginning of the configuration file. So, if occurred an error in
# the parse of the configuration file, the user already can change to a TTY
# and kill 'Qtile'
if is_running_in_wayland:
    for term_nr in range(1, VIRTUAL_TERM_MAX):
        keys.extend(
            [
                Key([CONTROL, ALT], "F" + str(term_nr), lazy.core.change_vt(term_nr)),
            ],
        )


def run_background(command: list[str]) -> None:
    """Run a command in the background.

    Parameters
    ----------
    command: list[str]
        Command to execute. First element is the command. The others are the
        arguments.

    """
    subprocess.run(command, check=True)  # noqa: S603


# Input devices {{{


wl_input_rules = None

if not is_running_in_wayland:
    run_background([HOME + "/.config/touchpad/setup.sh"])

else:
    from libqtile.backend.wayland import InputConfig

    wl_input_rules = {
        "type:touchpad": InputConfig(dwt=True, tap=True),
    }

# Sets the keyboard layout in Xorg. If running in wayland, the user need to
# set this environment variable: `XKB_DEFAULT_LAYOUT="br"`.
# This can be done in the "/etc/environment" file
if not is_running_in_wayland:
    keyboard_layout = os.environ.get("XKB_DEFAULT_LAYOUT")
    if keyboard_layout is not None:
        run_background(["/bin/setxkbmap", "-layout", keyboard_layout])

# end_marker }}}

# Groups and screens creation {{{

for group_name, group_key in zip(GROUPS_NAMES, GROUPS_KEYS):
    groups.append(Group(group_name))
    keys.extend(
        [
            # Focus to group
            Key([SUPER], group_key, lazy.group[group_name].toscreen()),
            # Move window to group
            Key([SUPER, SHIFT], group_key, lazy.window.togroup(group_name)),
            Key(
                [SUPER, ALT],
                group_key,
                lazy.window.togroup(group_name, switch_group=True),
            ),
        ],
    )

screens = [
    Screen(
        top=bar.Gap(SCREEN_GAPS),
        right=bar.Gap(SCREEN_GAPS),
        left=bar.Gap(SCREEN_GAPS),
        bottom=bar.Gap(SCREEN_GAPS),
        wallpaper=HOME + "/.local/share/wallpaper/wallpaper.jpg",
        wallpaper_mode="stretch",
    ),
]

# Command to update the wallpaper
os.environ["CUSTOM_DESKTOP_SET_WALLPAPAER_COMMAND"] = (
    "qtile cmd-obj -o screen -f set_wallpaper "
    "-a ~/.local/share/wallpaper/wallpaper.jpg stretch"
)

# end_marker }}}

# Layouts {{{

default_layout_parameters = {
    "border_focus": "#ff6633",
    "border_normal": "#777777",
    "border_width": 3,
    "margin": margin.LAYOUTS_MARGIN_DIFF,
    "margin_on_single": 0,
}

layouts = [
    layout.Columns(**default_layout_parameters),
    layout.Zoomy(**default_layout_parameters),
    layout.Bsp(**default_layout_parameters),
    layout.MonadTall(**default_layout_parameters),
    layout.MonadWide(**default_layout_parameters),
    layout.Spiral(**default_layout_parameters),
    layout.RatioTile(**default_layout_parameters),
    layout.Tile(**default_layout_parameters),
    layout.Max(**default_layout_parameters),
    layout.Stack(**default_layout_parameters, num_stacks=2),
    layout.Stack(**default_layout_parameters, num_stacks=3),
]

floating_layout = layout.Floating(
    **default_layout_parameters,
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="launcher"),
    ],
)

# end_marker }}}

# Key mappings {{{


@lazy.function
def reset_window_state(qtile: Qtile) -> None:
    """Reset the current window state to the default one.

    Disables floating, full screen and sticky mode.
    """
    window = qtile.current_window

    if window is None:
        return

    window.disable_floating()
    window.disable_fullscreen()
    sticky.disable_window_sticky(window)


# List of all keybinds:
# https://github.com/qtile/qtile/blob/master/libqtile/backend/x11/xkeysyms.py
keys.extend(
    [
        # Applications {{{
        Key([SUPER], "Return", lazy.spawn("default_term")),
        Key([SUPER], "f", lazy.spawn("default_file_manager")),
        Key(
            [SUPER],
            "w",
            lazy.spawn(HOME + "/.local/dotfiles_bin/default_web_browser"),
        ),
        Key([SUPER], "t", lazy.spawn(HOME + "/.config/rofi/tools/chdesk.sh")),
        Key([SUPER], "a", lazy.spawn(HOME + "/.config/rofi/tools/applications.sh")),
        Key([SUPER], "o", lazy.spawn(HOME + "/.config/rofi/tools/org.sh")),
        Key(
            [SUPER],
            "r",
            lazy.spawn(HOME + "/.local/dotfiles_bin/custom-script-popup"),
        ),
        Key([SUPER, SHIFT], "p", lazy.spawn(HOME + "/.config/rofi/tools/pass.sh")),
        Key([SUPER], "s", lazy.spawn(HOME + "/.config/screenshot/take.sh -c")),
        Key(
            [SUPER, SHIFT],
            "s",
            lazy.spawn(HOME + "/.config/screenshot/take.sh -i -c"),
        ),
        Key(
            [SUPER, SHIFT],
            "Escape",
            lazy.spawn(HOME + "/.config/rofi/tools/session_manager.sh"),
        ),
        # end_marker }}}
        Key([SUPER], "c", lazy.window.kill()),
        Key([SUPER, CONTROL, SHIFT], "q", lazy.shutdown()),
        Key([SUPER, SHIFT], "x", lazy.reload_config()),
        # Movement {{{
        # Focus to direction
        Key([SUPER], "h", lazy.layout.left()),
        Key([SUPER], "j", lazy.layout.down()),
        Key([SUPER], "k", lazy.layout.up()),
        Key([SUPER], "l", lazy.layout.right()),
        Key([SUPER], "g", lazy.layout.next()),
        # Focus to group
        Key([SUPER], "bracketleft", lazy.screen.prev_group()),
        Key([SUPER], "bracketright", lazy.screen.next_group()),
        Key([SUPER], "Backspace", lazy.screen.toggle_group()),
        # Move window to direction
        Key([SUPER, ALT], "h", lazy.layout.shuffle_left()),
        Key([SUPER, ALT], "j", lazy.layout.shuffle_down()),
        Key([SUPER, ALT], "k", lazy.layout.shuffle_up()),
        Key([SUPER, ALT], "l", lazy.layout.shuffle_right()),
        Key([SUPER, ALT], "g", lazy.layout.toggle_split()),
        # Flip to direction
        Key([SUPER, CONTROL], "j", lazy.layout.flip_down()),
        Key([SUPER, CONTROL], "k", lazy.layout.flip_up()),
        Key([SUPER, CONTROL], "h", lazy.layout.flip_left()),
        Key([SUPER, CONTROL], "l", lazy.layout.flip_right()),
        Key([SUPER, CONTROL], "g", lazy.layout.flip()),
        # Resizes in direction
        Key([SUPER, SHIFT], "h", lazy.layout.grow_left()),
        Key([SUPER, SHIFT], "j", lazy.layout.grow_down()),
        Key([SUPER, SHIFT], "k", lazy.layout.grow_up()),
        Key([SUPER, SHIFT], "l", lazy.layout.grow_right()),
        Key([SUPER, SHIFT], "g", lazy.layout.normalize()),
        # end_marker }}}
        # Mouse simulation {{{
        Key([SUPER], "e", lazy.spawn(HOME + "/.config/mouse/scroll.sh 10")),
        Key([SUPER], "u", lazy.spawn(HOME + "/.config/mouse/scroll.sh 10")),
        Key([SUPER], "d", lazy.spawn(HOME + "/.config/mouse/scroll.sh -10")),
        Key([SUPER, SHIFT], "d", lazy.spawn(HOME + "/.config/mouse/scroll.sh 0")),
        # end_marker }}}
        # Node management {{{
        Key([SUPER], "0", reset_window_state()),
        Key([SUPER], "9", lazy.window.toggle_floating()),
        Key([SUPER], "8", lazy.window.toggle_fullscreen()),
        Key([SUPER], "7", sticky.MyLazy.current_window_toggle_sticky()),
        # end_marker }}}
        # Layout {{{
        Key([SUPER, SHIFT], "m", lazy.prev_layout()),
        Key([SUPER], "m", lazy.next_layout()),
        # end_marker }}}
        # Notifications {{{
        Key([SUPER], "n", lazy.spawn(HOME + "/.config/dunst/context-menu.sh")),
        Key([SUPER, SHIFT], "n", lazy.spawn(HOME + "/.config/dunst/dismiss.sh")),
        # end_marker }}}
        # System management {{{
        Key(
            [SUPER],
            "y",
            lazy.spawn(HOME + "/.local/dotfiles_bin/receive-clip-from-sync-folder"),
        ),
        Key(
            [SUPER],
            "p",
            lazy.spawn(HOME + "/.local/dotfiles_bin/send-clip-to-sync-folder"),
        ),
        Key([SUPER, SHIFT], "y", lazy.spawn(HOME + "/.config/clipboard/clear.sh")),
        Key([SUPER], "Delete", lazy.spawn("xkill")),
        Key([SUPER], "z", lazy.spawn(HOME + "/.config/screenlocker/manager.sh toggle")),
        Key(
            [CONTROL, ALT],
            "l",
            lazy.spawn(HOME + "/.config/screenlocker/manager.sh run"),
        ),
        # end_marker }}}
        # Margin {{{
        Key([SUPER, ALT, SHIFT], "m", margin.MyLazy.remove_margin()),
        Key([SUPER, ALT], "m", margin.MyLazy.add_margin()),
        # end_marker }}}
        # Back light {{{
        Key([SUPER], "F6", lazy.spawn("brightnessctl set 5%-")),
        Key([SUPER], "F7", lazy.spawn("brightnessctl set 15%")),
        Key([SUPER], "F8", lazy.spawn("brightnessctl set +5%")),
        # end_marker }}}
        # Sound and volume {{{
        Key([SUPER], "F9", lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")),
        Key([SUPER], "F10", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")),
        Key([SUPER], "F11", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")),
        Key(
            [SUPER],
            "b",
            lazy.spawn(HOME + "/.config/keyboard/sound_emulator.sh toggle"),
        ),
        # end_marker }}}
    ],
)

# end_marker }}}

# Mouse settings {{{

MOUSE_LEFT = "Button1"
MOUSE_CENTER = "Button2"
MOUSE_RIGHT = "Button3"

mouse = [
    Drag(
        [SUPER],
        MOUSE_LEFT,
        lazy.window.set_position(),
        start=lazy.window.get_position(),
    ),
    Click([SUPER], MOUSE_LEFT, lazy.window.disable_floating()),
    # Use the right button to grow the layouts
    Click([SUPER], MOUSE_RIGHT, mouse_grow.MyLazy.reset_delta()),
    Drag([SUPER], MOUSE_RIGHT, mouse_grow.MyLazy.resize_current_window()),
    # Floating motions
    Click([SUPER, ALT], MOUSE_LEFT, lazy.window.bring_to_front()),
    Drag(
        [SUPER, ALT],
        MOUSE_LEFT,
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [SUPER, ALT],
        MOUSE_RIGHT,
        lazy.window.set_size_floating(),
        start=lazy.window.get_size(),
        warp_pointer=True,
    ),
]

# end_marker }}}

# Initialization script
run_background([HOME + "/.config/qtile/init.sh"])


if not is_running_in_wayland:

    @hook.subscribe.layout_change
    def _update_layout_polybar(layout: Layout, _group: Group) -> None:
        """Send the current layout to Polybar."""
        run_background(["polybar-msg", "action", "qtile-layout", "send", layout.name])

    @hook.subscribe.setgroup
    def _update_backlight_filter() -> None:
        """Update the screen temperature."""
        group_num = int(qtile.current_group.name)

        if group_num >= START_TEMPERATURE_FILTER_GROUP:
            run_background(["gammastep", "-P", "-O", "3000"])
        else:
            run_background(["gammastep", "-x"])
