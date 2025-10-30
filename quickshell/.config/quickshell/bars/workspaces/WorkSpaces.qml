import QtQuick

import "../../libs"

Loader {
    id: barLoader

    Component.onCompleted: {
        if (LibEnv.is_wayland) {
            source = Qt.resolvedUrl("./backends/Hyprland.qml");
        } else {} // TODO(LucasAVasco): add X11 support
    }
}
