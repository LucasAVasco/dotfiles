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
}
