import QtQuick
import Quickshell.Services.Notifications
import Quickshell.Widgets

import "../../libs"

// App icon and image
Rectangle {
    id: root

    required property Notification notification

    // Layout
    implicitWidth: (root.notification?.image) ? root.height : root.height / 3 // Conditionally reserves space for the image

    // Appearance
    radius: root.height / 4
    color: "transparent"

    // Image
    // NOTE(LucasAVasco): the QuickShell documentation says that messages apps may send the user picture as a image
    IconImage {
        visible: root.notification?.image !== null
        source: Qt.url(root.notification?.image || "")

        // Layout
        anchors.fill: parent
        implicitSize: root.height / 2
    }

    // App icon
    Rectangle {
        // Layout
        anchors.left: parent.left
        anchors.top: parent.top
        width: root.height / 3
        height: root.height / 3

        // Appearance
        radius: height / 2
        color: "#444444"

        IconImage {
            source: LibIcon.getIconPath(root.notification?.appIcon)

            anchors.centerIn: parent
            implicitSize: parent.height * 0.7
        }
    }

    // Urgency indicator
    Rectangle {
        // Appearance
        radius: height / 2
        color: {
            switch (root.notification?.urgency) {
            case NotificationUrgency.Critical:
                return "#aa0000";
                break;
            case NotificationUrgency.Low:
                return "#006600";
                break;
            case NotificationUrgency.Normal:
            }

            return "transparent";
        }

        // Layout
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: root.height / 3
        height: root.height / 3
    }
}
