import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications

import "../components"

// App icon, image and notification description
Rectangle {
    id: root

    required property Notification notification
    required property date receivedAt

    color: "transparent"

    RowLayout {
        anchors.fill: parent

        NotificationIcon {
            id: icon

            notification: root.notification

            // Layout
            Layout.fillHeight: true
            Layout.fillWidth: true
            implicitHeight: root.height
        }

        // Description of the notification
        Description {
            notification: root.notification
            receivedAt: root.receivedAt

            // Layout
            Layout.fillHeight: true
            Layout.fillWidth: true
            implicitWidth: root.width - icon.implicitWidth
            implicitHeight: root.height

            // Appearance
            color: "#444444"
        }
    }
}
