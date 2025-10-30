import QtQuick
import Quickshell.Io

import "./config"

Text {
    id: root

    required property string command
    required property string label

    property int size: Math.max(height * 0.5, 10)

    leftPadding: size / 2
    rightPadding: size / 2

    // Appearance
    color: Colors.foreground
    font.pointSize: size
    font.family: Fonts.monoFont

    // Contents
    text: root.label

    // Command execution
    Process {
        id: proc

        command: ["sh", "-c", root.command]
    }

    // Runs the process when the button is clicked
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: () => {
            proc.running = true;
        }
    }
}
