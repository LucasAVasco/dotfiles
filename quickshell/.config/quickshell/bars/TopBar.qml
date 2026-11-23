import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

import "../services"
import "../theme"
import "../ui"
import "./audio"
import "./bluetooth"
import "./clock"
import "./display"
import "./media"
import "./network"
import "./power"
import "./sysmon"
import "./window_title"
import "./workspaces"

PanelWindow {
    id: root

    implicitHeight: Theme.topBarHeight
    anchors {
        top: true
        left: true
        right: true
    }

    color: Theme.panelBg

    // Subtle bottom hairline border
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: Theme.borderSubtle
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: Theme.spaceSm
        anchors.rightMargin: Theme.spaceSm

        // =====================================================================
        // Left: System Menu Trigger + Workspaces + Active Window Title
        // =====================================================================
        RowLayout {
            id: leftRow
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spaceSm

            // Top-left GNOME-inspired System Menu button
            Rectangle {
                id: sysMenuBtn
                readonly property bool isOpen: ShellState.activePopover === "systemMenu"
                readonly property bool hovered: sysMouse.containsMouse

                implicitHeight: 26
                implicitWidth: sysRow.implicitWidth + Theme.spaceMd * 2
                radius: Theme.radiusPill
                antialiasing: true
                color: {
                    if (isOpen)
                        return Theme.accentSubtle;
                    if (sysMouse.pressed)
                        return Theme.pressedBg;
                    if (hovered)
                        return Theme.hoverBg;
                    if (PowerService.hasScheduledAction)
                        return Theme.warningSubtle;
                    return "transparent";
                }
                border.width: (isOpen || PowerService.hasScheduledAction) ? 1 : 0
                border.color: isOpen ? Theme.accentBorder : Theme.warningBorder

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animFast
                    }
                }

                RowLayout {
                    id: sysRow
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: "󰐥"
                        font.family: Theme.fontIcon
                        font.pixelSize: 14
                        color: {
                            if (sysMenuBtn.isOpen)
                                return Theme.accentHover;
                            if (PowerService.hasScheduledAction)
                                return Theme.warning;
                            return Theme.textPrimary;
                        }
                    }

                    // Compact scheduled indicator badge
                    Text {
                        visible: PowerService.hasScheduledAction && PowerService.remainingText.length > 0
                        text: PowerService.remainingText
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontXs
                        font.weight: Font.DemiBold
                        color: Theme.warning
                    }
                }

                Process {
                    id: sessionManagerProc
                    command: ["sh", "-c", "~/.config/custom-desktop/session-manager.sh"]
                }

                MouseArea {
                    id: sysMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        ShellState.activeScreen = root.screen;
                        sessionManagerProc.startDetached();
                    }
                }
            }

            // Workspaces pill container
            Rectangle {
                implicitHeight: 26
                implicitWidth: workspacesLoader.implicitWidth + Theme.spaceMd
                radius: Theme.radiusPill
                color: Theme.subtleBg

                WorkSpaces {
                    id: workspacesLoader
                    anchors.centerIn: parent
                }
            }

            // Active window title
            WindowTitle {
                Layout.maximumWidth: Math.max(120, Math.min(340, root.width * 0.22))
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // =====================================================================
        // Center: Interactive Clock & Notification Center Trigger
        // =====================================================================
        Clock {
            anchors.centerIn: parent
            barScreen: root.screen
        }

        // =====================================================================
        // Right: Quick Launchers + System Tray + Volume + Lock
        // =====================================================================
        RowLayout {
            id: rightRow
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spaceXs

            // Preserved quick-launch buttons
            RowLayout {
                spacing: 2

                ShellCmdButton {
                    label: "󰌧"
                    command: "~/.config/quickshell/manager.sh run launcher"
                }

                ShellCmdButton {
                    label: ""
                    command: "~/.config/custom-desktop/chdesk-ui.sh"
                }

                ShellCmdButton {
                    label: "󰖲"
                    command: "~/.config/custom-desktop/windows-ui.sh"
                }

                ShellCmdButton {
                    label: "󰆍"
                    command: "default_term"
                }
            }

            Separator {
                visible: trayArea.hasItems
                vertical: true
                Layout.preferredHeight: 16
                Layout.leftMargin: 2
                Layout.rightMargin: 2
            }

            TrayArea {
                id: trayArea
                menuParentWindow: root
                Layout.alignment: Qt.AlignVCenter
            }

            Separator {
                vertical: true
                Layout.preferredHeight: 16
                Layout.leftMargin: 2
                Layout.rightMargin: 2
            }

            MediaButton {
                barScreen: root.screen
            }

            SysMonButton {
                barScreen: root.screen
            }

            Separator {
                vertical: true
                Layout.preferredHeight: 16
                Layout.leftMargin: 2
                Layout.rightMargin: 2
            }

            Volume {
                barScreen: root.screen
            }

            DisplayButton {
                barScreen: root.screen
            }

            NetworkButton {
                barScreen: root.screen
            }

            BluetoothButton {
                barScreen: root.screen
            }

            PowerButton {
                barScreen: root.screen
            }

            ShellCmdButton {
                label: "󰌾"
                command: "~/.config/screenlocker/manager.sh run"
            }
        }
    }
}
