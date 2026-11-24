pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth

import "../../theme"
import "../../ui"

ModalDialog {
    id: root

    property BluetoothDevice device: null

    readonly property int batteryPct: (device && device.batteryAvailable) ? Math.max(0, Math.min(100, Math.round(device.battery * 100))) : -1
    readonly property bool isConnecting: device !== null && device.state === BluetoothDeviceState.Connecting
    readonly property bool isDisconnecting: device !== null && device.state === BluetoothDeviceState.Disconnecting
    readonly property bool canForget: device !== null && (device.paired || device.bonded || device.trusted || device.blocked)

    dialogWidth: 380

    BluetoothIcons {
        id: btIcons
    }

    // Header
    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spaceMd

        Rectangle {
            implicitWidth: 40
            implicitHeight: 40
            radius: Theme.radiusMd
            color: (root.device && root.device.connected) ? Theme.accentSubtle : Theme.surfaceRaised
            border.width: 1
            border.color: (root.device && root.device.connected) ? Theme.accentBorder : Theme.borderSubtle

            Text {
                anchors.centerIn: parent
                text: root.device ? btIcons.deviceIcon(root.device.icon, root.device.connected) : "󰂯"
                font.family: Theme.fontIcon
                font.pixelSize: 20
                color: {
                    if (!root.device)
                        return Theme.textSecondary;
                    if (root.device.blocked)
                        return Theme.dangerHover;
                    if (root.device.connected)
                        return Theme.accentHover;
                    return Theme.textPrimary;
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: root.device ? (root.device.name || root.device.deviceName || "Bluetooth Device") : ""
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontLg
                font.weight: Font.DemiBold
                color: Theme.textPrimary
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: root.device ? (root.device.address || "") : ""
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontXs
                color: Theme.textMuted
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        IconButton {
            icon: "󰅖"
            iconSize: 13
            buttonSize: 28
            iconColor: Theme.textSecondary
            onClicked: root.dismissed()
        }
    }

    // Status & Battery summary card
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: summaryCol.implicitHeight + Theme.spaceMd * 2
        radius: Theme.radiusMd
        color: Theme.surfaceRaised
        border.width: 1
        border.color: Theme.borderSubtle

        ColumnLayout {
            id: summaryCol
            anchors.fill: parent
            anchors.margins: Theme.spaceMd
            spacing: Theme.spaceSm

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spaceSm

                Text {
                    text: "Status"
                    font.family: Theme.fontSans
                    font.pixelSize: Theme.fontSm
                    color: Theme.textSecondary
                    Layout.fillWidth: true
                }

                Text {
                    text: btIcons.statusText(root.device)
                    font.family: Theme.fontSans
                    font.pixelSize: Theme.fontSm
                    font.weight: Font.DemiBold
                    color: {
                        if (!root.device)
                            return Theme.textMuted;
                        if (root.device.blocked)
                            return Theme.dangerHover;
                        if (root.device.pairing)
                            return Theme.warning;
                        if (root.device.connected)
                            return Theme.accentHover;
                        return Theme.textPrimary;
                    }
                }
            }

            // Battery row + bar (only when batteryAvailable)
            ColumnLayout {
                visible: root.device !== null && root.device.batteryAvailable
                Layout.fillWidth: true
                spacing: Theme.spaceXs

                Separator {
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spaceSm

                    Text {
                        text: btIcons.batteryIcon(root.batteryPct)
                        font.family: Theme.fontIcon
                        font.pixelSize: 14
                        color: root.batteryPct <= 15 ? Theme.dangerHover : Theme.textSecondary
                    }

                    Text {
                        text: "Battery"
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontSm
                        color: Theme.textSecondary
                        Layout.fillWidth: true
                    }

                    Text {
                        text: root.batteryPct + "%"
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSm
                        font.weight: Font.DemiBold
                        color: root.batteryPct <= 15 ? Theme.dangerHover : Theme.textPrimary
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 6
                    radius: 3
                    color: Theme.surfaceOverlay

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: Math.max(6, parent.width * Math.max(0, Math.min(1, root.device ? root.device.battery : 0)))
                        radius: 3
                        color: root.batteryPct <= 15 ? Theme.danger : Theme.accent
                    }
                }
            }
        }
    }

    // Device states & settings
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.spaceXs

        Text {
            text: "DEVICE STATE"
            font.family: Theme.fontSans
            font.pixelSize: 10
            font.weight: Font.DemiBold
            font.letterSpacing: 0.7
            color: Theme.textMuted
            Layout.leftMargin: 4
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: stateCol.implicitHeight + Theme.spaceMd * 2
            radius: Theme.radiusMd
            color: Theme.surfaceRaised
            border.width: 1
            border.color: Theme.borderSubtle

            ColumnLayout {
                id: stateCol
                anchors.fill: parent
                anchors.margins: Theme.spaceMd
                spacing: Theme.spaceSm

                // Paired (read-only)
                StateBadgeRow {
                    icon: "󰌹"
                    label: "Paired"
                    active: root.device !== null && root.device.paired
                    activeText: "Yes"
                    inactiveText: "No"
                }

                Separator {
                    Layout.fillWidth: true
                }

                // Bonded (read-only)
                StateBadgeRow {
                    icon: "󰌾"
                    label: "Bonded"
                    active: root.device !== null && root.device.bonded
                    activeText: "Yes"
                    inactiveText: "No"
                }

                Separator {
                    Layout.fillWidth: true
                }

                // Trusted (toggle)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spaceSm

                    Text {
                        text: "󰒃"
                        font.family: Theme.fontIcon
                        font.pixelSize: 15
                        color: (root.device && root.device.trusted) ? Theme.success : Theme.textMuted
                        Layout.preferredWidth: 18
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        text: "Trusted"
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontSm
                        font.weight: Font.Medium
                        color: Theme.textPrimary
                        Layout.fillWidth: true
                    }

                    SwitchControl {
                        checked: root.device !== null && root.device.trusted
                        disabled: root.device === null
                        onToggled: function (state) {
                            if (root.device)
                                root.device.trusted = state;
                        }
                    }
                }

                Separator {
                    Layout.fillWidth: true
                }

                // Wake Allowed (toggle)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spaceSm

                    Text {
                        text: "󰖨"
                        font.family: Theme.fontIcon
                        font.pixelSize: 15
                        color: (root.device && root.device.wakeAllowed) ? Theme.accentHover : Theme.textMuted
                        Layout.preferredWidth: 18
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        text: "Wake Allowed"
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontSm
                        font.weight: Font.Medium
                        color: Theme.textPrimary
                        Layout.fillWidth: true
                    }

                    SwitchControl {
                        checked: root.device !== null && root.device.wakeAllowed
                        disabled: root.device === null
                        onToggled: function (state) {
                            if (root.device)
                                root.device.wakeAllowed = state;
                        }
                    }
                }

                Separator {
                    Layout.fillWidth: true
                }

                // Blocked (toggle)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spaceSm

                    Text {
                        text: "󰜺"
                        font.family: Theme.fontIcon
                        font.pixelSize: 15
                        color: (root.device && root.device.blocked) ? Theme.dangerHover : Theme.textMuted
                        Layout.preferredWidth: 18
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        text: "Blocked"
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontSm
                        font.weight: Font.Medium
                        color: Theme.textPrimary
                        Layout.fillWidth: true
                    }

                    SwitchControl {
                        checked: root.device !== null && root.device.blocked
                        disabled: root.device === null
                        onToggled: function (state) {
                            if (root.device)
                                root.device.blocked = state;
                        }
                    }
                }
            }
        }
    }

    // Action buttons footer
    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: Theme.spaceXs
        spacing: Theme.spaceSm

        ActionButton {
            visible: root.canForget
            text: "Forget"
            icon: "󰆴"
            variant: "danger"
            onClicked: {
                if (root.device) {
                    root.device.forget();
                    root.dismissed();
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

        ActionButton {
            text: {
                if (!root.device)
                    return "";
                if (root.device.pairing)
                    return "Cancel Pairing";
                return btIcons.primaryActionLabel(root.device);
            }
            variant: btIcons.primaryActionVariant(root.device)
            disabled: root.device === null || root.isDisconnecting || (!root.device.pairing && !root.device.connected && !root.isConnecting && root.device.blocked)
            onClicked: btIcons.triggerPrimaryAction(root.device)
        }
    }

    component StateBadgeRow: RowLayout {
        id: badgeRow
        required property string icon
        required property string label
        required property bool active
        property string activeText: "Yes"
        property string inactiveText: "No"

        Layout.fillWidth: true
        spacing: Theme.spaceSm

        Text {
            text: badgeRow.icon
            font.family: Theme.fontIcon
            font.pixelSize: 15
            color: badgeRow.active ? Theme.accentHover : Theme.textMuted
            Layout.preferredWidth: 18
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            text: badgeRow.label
            font.family: Theme.fontSans
            font.pixelSize: Theme.fontSm
            font.weight: Font.Medium
            color: Theme.textPrimary
            Layout.fillWidth: true
        }

        Rectangle {
            implicitWidth: stateBadgeText.implicitWidth + Theme.spaceSm * 2
            implicitHeight: 22
            radius: Theme.radiusPill
            color: badgeRow.active ? Theme.accentSubtle : Theme.subtleBg
            border.width: 1
            border.color: badgeRow.active ? Theme.accentBorder : Theme.borderSubtle

            Text {
                id: stateBadgeText
                anchors.centerIn: parent
                text: badgeRow.active ? badgeRow.activeText : badgeRow.inactiveText
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontXs
                font.weight: Font.Medium
                color: badgeRow.active ? Theme.accentHover : Theme.textMuted
            }
        }
    }
}
