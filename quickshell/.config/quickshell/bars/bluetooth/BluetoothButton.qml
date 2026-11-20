import QtQuick
import Quickshell.Bluetooth

import "../../services"
import "../../theme"

Rectangle {
    id: root

    property var barScreen: null

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool isOpen: ShellState.activePopover === "bluetooth"

    // Strictly hidden when no Bluetooth hardware / BlueZ adapter is present
    visible: available
    implicitHeight: 26
    implicitWidth: 28
    radius: Theme.radiusPill
    antialiasing: true

    color: {
        if (isOpen)
            return Theme.accentSubtle;
        if (btMouse.pressed)
            return Theme.pressedBg;
        if (btMouse.containsMouse)
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

    Text {
        anchors.centerIn: parent
        text: (root.adapter && root.adapter.enabled) ? "󰂯" : "󰂲"
        font.family: Theme.fontIcon
        font.pixelSize: 14
        color: {
            if (root.isOpen)
                return Theme.accentHover;
            if (root.adapter && root.adapter.enabled)
                return Theme.textPrimary;
            return Theme.textMuted;
        }
    }

    MouseArea {
        id: btMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: ShellState.togglePopover("bluetooth", root.barScreen)
    }
}
