import QtQuick

import "../../libs"

Loader {
    Component.onCompleted: {
        if (LibEnv.is_wayland) {
            source = Qt.resolvedUrl("./backends/Hyprland.qml");
        } else {} // TODO(LucasAVasco): Add support for X11
    }
}
