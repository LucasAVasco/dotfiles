pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Notifications

ListView {
    id: root

    required property Notification notification

    model: notification?.actions

    // Layout
    spacing: height / 10

    delegate: ActionButton {
        required property NotificationAction modelData

        implicitHeight: root.height

        notificationAction: modelData
        hasActionIcons: root.notification?.hasActionIcons || false
    }

    // MouseArea to capture mouse wheel events
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton // Only react to mouse wheel events

        onWheel: {
            wheel.accepted = true; // Accept the wheel event to prevent it from being sent to other widgets

            let nextContentX = root.contentX - wheel.angleDelta.y;
            if (nextContentX > 0 && nextContentX < root.contentWidth - root.width) {
                root.contentX = nextContentX;
            }
        }
    }
}
