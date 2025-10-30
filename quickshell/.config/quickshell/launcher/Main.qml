pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io

import "../libs"
import "../components"

ShellRoot {
    TempItem {
        id: lazyLoader
        source: Qt.resolvedUrl("./AppLauncher.qml")
    }

    // Receives the requests to show the launcher
    IpcHandler {
        target: "launcher"

        function showLauncher() {
            lazyLoader.load();
        }
    }
}
