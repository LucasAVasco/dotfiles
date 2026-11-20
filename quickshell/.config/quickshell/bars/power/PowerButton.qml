import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

import "../../services"
import "../../theme"

Rectangle {
    id: root

    property var barScreen: null

    readonly property bool isOpen: ShellState.activePopover === "power"
    readonly property UPowerDevice displayDev: UPower.displayDevice
    readonly property bool hasSystemBattery: displayDev !== null && displayDev.ready && displayDev.isLaptopBattery
    readonly property int batteryPct: hasSystemBattery ? Math.round(displayDev.percentage * 100) : -1
    readonly property bool isCharging: hasSystemBattery && displayDev.state === UPowerDeviceState.Charging

    readonly property string powerIcon: {
        if (hasSystemBattery) {
            if (isCharging)
                return "󰂄";
            if (displayDev.state === UPowerDeviceState.FullyCharged)
                return "󰁹";
            if (batteryPct >= 80)
                return "󰂁";
            if (batteryPct >= 60)
                return "󰁿";
            if (batteryPct >= 40)
                return "󰁽";
            if (batteryPct >= 20)
                return "󰁻";
            return "󰁺";
        }
        // Fallback to active power profile icon when on desktop without laptop battery
        if (PowerProfiles.profile === PowerProfile.PowerSaver)
            return "󰌪";
        if (PowerProfiles.profile === PowerProfile.Performance)
            return "󰓅";
        return "󰾅";
    }

    implicitHeight: 26
    implicitWidth: pwrRow.implicitWidth + Theme.spaceMd * 2
    radius: Theme.radiusPill
    antialiasing: true

    color: {
        if (isOpen)
            return Theme.accentSubtle;
        if (pwrMouse.pressed)
            return Theme.pressedBg;
        if (pwrMouse.containsMouse)
            return Theme.hoverBg;
        return "transparent";
    }

    border.width: isOpen ? 1 : 0
    border.color: Theme.accentBorder

    Behavior on color {
        ColorAnimation {
            duration: Theme.animFast
        }
    }

    RowLayout {
        id: pwrRow
        anchors.centerIn: parent
        spacing: 5

        Text {
            text: root.powerIcon
            font.family: Theme.fontIcon
            font.pixelSize: 14
            color: {
                if (root.isOpen)
                    return Theme.accentHover;
                if (root.hasSystemBattery && root.batteryPct <= 15 && !root.isCharging)
                    return Theme.dangerHover;
                if (root.isCharging)
                    return Theme.success;
                return Theme.textPrimary;
            }
        }

        Text {
            visible: root.hasSystemBattery
            text: root.batteryPct + "%"
            font.family: Theme.fontSans
            font.pixelSize: Theme.fontXs
            font.weight: Font.Medium
            color: (root.batteryPct <= 15 && !root.isCharging) ? Theme.dangerHover : Theme.textSecondary
        }
    }

    MouseArea {
        id: pwrMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: ShellState.togglePopover("power", root.barScreen)
    }
}
