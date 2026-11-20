pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Io

import "../../components"
import "../../theme"

Rectangle {
    id: root
    visible: capslock.active

    implicitWidth: capsRow.implicitWidth + Theme.spaceLg * 2
    implicitHeight: 30
    radius: Theme.radiusPill
    color: Theme.warningSubtle
    border.width: 1
    border.color: Theme.warningBorder

    RowLayout {
        id: capsRow
        anchors.centerIn: parent
        spacing: Theme.spaceXs

        Text {
            text: "󰪛"
            font.family: Theme.fontIcon
            font.pixelSize: 13
            color: Theme.warning
        }

        Text {
            text: "Caps Lock is on"
            font.family: Theme.fontSans
            font.pixelSize: Theme.fontXs
            font.weight: Font.Medium
            color: Theme.warning
        }
    }

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
