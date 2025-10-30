pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    signal triggered
    property date now: new Date()

    Timer {
        interval: 1000 * 60 // 1 minute
        repeat: true
        running: true

        onTriggered: {
            root.now = new Date();
            root.triggered();
        }
    }
}
