import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import "../libs"

Rectangle {
    id: root

    required property DesktopEntry entry
    required property bool active

    signal clicked(DesktopEntry entry)

    // Appearance
    color: active ? Qt.rgba(0.5, 0.5, 0.5, 0.2) : "transparent"
    radius: height / 4

    RowLayout {
        // Layout
        anchors.fill: parent

        // Icon
        Rectangle {
            // Layout
            implicitWidth: parent.height
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: height / 8

            // Appearance
            radius: height / 4
            color: Qt.rgba(0.5, 0.5, 0.5, 0.2)

            IconImage {
                source: LibIcon.getIconPath(root.entry?.icon)

                // Layout
                anchors.centerIn: parent
                implicitSize: parent.height * 0.8
            }
        }

        // Name and short description
        Rectangle {
            // Layout
            implicitWidth: parent.width - parent.height
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: height / 8

            // Appearance
            color: "transparent"

            ColumnLayout {
                // Layout
                anchors.fill: parent

                Text {
                    text: root.entry?.name || ""

                    // Layout
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // Appearance
                    color: "#ffffff"
                    font.pixelSize: root.height / 4
                }

                Text {
                    text: root.entry?.genericName || ""

                    // Layout
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // Appearance
                    color: "#aaaaaa"
                    font.pixelSize: root.height / 4
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.clicked(root.entry);
        }
    }
}
