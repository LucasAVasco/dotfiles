pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell

import "../../services"
import "../../theme"
import "../../ui"

PanelWindow {
    id: root

    readonly property bool isOpen: ShellState.activePopover === "network"
    property string pendingPasswordSsid: ""

    onIsOpenChanged: {
        if (isOpen) {
            pendingPasswordSsid = "";
            NetworkService.clearError();
            NetworkService.refreshAll();
            netSurface.forceActiveFocus();
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
        id: netSurface
        elevation: "popover"
        radius: Theme.radiusXl
        border.color: Theme.borderDefault

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: Theme.topBarHeight + 8
        anchors.rightMargin: 12

        width: Math.min(350, root.width - 24)
        height: Math.min(netFlick.contentHeight + Theme.spaceLg * 2, root.height - Theme.topBarHeight - 32)

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
                if (root.pendingPasswordSsid.length > 0)
                    root.pendingPasswordSsid = "";
                else
                    ShellState.closePopovers();
            }
        }

        Flickable {
            id: netFlick
            anchors.fill: parent
            anchors.margins: Theme.spaceLg
            contentWidth: width
            contentHeight: netCol.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: netCol
                width: netFlick.width
                spacing: Theme.spaceMd

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spaceSm

                    Text {
                        text: "Network"
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontLg
                        font.weight: Font.DemiBold
                        color: Theme.textPrimary
                        Layout.fillWidth: true
                    }

                    Text {
                        text: NetworkService.connected ? (NetworkService.activeName || "Connected") : "Disconnected"
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontXs
                        color: NetworkService.connected ? Theme.success : Theme.textMuted
                        elide: Text.ElideRight
                        Layout.maximumWidth: 160
                    }

                    IconButton {
                        id: refreshBtn
                        icon: "󰑐"
                        iconSize: 14
                        buttonSize: 28
                        disabled: NetworkService.busy || NetworkService.scanning
                        onClicked: {
                            NetworkService.refreshAll();
                            if (NetworkService.hasWifi && NetworkService.wifiEnabled)
                                NetworkService.rescanWifi();
                        }
                    }
                }

                // Error banner
                Rectangle {
                    visible: NetworkService.lastError.length > 0
                    Layout.fillWidth: true
                    implicitHeight: errTxt.implicitHeight + Theme.spaceSm * 2
                    radius: Theme.radiusSm
                    color: Theme.dangerSubtle
                    border.width: 1
                    border.color: Theme.dangerBorder

                    Text {
                        id: errTxt
                        anchors.fill: parent
                        anchors.margins: Theme.spaceSm
                        text: NetworkService.lastError
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontXs
                        color: Theme.dangerHover
                        wrapMode: Text.Wrap
                    }
                }

                // =============================================================
                // Ethernet Section (only when Ethernet hardware exists)
                // =============================================================
                ColumnLayout {
                    visible: NetworkService.hasEthernet
                    Layout.fillWidth: true
                    spacing: Theme.spaceXs

                    Text {
                        text: "WIRED"
                        font.family: Theme.fontSans
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        font.letterSpacing: 0.7
                        color: Theme.textMuted
                        Layout.leftMargin: 4
                    }

                    Repeater {
                        model: NetworkService.ethernetDevices

                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 46
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
                                    text: "󰈀"
                                    font.family: Theme.fontIcon
                                    font.pixelSize: 16
                                    color: modelData.connected ? Theme.accentHover : Theme.textMuted
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1

                                    Text {
                                        text: modelData.connection || modelData.device
                                        font.family: Theme.fontSans
                                        font.pixelSize: Theme.fontSm
                                        font.weight: Font.Medium
                                        color: Theme.textPrimary
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: modelData.device + " · " + modelData.state
                                        font.family: Theme.fontSans
                                        font.pixelSize: Theme.fontXs
                                        color: Theme.textSecondary
                                    }
                                }

                                ActionButton {
                                    text: modelData.connected ? "Disconnect" : "Connect"
                                    compact: true
                                    variant: "secondary"
                                    disabled: NetworkService.busy
                                    onClicked: {
                                        if (modelData.connected)
                                            NetworkService.disconnectDevice(modelData.device);
                                        else
                                            NetworkService.connectDevice(modelData.device);
                                    }
                                }
                            }
                        }
                    }
                }

                // =============================================================
                // Wi-Fi Section (only when Wi-Fi hardware exists)
                // =============================================================
                Separator {
                    visible: NetworkService.hasEthernet && NetworkService.hasWifi
                    Layout.fillWidth: true
                }

                ColumnLayout {
                    visible: NetworkService.hasWifi
                    Layout.fillWidth: true
                    spacing: Theme.spaceSm

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spaceSm

                        Text {
                            text: "Wi-Fi"
                            font.family: Theme.fontSans
                            font.pixelSize: Theme.fontMd
                            font.weight: Font.DemiBold
                            color: Theme.textPrimary
                            Layout.fillWidth: true
                        }

                        SwitchControl {
                            id: wifiSwitch
                            checked: NetworkService.wifiEnabled
                            disabled: NetworkService.busy
                            onToggled: function (state) {
                                NetworkService.setWifiEnabled(state);
                            }
                        }
                    }

                    // Inline Wi-Fi password prompt (never logs/exposes password)
                    Rectangle {
                        visible: root.pendingPasswordSsid.length > 0
                        Layout.fillWidth: true
                        implicitHeight: pwdCol.implicitHeight + Theme.spaceMd * 2
                        radius: Theme.radiusMd
                        color: Theme.surfaceRaised
                        border.width: 1
                        border.color: Theme.accentBorder

                        ColumnLayout {
                            id: pwdCol
                            anchors.fill: parent
                            anchors.margins: Theme.spaceMd
                            spacing: Theme.spaceSm

                            Text {
                                text: "Password for " + root.pendingPasswordSsid
                                font.family: Theme.fontSans
                                font.pixelSize: Theme.fontSm
                                font.weight: Font.Medium
                                color: Theme.textPrimary
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            TextFieldBox {
                                id: wifiPwdInput
                                Layout.fillWidth: true
                                placeholderText: "Enter Wi-Fi password"
                                echoMode: TextInput.Password
                                showClearButton: false
                                onAccepted: submitPwd()
                                onEscapePressed: root.pendingPasswordSsid = ""

                                function submitPwd() {
                                    let ssid = root.pendingPasswordSsid;
                                    let pwd = wifiPwdInput.text;
                                    wifiPwdInput.text = "";
                                    root.pendingPasswordSsid = "";
                                    NetworkService.connectWifi(ssid, pwd);
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Theme.spaceXs
                                Item { Layout.fillWidth: true }
                                ActionButton {
                                    text: "Cancel"
                                    compact: true
                                    variant: "ghost"
                                    onClicked: {
                                        wifiPwdInput.text = "";
                                        root.pendingPasswordSsid = "";
                                    }
                                }
                                ActionButton {
                                    text: "Connect"
                                    compact: true
                                    variant: "primary"
                                    disabled: wifiPwdInput.text.length === 0 || NetworkService.busy
                                    onClicked: wifiPwdInput.submitPwd()
                                }
                            }
                        }
                    }

                    // Available SSID list
                    ColumnLayout {
                        visible: NetworkService.wifiEnabled
                        Layout.fillWidth: true
                        spacing: 4

                        Repeater {
                            model: NetworkService.wifiNetworks

                            delegate: Rectangle {
                                id: ssidRow
                                required property var modelData
                                activeFocusOnTab: true
                                Layout.fillWidth: true
                                implicitHeight: 38
                                radius: Theme.radiusMd
                                color: {
                                    if (ssidMouse.pressed)
                                        return Theme.pressedBg;
                                    if (modelData.inUse)
                                        return Theme.accentSubtle;
                                    if (ssidMouse.containsMouse || activeFocus)
                                        return Theme.hoverBg;
                                    return "transparent";
                                }
                                border.width: activeFocus ? 2 : (modelData.inUse ? 1 : 0)
                                border.color: activeFocus ? Theme.accentHover : Theme.accentBorder

                                Keys.onPressed: function (event) {
                                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                                        event.accepted = true;
                                        ssidRow.activateSsid();
                                    }
                                }

                                function activateSsid() {
                                    if (modelData.inUse) {
                                        NetworkService.disconnectDevice(NetworkService.wifiDevice);
                                    } else if (modelData.secured) {
                                        root.pendingPasswordSsid = modelData.ssid;
                                        wifiPwdInput.text = "";
                                        wifiPwdInput.focusInput();
                                    } else {
                                        NetworkService.connectWifi(modelData.ssid, "");
                                    }
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: Theme.spaceSm
                                    anchors.rightMargin: Theme.spaceSm
                                    spacing: Theme.spaceSm

                                    Text {
                                        text: modelData.signal >= 75 ? "󰤨" : (modelData.signal >= 50 ? "󰤥" : (modelData.signal >= 25 ? "󰤢" : "󰤟"))
                                        font.family: Theme.fontIcon
                                        font.pixelSize: 14
                                        color: modelData.inUse ? Theme.accentHover : Theme.textSecondary
                                    }

                                    Text {
                                        text: modelData.ssid
                                        font.family: Theme.fontSans
                                        font.pixelSize: Theme.fontSm
                                        font.weight: modelData.inUse ? Font.DemiBold : Font.Normal
                                        color: Theme.textPrimary
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        visible: modelData.secured
                                        text: "󰌾"
                                        font.family: Theme.fontIcon
                                        font.pixelSize: 11
                                        color: Theme.textMuted
                                    }

                                    Text {
                                        text: modelData.inUse ? "Connected" : (modelData.signal + "%")
                                        font.family: Theme.fontSans
                                        font.pixelSize: Theme.fontXs
                                        color: modelData.inUse ? Theme.accentHover : Theme.textMuted
                                    }
                                }

                                MouseArea {
                                    id: ssidMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: ssidRow.activateSsid()
                                }
                            }
                        }

                        Text {
                            visible: NetworkService.wifiNetworks.length === 0
                            text: NetworkService.scanning ? "Scanning for networks…" : "No Wi-Fi networks found"
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
}
