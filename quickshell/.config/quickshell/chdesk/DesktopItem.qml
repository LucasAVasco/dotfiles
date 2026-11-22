pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import "../theme"

Rectangle {
    id: root

    required property string desktopName
    required property bool selected
    required property bool isCurrentDesktop

    signal clicked(string name)
    signal hovered

    radius: Theme.radiusMd
    antialiasing: true
    color: {
        if (itemMouse.pressed)
            return Theme.pressedBg;
        if (root.selected)
            return Theme.accentSubtle;
        if (itemMouse.containsMouse)
            return Theme.hoverBg;
        return "transparent";
    }
    border.width: root.selected ? 1 : 0
    border.color: Theme.accentBorder

    Behavior on color {
        ColorAnimation {
            duration: Theme.animFast
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spaceMd
        anchors.rightMargin: Theme.spaceMd
        spacing: Theme.spaceMd

        // Desktop icon tile
        Rectangle {
            implicitWidth: 32
            implicitHeight: 32
            radius: Theme.radiusSm
            color: root.isCurrentDesktop ? Theme.accentSubtle : Theme.subtleBg

            Text {
                anchors.centerIn: parent
                text: "󰍹"
                font.family: Theme.fontIcon
                font.pixelSize: 15
                color: (root.selected || root.isCurrentDesktop) ? Theme.accentHover : Theme.textSecondary
            }
        }

        // Desktop name
        Text {
            text: root.desktopName
            font.family: Theme.fontSans
            font.pixelSize: Theme.fontMd
            font.weight: (root.selected || root.isCurrentDesktop) ? Font.DemiBold : Font.Medium
            color: Theme.textPrimary
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        // Active desktop badge
        RowLayout {
            visible: root.isCurrentDesktop
            spacing: 4

            Text {
                text: "Active"
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontXs
                font.weight: Font.Medium
                color: Theme.accentHover
            }

            Text {
                text: "󰄬"
                font.family: Theme.fontIcon
                font.pixelSize: 13
                color: Theme.accentHover
            }
        }

        // Return hint on highlighted item
        Text {
            visible: root.selected && !root.isCurrentDesktop
            text: "󰌑"
            font.family: Theme.fontIcon
            font.pixelSize: 13
            color: Theme.accentHover
        }
    }

    MouseArea {
        id: itemMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered()
        onClicked: root.clicked(root.desktopName)
    }
}
