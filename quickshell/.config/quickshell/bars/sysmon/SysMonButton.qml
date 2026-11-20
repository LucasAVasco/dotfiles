import QtQuick
import QtQuick.Layouts

import "../../services"
import "../../theme"

Rectangle {
    id: root

    property var barScreen: null

    readonly property bool isOpen: ShellState.activePopover === "sysmon"

    implicitHeight: 26
    implicitWidth: monRow.implicitWidth + Theme.spaceMd * 2
    radius: Theme.radiusPill
    antialiasing: true

    color: {
        if (isOpen)
            return Theme.accentSubtle;
        if (monMouse.pressed)
            return Theme.pressedBg;
        if (monMouse.containsMouse)
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
        id: monRow
        anchors.centerIn: parent
        spacing: Theme.spaceSm

        MetricChip {
            icon: "󰍛"
            val: SystemMonitorService.formatPercent(SystemMonitorService.cpuPercent)
            high: SystemMonitorService.cpuPercent >= 85
        }

        MetricChip {
            icon: "󰘚"
            val: SystemMonitorService.formatPercent(SystemMonitorService.memPercent)
            high: SystemMonitorService.memPercent >= 85
        }

        MetricChip {
            icon: "󰋊"
            val: SystemMonitorService.formatPercent(SystemMonitorService.diskPercent)
            high: SystemMonitorService.diskPercent >= 90
        }
    }

    MouseArea {
        id: monMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: ShellState.togglePopover("sysmon", root.barScreen)
    }

    component MetricChip: RowLayout {
        required property string icon
        required property string val
        property bool high: false
        spacing: 3

        Text {
            text: icon
            font.family: Theme.fontIcon
            font.pixelSize: 12
            color: high ? Theme.warning : (root.isOpen ? Theme.accentHover : Theme.textMuted)
        }

        Text {
            text: val
            font.family: Theme.fontMono
            font.pixelSize: 11
            font.weight: Font.Medium
            color: high ? Theme.warning : Theme.textSecondary
        }
    }
}
