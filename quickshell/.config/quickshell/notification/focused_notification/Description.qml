pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Notifications

import "../../components"

Rectangle {
    id: root

    required property Notification notification
    required property date receivedAt

    // Appearance
    color: "#444444"
    radius: height / 6

    GridLayout {
        // Layout
        anchors.fill: parent
        columns: 2
        rows: 4
        rowSpacing: width / 100
        columnSpacing: width / 10
        anchors.margins: width / 40

        EntryKey {
            text: "App name"
        }

        EntryValue {
            text: root.notification?.appName || ""
        }

        EntryKey {
            text: "Desktop entry"
        }

        EntryValue {
            text: root.notification?.desktopEntry || ""
        }

        EntryKey {
            text: "Received at"
        }

        EntryValue {
            text: root.receivedAt
        }

        EntryKey {
            text: "Summary"
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            implicitHeight: 100

            TextArea {
                id: body

                text: root.notification?.summary || ""
                readOnly: true
                wrapMode: Text.WordWrap // Limit the text

                // Layout
                anchors.fill: parent

                // Appearance
                color: "#ffffff"
            }
        }
    }

    component EntryKey: LimitedText {
        color: "#aaaaaa"
        Layout.fillHeight: true
    }

    component EntryValue: LimitedText {
        color: "#aaaaaa"
        Layout.fillWidth: true
        Layout.fillHeight: true
    }
}
