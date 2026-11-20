import QtQuick
import Quickshell.Io

import "../theme"
import "../ui"

IconButton {
    id: root

    required property string command
    required property string label

    icon: label
    iconSize: 14
    buttonSize: 26
    iconColor: Theme.textSecondary

    Process {
        id: proc
        command: ["sh", "-c", root.command]
    }

    onClicked: proc.startDetached()
}
