import QtQuick
import QtQuick.Layouts

import "../../services"
import "../../theme"

Rectangle {
    id: root

    property var barScreen: null

    readonly property bool isOpen: ShellState.activePopover === "display"

    implicitHeight: 26
    implicitWidth: dispRow.implicitWidth + Theme.spaceMd * 2
    radius: Theme.radiusPill
    antialiasing: true

    color: {
        if (isOpen)
            return Theme.accentSubtle;
        if (dispMouse.pressed)
            return Theme.pressedBg;
        if (dispMouse.containsMouse)
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
        id: dispRow
        anchors.centerIn: parent
        spacing: 5

        Text {
            text: "󰃠"
            font.family: Theme.fontIcon
            font.pixelSize: 14
            color: root.isOpen ? Theme.accentHover : Theme.textPrimary
        }
    }

    MouseArea {
        id: dispMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton

        onClicked: ShellState.togglePopover("display", root.barScreen)

        onWheel: function (wheel) {
            let step = wheel.angleDelta.y > 0 ? 5 : (wheel.angleDelta.y < 0 ? -5 : 0);
            if (step !== 0)
                DisplayService.scrollBacklightFromBar(step);
        }
    }
}
