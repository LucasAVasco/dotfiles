import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications

import "../components"

Rectangle {
    id: root

    required property Notification notification
    required property date receivedAt

    // Appearance
    radius: height / 4
    color: "transparent"

    RowLayout {
        anchors.fill: parent

        // Notification icon
        NotificationIcon {
            notification: root.notification

            // Layout
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: height / 10
        }

        // Notification description and actions
        Description {
            notification: root.notification
            receivedAt: root.receivedAt

            // Layout
            implicitWidth: root.width - root.height
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: height / 10
        }
    }
}
