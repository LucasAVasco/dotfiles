pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io

import "../components"

ShellRoot {
    TempItem {
        id: lazyLoader
        source: Qt.resolvedUrl("./DesktopSwitcher.qml")
    }

    // Receives requests to open the chdesk desktop switcher
    IpcHandler {
        target: "chdesk"

        function showChdesk() {
            lazyLoader.load();
        }
    }
}
