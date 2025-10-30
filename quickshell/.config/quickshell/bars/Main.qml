import QtQuick
import Quickshell
import Quickshell.Io

import "../libs"

ShellRoot {
    id: root

    function reload() {
        loader.source = "";
        loader.source = Qt.resolvedUrl("./Bars.qml");
    }

    Loader {
        id: loader
        source: ""
    }

    // Receives the requests to show the bars
    IpcHandler {
        target: "bars"

        function reload() {
            root.reload();
        }
    }

    // Starts with the bars loaded
    Component.onCompleted: root.reload()
}
