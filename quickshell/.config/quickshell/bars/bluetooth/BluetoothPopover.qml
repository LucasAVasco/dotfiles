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
    property BluetoothDevice selectedDevice: null

    readonly property var sortedDevices: {
        if (!adapter || !adapter.devices)
            return [];
        let list = [...adapter.devices.values].filter(d => d !== null);
        list.sort((a, b) => {
            let rank = d => {
                if (d.connected)
                    return 0;
                if (d.pairing || d.state === BluetoothDeviceState.Connecting)
                    return 1;
                if (d.paired || d.bonded)
                    return 2;
                return 3;
            };
            let ra = rank(a);
            let rb = rank(b);
            if (ra !== rb)
                return ra - rb;
            let na = (a.name || a.deviceName || a.address || "").toLowerCase();
            let nb = (b.name || b.deviceName || b.address || "").toLowerCase();
            return na.localeCompare(nb);
        });
        return list;
    }

    readonly property BluetoothDevice activeSelectedDevice: (selectedDevice !== null && sortedDevices.indexOf(selectedDevice) >= 0) ? selectedDevice : null

    BluetoothIcons {
        id: btIcons
    }

    onIsOpenChanged: {
        if (isOpen) {
            btSurface.forceActiveFocus();
        } else {
            selectedDevice = null;
            if (adapter && adapter.discovering) {
                adapter.discovering = false;
            }
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
        id: btSurface
        elevation: "popover"
        radius: Theme.radiusXl
        border.color: Theme.borderDefault

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: Theme.topBarHeight + 8
        anchors.rightMargin: 12

        width: Math.min(364, root.width - 24)
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
            if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
                ShellState.markKeyboardNav();
            } else if (event.key === Qt.Key_Escape) {
                event.accepted = true;
                if (root.selectedDevice !== null)
                    root.selectedDevice = null;
                else
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
                    spacing: 6

                    Repeater {
                        model: root.sortedDevices

                        delegate: Rectangle {
                            id: devCard
                            required property BluetoothDevice modelData
                            readonly property int batteryPct: modelData.batteryAvailable ? Math.max(0, Math.min(100, Math.round(modelData.battery * 100))) : -1
                            readonly property bool hasStateIcons: modelData.paired || modelData.bonded || modelData.trusted || modelData.wakeAllowed || modelData.blocked
                            readonly property bool isConnecting: modelData.state === BluetoothDeviceState.Connecting
                            readonly property bool isDisconnecting: modelData.state === BluetoothDeviceState.Disconnecting

                            Layout.fillWidth: true
                            implicitHeight: Math.max(50, devRow.implicitHeight + Theme.spaceSm * 2)
                            radius: Theme.radiusMd
                            antialiasing: true
                            color: {
                                if (cardMouse.pressed)
                                    return Theme.pressedBg;
                                if (modelData.connected)
                                    return Theme.accentSubtle;
                                if (cardMouse.containsMouse)
                                    return Theme.hoverBg;
                                return Theme.surfaceRaised;
                            }
                            border.width: 1
                            border.color: {
                                if (modelData.blocked)
                                    return Theme.dangerBorder;
                                if (modelData.connected)
                                    return Theme.accentBorder;
                                return Theme.borderSubtle;
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.animFast
                                }
                            }

                            // Click card to open detailed device popup
                            MouseArea {
                                id: cardMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.selectedDevice = devCard.modelData
                            }

                            RowLayout {
                                id: devRow
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: Theme.spaceMd
                                anchors.rightMargin: Theme.spaceSm
                                spacing: Theme.spaceSm

                                // Device type icon
                                Text {
                                    text: btIcons.deviceIcon(devCard.modelData.icon, devCard.modelData.connected)
                                    font.family: Theme.fontIcon
                                    font.pixelSize: 16
                                    color: {
                                        if (devCard.modelData.blocked)
                                            return Theme.dangerHover;
                                        if (devCard.modelData.connected)
                                            return Theme.accentHover;
                                        return Theme.textSecondary;
                                    }
                                    Layout.preferredWidth: 18
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                // Name, status, battery, and compact state icons
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        text: devCard.modelData.name || devCard.modelData.deviceName || devCard.modelData.address || "Bluetooth Device"
                                        font.family: Theme.fontSans
                                        font.pixelSize: Theme.fontSm
                                        font.weight: devCard.modelData.connected ? Font.DemiBold : Font.Medium
                                        color: Theme.textPrimary
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 6

                                        Text {
                                            text: btIcons.statusText(devCard.modelData)
                                            font.family: Theme.fontSans
                                            font.pixelSize: Theme.fontXs
                                            color: {
                                                if (devCard.modelData.blocked)
                                                    return Theme.dangerHover;
                                                if (devCard.modelData.pairing)
                                                    return Theme.warning;
                                                if (devCard.modelData.connected)
                                                    return Theme.accentHover;
                                                return Theme.textMuted;
                                            }
                                        }

                                        // Inline battery indicator
                                        RowLayout {
                                            visible: devCard.modelData.batteryAvailable
                                            spacing: 2

                                            Text {
                                                text: btIcons.batteryIcon(devCard.batteryPct)
                                                font.family: Theme.fontIcon
                                                font.pixelSize: 11
                                                color: devCard.batteryPct <= 15 ? Theme.dangerHover : Theme.textSecondary
                                            }

                                            Text {
                                                text: devCard.batteryPct + "%"
                                                font.family: Theme.fontMono
                                                font.pixelSize: 10
                                                font.weight: Font.Medium
                                                color: devCard.batteryPct <= 15 ? Theme.dangerHover : Theme.textSecondary
                                            }
                                        }

                                        // Compact state icons (Paired, Bonded, Trusted, Wake Allowed, Blocked)
                                        RowLayout {
                                            visible: devCard.hasStateIcons
                                            spacing: 4

                                            Text {
                                                visible: devCard.modelData.paired
                                                text: "󰌹"
                                                font.family: Theme.fontIcon
                                                font.pixelSize: 11
                                                color: Theme.accentHover
                                            }

                                            Text {
                                                visible: devCard.modelData.bonded
                                                text: "󰌾"
                                                font.family: Theme.fontIcon
                                                font.pixelSize: 11
                                                color: Theme.accentHover
                                            }

                                            Text {
                                                visible: devCard.modelData.trusted
                                                text: "󰒃"
                                                font.family: Theme.fontIcon
                                                font.pixelSize: 11
                                                color: Theme.success
                                            }

                                            Text {
                                                visible: devCard.modelData.wakeAllowed
                                                text: "󰖨"
                                                font.family: Theme.fontIcon
                                                font.pixelSize: 11
                                                color: Theme.accentHover
                                            }

                                            Text {
                                                visible: devCard.modelData.blocked
                                                text: "󰜺"
                                                font.family: Theme.fontIcon
                                                font.pixelSize: 11
                                                color: Theme.dangerHover
                                            }
                                        }
                                    }
                                }

                                // Quick action (Cancel / Disconnect / Connect / Pair)
                                ActionButton {
                                    text: btIcons.primaryActionLabel(devCard.modelData)
                                    compact: true
                                    variant: btIcons.primaryActionVariant(devCard.modelData)
                                    disabled: devCard.isDisconnecting || (!devCard.modelData.pairing && !devCard.modelData.connected && !devCard.isConnecting && devCard.modelData.blocked)
                                    onClicked: btIcons.triggerPrimaryAction(devCard.modelData)
                                }

                                // Details chevron hint
                                Text {
                                    text: "󰅂"
                                    font.family: Theme.fontIcon
                                    font.pixelSize: 12
                                    color: cardMouse.containsMouse ? Theme.textPrimary : Theme.textMuted
                                }
                            }
                        }
                    }

                    Text {
                        visible: root.sortedDevices.length === 0
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

    // Device details & management popup
    BluetoothDeviceDialog {
        screen: root.screen
        device: root.activeSelectedDevice
        open: root.isOpen && root.activeSelectedDevice !== null
        onDismissed: root.selectedDevice = null
    }
}
