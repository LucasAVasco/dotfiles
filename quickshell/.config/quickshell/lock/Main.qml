pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

import "../components"

Item {
    TempItem {
        id: lazyLoader

        source: {
            if (true) {
                return Qt.resolvedUrl("./backend/WaylandLocker.qml");
            } else {} // TODO(LucasAVasco): implement X11 locker
        }
    }

    // Receives the lock request
    IpcHandler {
        target: "lock"

        function lockScreen() {
            lazyLoader.load();
        }
    }
}
