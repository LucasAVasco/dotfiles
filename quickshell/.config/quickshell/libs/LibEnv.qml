pragma Singleton

import Quickshell

Singleton {
    readonly property bool is_wayland: {
        return Quickshell.env("WAYLAND_DISPLAY") != null;
    }

    readonly property bool is_debug: {
        return Quickshell.env("DEBUG") != null;
    }
}
