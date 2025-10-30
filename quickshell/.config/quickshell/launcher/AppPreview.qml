pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import "../libs"

Rectangle {
    id: root

    required property DesktopEntry entry

    // Appearance
    color: "transparent"

    RowLayout {
        // Layout
        anchors.fill: parent
        spacing: parent.height / 8

        // Application icon
        Rectangle {
            // Layout
            implicitWidth: parent.height
            Layout.fillWidth: true
            Layout.fillHeight: true

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

        // Application description
        Rectangle {
            // Layout
            implicitWidth: parent.width - parent.height
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Appearance
            color: Qt.rgba(0.5, 0.5, 0.5, 0.2)
            radius: height / 4

            GridLayout {
                // Appearance
                visible: root.entry !== null

                // Layout
                anchors.fill: parent
                anchors.topMargin: parent.height / 8
                anchors.bottomMargin: parent.height / 6
                anchors.leftMargin: parent.height / 4
                anchors.rightMargin: anchors.leftMargin
                columns: 2

                Repeater {
                    id: repeater

                    property int fontSize: Math.max(parent.height / 8, 12)

                    model: [
                        {
                            text: "Name",
                            isHeader: true
                        },
                        {
                            text: root.entry?.name,
                            isHeader: false
                        },
                        {
                            text: "Generic name",
                            isHeader: true
                        },
                        {
                            text: root.entry?.genericName,
                            isHeader: false
                        },
                        {
                            text: "Categories",
                            isHeader: true
                        },
                        {
                            text: root.entry?.categories.join(", "),
                            isHeader: false
                        },
                        {
                            text: "Comment",
                            isHeader: true
                        },
                        {
                            text: root.entry?.comment,
                            isHeader: false
                        },
                        {
                            text: "Exec string",
                            isHeader: true
                        },
                        {
                            text: root.entry?.execString,
                            isHeader: false
                        }
                    ]

                    delegate: Text {
                        required property var modelData

                        text: modelData.text || ""

                        // Appearance
                        color: "#aaaaaa"
                        font.pixelSize: repeater.fontSize

                        // Layout
                        Layout.alignment: Qt.AlignCenter
                        Layout.preferredWidth: modelData.isHeader ? 20 : 80
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }
}
