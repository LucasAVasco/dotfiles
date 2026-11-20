pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower

import "../../services"
import "../../theme"
import "../../ui"

PanelWindow {
    id: root

    readonly property bool isOpen: ShellState.activePopover === "power"
    readonly property UPowerDevice displayDev: UPower.displayDevice
    readonly property bool hasSystemBattery: displayDev !== null && displayDev.ready && displayDev.isLaptopBattery

    // Discover all battery-bearing devices (laptop + peripherals like wireless keyboard/mouse)
    readonly property var batteryDevices: {
        if (!UPower.devices)
            return [];
        return [...UPower.devices.values].filter(d => {
            if (!d || !d.ready)
                return false;
            return d.type !== UPowerDeviceType.LinePower && d.type !== UPowerDeviceType.Unknown && d.percentage >= 0;
        });
    }

    // Dynamically discovered power profiles
    readonly property var availableProfiles: {
        let list = [
            { id: PowerProfile.PowerSaver, label: "Power Saver", desc: "Lower power consumption", icon: "󰌪" },
            { id: PowerProfile.Balanced, label: "Balanced", desc: "Standard performance and power", icon: "󰾅" }
        ];
        if (PowerProfiles.hasPerformanceProfile) {
            list.push({ id: PowerProfile.Performance, label: "Performance", desc: "Maximum system performance", icon: "󰓅" });
        }
        return list;
    }

    function stateLabel(st) {
        switch (st) {
        case UPowerDeviceState.Charging:
            return "Charging";
        case UPowerDeviceState.Discharging:
            return "Discharging";
        case UPowerDeviceState.FullyCharged:
            return "Fully charged";
        case UPowerDeviceState.PendingCharge:
        case UPowerDeviceState.PendingDischarge:
            return "Not charging";
        case UPowerDeviceState.Empty:
            return "Empty";
        default:
            return "Unknown";
        }
    }

    function formatDuration(sec) {
        if (!sec || sec <= 0)
            return "";
        let hrs = Math.floor(sec / 3600);
        let mins = Math.floor((sec % 3600) / 60);
        if (hrs > 0)
            return hrs + "h " + mins + "m";
        return mins + "m";
    }

    onIsOpenChanged: {
        if (isOpen)
            powerSurface.forceActiveFocus();
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
        id: powerSurface
        elevation: "popover"
        radius: Theme.radiusXl
        border.color: Theme.borderDefault

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: Theme.topBarHeight + 8
        anchors.rightMargin: 12

        width: Math.min(340, root.width - 24)
        height: Math.min(pwrCol.implicitHeight + Theme.spaceLg * 2, root.height - Theme.topBarHeight - 32)

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
                ShellState.closePopovers();
            }
        }

        ColumnLayout {
            id: pwrCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.spaceLg
            spacing: Theme.spaceMd

            Text {
                text: "Power"
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontLg
                font.weight: Font.DemiBold
                color: Theme.textPrimary
            }

            // Batteries section (hidden completely if no batteries exist)
            ColumnLayout {
                visible: root.hasSystemBattery || root.batteryDevices.length > 0
                Layout.fillWidth: true
                spacing: Theme.spaceSm

                Text {
                    text: "BATTERIES"
                    font.family: Theme.fontSans
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    font.letterSpacing: 0.7
                    color: Theme.textMuted
                    Layout.leftMargin: 4
                }

                Repeater {
                    model: root.batteryDevices

                    delegate: Rectangle {
                        id: batCard
                        required property UPowerDevice modelData
                        readonly property int pct: Math.round(modelData.percentage * 100)
                        readonly property string remStr: {
                            if (modelData.state === UPowerDeviceState.Charging && modelData.timeToFull > 0)
                                return " · " + root.formatDuration(modelData.timeToFull) + " until full";
                            if (modelData.state === UPowerDeviceState.Discharging && modelData.timeToEmpty > 0)
                                return " · " + root.formatDuration(modelData.timeToEmpty) + " remaining";
                            return "";
                        }

                        Layout.fillWidth: true
                        implicitHeight: batCol.implicitHeight + Theme.spaceMd * 2
                        radius: Theme.radiusMd
                        color: Theme.surfaceRaised
                        border.width: 1
                        border.color: Theme.borderSubtle

                        ColumnLayout {
                            id: batCol
                            anchors.fill: parent
                            anchors.margins: Theme.spaceMd
                            spacing: Theme.spaceXs

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Theme.spaceSm

                                Text {
                                    text: modelData.model || (modelData.isLaptopBattery ? "System Battery" : "Device Battery")
                                    font.family: Theme.fontSans
                                    font.pixelSize: Theme.fontSm
                                    font.weight: Font.Medium
                                    color: Theme.textPrimary
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: batCard.pct + "%"
                                    font.family: Theme.fontMono
                                    font.pixelSize: Theme.fontSm
                                    font.weight: Font.DemiBold
                                    color: batCard.pct <= 15 ? Theme.dangerHover : Theme.textPrimary
                                }
                            }

                            // Battery level bar
                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 6
                                radius: 3
                                color: Theme.surfaceOverlay

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    width: Math.max(6, parent.width * Math.max(0, Math.min(1, modelData.percentage)))
                                    radius: 3
                                    color: modelData.state === UPowerDeviceState.Charging
                                        ? Theme.success
                                        : (batCard.pct <= 15 ? Theme.danger : Theme.accent)
                                }
                            }

                            Text {
                                text: root.stateLabel(modelData.state) + batCard.remStr
                                font.family: Theme.fontSans
                                font.pixelSize: Theme.fontXs
                                color: Theme.textSecondary
                            }
                        }
                    }
                }
            }

            Separator {
                visible: root.hasSystemBattery || root.batteryDevices.length > 0
                Layout.fillWidth: true
            }

            // Power Profiles section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spaceXs

                Text {
                    text: "POWER PROFILE"
                    font.family: Theme.fontSans
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    font.letterSpacing: 0.7
                    color: Theme.textMuted
                    Layout.leftMargin: 4
                }

                Repeater {
                    id: profileRepeater
                    model: root.availableProfiles

                    delegate: Rectangle {
                        id: profRow
                        required property var modelData
                        readonly property bool selected: PowerProfiles.profile === modelData.id
                        readonly property bool showFocusRing: activeFocus && ShellState.keyboardFocusVisible

                        activeFocusOnTab: true
                        Layout.fillWidth: true
                        implicitHeight: 46
                        radius: Theme.radiusMd
                        antialiasing: true
                        color: {
                            if (profMouse.pressed)
                                return Theme.pressedBg;
                            if (selected)
                                return Theme.accentSubtle;
                            if (profMouse.containsMouse || showFocusRing)
                                return Theme.hoverBg;
                            return "transparent";
                        }
                        border.width: showFocusRing ? 2 : (selected ? 1 : 0)
                        border.color: showFocusRing ? Theme.accentHover : Theme.accentBorder

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.animFast
                            }
                        }

                        Keys.onPressed: function (event) {
                            if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
                                ShellState.markKeyboardNav();
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                                event.accepted = true;
                                PowerProfiles.profile = modelData.id;
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.spaceMd
                            anchors.rightMargin: Theme.spaceMd
                            spacing: Theme.spaceSm

                            Text {
                                text: modelData.icon
                                font.family: Theme.fontIcon
                                font.pixelSize: 16
                                color: profRow.selected ? Theme.accentHover : Theme.textSecondary
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                Text {
                                    text: modelData.label
                                    font.family: Theme.fontSans
                                    font.pixelSize: Theme.fontSm
                                    font.weight: profRow.selected ? Font.DemiBold : Font.Medium
                                    color: Theme.textPrimary
                                }

                                Text {
                                    text: modelData.desc
                                    font.family: Theme.fontSans
                                    font.pixelSize: Theme.fontXs
                                    color: Theme.textMuted
                                }
                            }

                            Text {
                                visible: profRow.selected
                                text: "󰄬"
                                font.family: Theme.fontIcon
                                font.pixelSize: 14
                                color: Theme.accentHover
                            }
                        }

                        MouseArea {
                            id: profMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                ShellState.markPointerNav();
                                PowerProfiles.profile = modelData.id;
                            }
                        }
                    }
                }

                // Performance degradation warning (if throttled)
                Text {
                    visible: PowerProfiles.degradationReason !== PerformanceDegradationReason.None
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    wrapMode: Text.Wrap
                    font.family: Theme.fontSans
                    font.pixelSize: Theme.fontXs
                    color: Theme.warning
                    text: PowerProfiles.degradationReason === PerformanceDegradationReason.HighTemperature
                        ? "Performance reduced due to high temperature."
                        : "Performance reduced due to lap detection."
                }
            }
        }
    }
}
