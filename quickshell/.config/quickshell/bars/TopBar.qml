import QtQuick
import QtQuick.Layouts
import Quickshell

import "../components"
import "./audio"
import "./clock"
import "./config"
import "./window_title"
import "./workspaces"

PanelWindow {
    id: root

    focusable: true // Required by system tray widget to get keyboard modifiers

    // Layout
    implicitHeight: 30
    anchors {
        top: true
        left: true
        right: true
    }

    // Appearance
    color: Colors.background

    Item {
        // Layout
        anchors.fill: parent
        anchors.margins: 5
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        // Widgets at the left
        RowLayout {
            anchors.left: parent.left

            WorkSpaces {}

            Space {
                size: root.height
            }

            WindowTitle {}
        }

        // Widgets at the center
        RowLayout {
            anchors.centerIn: parent

            ShellCmdButton {
                label: "󰌧"
                command: "~/.config/quickshell/manager.sh run launcher"
            }

            ShellCmdButton {
                label: ""
                command: "~/.config/rofi/tools/chdesk.sh"
            }

            ShellCmdButton {
                label: "󰖲"
                command: "~/.config/rofi/tools/windows.sh"
            }

            ShellCmdButton {
                label: "󰆍"
                command: "default_term"
            }
        }

        // Widgets at the right
        RowLayout {
            anchors.right: parent.right

            TrayArea {
                menuParentWindow: root

                // Layout
                implicitHeight: parent.height
                implicitWidth: root.width / 10
            }

            Clock {}

            Space {
                size: root.height
            }

            Volume {}

            ShellCmdButton {
                label: "󰌾"
                command: "~/.config/screenlocker/manager.sh run"
            }

            Space {
                size: root.height
            }

            ShellCmdButton {
                label: "⏻"
                command: "~/.config/quickshell/manager.sh run sessions"
            }
        }
    }
}
