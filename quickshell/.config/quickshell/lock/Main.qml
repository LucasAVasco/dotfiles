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

        onDone: {
            // Sometimes the bars are not rendered after the locker is done. We reload them after some time to make sure they are rendered
            Quickshell.execDetached({
                command: ["bash", "-c", "~/.config/quickshell/lock/scripts/reload-bars.sh"]
            });
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
