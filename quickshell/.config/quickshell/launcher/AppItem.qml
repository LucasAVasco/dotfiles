import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import "../libs"
import "../theme"

Rectangle {
    id: root

    required property DesktopEntry entry
    required property bool active

    signal clicked(DesktopEntry entry)
    signal hovered

    radius: Theme.radiusMd
    antialiasing: true
    color: {
        if (itemMouse.pressed)
            return Theme.pressedBg;
        if (active)
            return Theme.accentSubtle;
        if (itemMouse.containsMouse)
            return Theme.hoverBg;
        return "transparent";
    }
    border.width: active ? 1 : 0
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

        // App icon tile
        Rectangle {
            implicitWidth: 38
            implicitHeight: 38
            radius: Theme.radiusSm
            color: Theme.subtleBg

            IconImage {
                anchors.centerIn: parent
                implicitSize: 30
                source: LibIcon.getIconPath(root.entry ? root.entry.icon : undefined)
            }
        }

        // Name & subtitle
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: root.entry ? (root.entry.name || "") : ""
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontMd
                font.weight: root.active ? Font.DemiBold : Font.Medium
                color: Theme.textPrimary
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                readonly property string sub: root.entry ? (root.entry.genericName || root.entry.comment || "") : ""
                visible: sub.length > 0
                text: sub
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontXs
                color: Theme.textSecondary
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        // Return hint on active item
        Text {
            visible: root.active
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
        onClicked: root.clicked(root.entry)
    }
}
