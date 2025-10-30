pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io

import "../components"

ShellRoot {
    TempItem {
        id: lazyLoader
        source: Qt.resolvedUrl("./Popup.qml")
    }

    // Receives the requests to show the session manager
    IpcHandler {
        target: "sessions"

        function showMenu() {
            lazyLoader.load();
        }
    }
}
