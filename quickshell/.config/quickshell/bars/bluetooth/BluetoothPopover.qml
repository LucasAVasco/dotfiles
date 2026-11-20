pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth

import "../../services"
import "../../theme"
import "../../ui"

PanelWindow {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property bool isOpen: ShellState.activePopover === "bluetooth" && adapter !== null

    onIsOpenChanged: {
        if (isOpen) {
            btSwitch.forceActiveFocus();
        } else if (adapter && adapter.discovering) {
            adapter.discovering = false;
        }
    }

    screen: ShellState.resolveScreen(ShellState.activeScreen)
    visible: isOpen
    focusable: true
    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: ShellState.closePopovers()
    }

    Surface {
        elevation: "popover"
        radius: Theme.radiusXl
        border.color: Theme.borderDefault

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: Theme.topBarHeight + 8
        anchors.rightMargin: 12

        width: Math.min(340, root.width - 24)
        height: Math.min(btFlick.contentHeight + Theme.spaceLg * 2, root.height - Theme.topBarHeight - 32)

        opacity: root.isOpen ? 1.0 : 0.0
        transform: Translate {
            y: root.isOpen ? 0 : -8

            Behavior on y {
                NumberAnimation {
                    duration: Theme.animNormal
                    easing.type: Easing.OutCubic
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            anchors.fill: parent
        }

        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Escape) {
                event.accepted = true;
                ShellState.closePopovers();
            }
        }

        Flickable {
            id: btFlick
            anchors.fill: parent
            anchors.margins: Theme.spaceLg
            contentWidth: width
            contentHeight: btCol.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: btCol
                width: btFlick.width
                spacing: Theme.spaceMd

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spaceSm

                    Text {
                        text: "Bluetooth"
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontLg
                        font.weight: Font.DemiBold
                        color: Theme.textPrimary
                        Layout.fillWidth: true
                    }

                    IconButton {
                        visible: root.adapter !== null && root.adapter.enabled
                        icon: root.adapter && root.adapter.discovering ? "󰓛" : "󰑐"
                        iconSize: 14
                        buttonSize: 28
                        active: root.adapter !== null && root.adapter.discovering
                        onClicked: {
                            if (root.adapter)
                                root.adapter.discovering = !root.adapter.discovering;
                        }
                    }

                    SwitchControl {
                        id: btSwitch
                        checked: root.adapter !== null && root.adapter.enabled
                        onToggled: function (state) {
                            if (root.adapter)
                                root.adapter.enabled = state;
                        }
                    }
                }

                Text {
                    visible: root.adapter !== null && !root.adapter.enabled
                    text: "Bluetooth is turned off"
                    font.family: Theme.fontSans
                    font.pixelSize: Theme.fontSm
                    color: Theme.textMuted
                    Layout.alignment: Qt.AlignHCenter
                }

                ColumnLayout {
                    visible: root.adapter !== null && root.adapter.enabled
                    Layout.fillWidth: true
                    spacing: 4

                    Repeater {
                        model: root.adapter ? root.adapter.devices.values : []

                        delegate: Rectangle {
                            required property BluetoothDevice modelData
                            Layout.fillWidth: true
                            implicitHeight: 44
                            radius: Theme.radiusMd
                            color: modelData.connected ? Theme.accentSubtle : Theme.surfaceRaised
                            border.width: 1
                            border.color: modelData.connected ? Theme.accentBorder : Theme.borderSubtle

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.spaceMd
                                anchors.rightMargin: Theme.spaceSm
                                spacing: Theme.spaceSm

                                Text {
                                    text: modelData.connected ? "󰂱" : "󰂯"
                                    font.family: Theme.fontIcon
                                    font.pixelSize: 15
                                    color: modelData.connected ? Theme.accentHover : Theme.textSecondary
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1

                                    Text {
                                        text: modelData.name || "Bluetooth Device"
                                        font.family: Theme.fontSans
                                        font.pixelSize: Theme.fontSm
                                        font.weight: modelData.connected ? Font.DemiBold : Font.Normal
                                        color: Theme.textPrimary
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: modelData.connected ? "Connected" : (modelData.pairing ? "Pairing…" : (modelData.paired ? "Paired" : "Available"))
                                        font.family: Theme.fontSans
                                        font.pixelSize: Theme.fontXs
                                        color: modelData.connected ? Theme.accentHover : Theme.textMuted
                                    }
                                }

                                ActionButton {
                                    text: modelData.connected ? "Disconnect" : (modelData.paired ? "Connect" : "Pair")
                                    compact: true
                                    variant: modelData.connected ? "secondary" : "primary"
                                    onClicked: {
                                        if (modelData.connected)
                                            modelData.disconnect();
                                        else if (modelData.paired)
                                            modelData.connect();
                                        else
                                            modelData.pair();
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        visible: !root.adapter || root.adapter.devices.values.length === 0
                        text: (root.adapter && root.adapter.discovering) ? "Searching for devices…" : "No Bluetooth devices found"
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontSm
                        color: Theme.textMuted
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: Theme.spaceSm
                    }
                }
            }
        }
    }
}
