pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io

import "../../components"

Rectangle {
    id: root
    visible: capslock.active

    radius: 10
    color: Qt.rgba(0.0, 0.0, 0.0, 0.5)

    Text {
        anchors.centerIn: parent
        text: "CAPS LOCK"
        color: "white"

        font.pixelSize: Math.max(16, parent.height / 2)
    }

    // Gets the first caps lock device with a bash script and uses this file to check if caps lock is active
    Process {
        running: true
        command: ["bash", "-c", "~/.config/quickshell/lock/scripts/get-first-caps-lock-device.sh"]
        stdout: StdioCollector {
            onStreamFinished: capslock.deviceFile = this.text
        }
    }

    CapsLock {
        id: capslock

        updateInterval: 500
    }
}
