import QtQuick
import QtQuick.Layouts

import "../../services"
import "../../theme"

Rectangle {
    id: root

    property var barScreen: null

    readonly property bool isOpen: ShellState.activePopover === "network"

    readonly property string netIcon: {
        if (!NetworkService.connected)
            return NetworkService.hasWifi ? "󰤭" : "󰈂";
        if (NetworkService.activeType === "ethernet")
            return "󰈀";
        let sig = NetworkService.activeWifiSignal;
        if (sig >= 75)
            return "󰤨";
        if (sig >= 50)
            return "󰤥";
        if (sig >= 25)
            return "󰤢";
        return "󰤟";
    }

    visible: NetworkService.available && (NetworkService.hasEthernet || NetworkService.hasWifi)
    implicitHeight: 26
    implicitWidth: 28
    radius: Theme.radiusPill
    antialiasing: true

    color: {
        if (isOpen)
            return Theme.accentSubtle;
        if (netMouse.pressed)
            return Theme.pressedBg;
        if (netMouse.containsMouse)
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
        text: root.netIcon
        font.family: Theme.fontIcon
        font.pixelSize: 14
        color: {
            if (root.isOpen)
                return Theme.accentHover;
            if (!NetworkService.connected)
                return Theme.textMuted;
            return Theme.textPrimary;
        }
    }

    MouseArea {
        id: netMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: ShellState.togglePopover("network", root.barScreen)
    }
}
