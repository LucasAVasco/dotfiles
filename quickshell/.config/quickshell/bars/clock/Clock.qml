import QtQuick
import QtQuick.Layouts

import "../../services"
import "../../theme"

Rectangle {
    id: root

    property var barScreen: null

    readonly property bool isOpen: ShellState.activePopover === "notificationCenter"
    readonly property bool hasUnread: NotificationStore.unreadCount > 0
    readonly property bool hovered: clockMouse.containsMouse

    implicitHeight: 26
    implicitWidth: clockRow.implicitWidth + Theme.spaceMd * 2
    radius: Theme.radiusPill
    antialiasing: true

    color: {
        if (isOpen)
            return Theme.accentSubtle;
        if (clockMouse.pressed)
            return Theme.pressedBg;
        if (hovered)
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
        id: clockRow
        anchors.centerIn: parent
        spacing: Theme.spaceSm

        Text {
            text: ClockTimer.time
            font.family: Theme.fontSans
            font.pixelSize: Theme.fontSm
            font.weight: Font.DemiBold
            color: root.isOpen ? Theme.accentHover : Theme.textPrimary
        }

        // Do Not Disturb indicator
        Text {
            visible: NotificationStore.doNotDisturb
            text: "󰂛"
            font.family: Theme.fontIcon
            font.pixelSize: 12
            color: Theme.textMuted
        }

        // Unread notification indicator dot
        Rectangle {
            visible: root.hasUnread && !NotificationStore.doNotDisturb
            implicitWidth: 7
            implicitHeight: 7
            radius: 4
            color: Theme.accentHover
        }
    }

    MouseArea {
        id: clockMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: ShellState.togglePopover("notificationCenter", root.barScreen)
    }
}
