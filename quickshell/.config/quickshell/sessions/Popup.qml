import QtQuick
import Quickshell
import Quickshell.Io

import "../libs"

PanelWindow {
    id: root
    color: "transparent"

    focusable: true // Required by list view widgets

    signal done

    // Layout
    anchors {
        left: true
        right: true
        bottom: true
        top: true
    }

    margins {
        left: Math.max(screen.width / 50, 10)
        right: Math.max(screen.width / 50, 10)
    }

    // Exits the PopUp if clicking outside of the button list
    MouseArea {
        anchors.fill: parent

        onClicked: {
            root.done();
        }
    }

    // Runs the selected command
    Process {
        id: proc

        property string commandString: ""

        command: {
            if (LibEnv.is_debug) {
                return ["notify-send", "QuickShell", "Popup button command: " + proc.commandString];
            } else {
                return ["sh", "-c", proc.commandString];
            }
        }
    }

    // The list of buttons
    ButtonList {
        id: buttonRow

        // Layouts
        implicitWidth: root.width
        anchors.centerIn: parent
        anchors.leftMargin: 10
        anchors.rightMargin: anchors.leftMargin

        // Signals
        onSelected: function (button) {
            proc.commandString = button.command;
            proc.startDetached();
            root.done();
        }

        // Handles all key events
        focus: true
        Keys.onPressed: function (event) {
            switch (event.key) {
            // Abort
            case Qt.Key_Escape:
                root.done();
                break;

            // Accept
            case Qt.Key_Enter:
            case Qt.Key_Return:
                buttonRow.executeCurrentButton();
                root.done();
                break;

            // Move left
            case Qt.Key_Left:
            case Qt.Key_Up:
            case Qt.Key_A:
            case Qt.Key_W:
            case Qt.Key_H:
            case Qt.Key_K:
                buttonRow.prevButton();
                break;

            // Move right
            case Qt.Key_Right:
            case Qt.Key_Down:
            case Qt.Key_D:
            case Qt.Key_S:
            case Qt.Key_L:
            case Qt.Key_J:
                buttonRow.nextButton();
                break;
            }
        }
    }
}
