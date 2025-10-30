pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

PanelWindow {
    id: root

    signal done
    signal notificationSelected(var notificationData)

    function addNotification(notification) {
        notification.tracked = true; // Avoids dismissing the notification

        let duration = (notification.expireTimeout > 0) ? notification.expireTimeout * 1000 : 15000;

        let item = {
            notification: notification,
            receivedAt: new Date(),
            expireAt: Date.now() + duration
        };

        // Remove notification from the list when it is closed
        notification.closed.connect(function () {
            for (var i = 0; i < notifications.count; i++) {
                if (notifications.get(i).data.notification === notification) {
                    notifications.remove(i);
                    break;
                }
            }
        });

        // Insert notification at the top
        notifications.insert(0, {
            data: item
        });
    }

    function dismissAll() {
        for (var i = notifications.count - 1; i >= 0; --i) {
            let notification = notifications.get(i).data.notification as Notification;
            if (notification !== null) {
                notification.expire();
            }
        }
    }

    property bool disableAutoExpire: false

    // Layout
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: Math.max(screen.width / 4, 300)
    readonly property int notificationHeight: implicitWidth / 5
    readonly property int notificationSpacing: screen.height / 100
    implicitHeight: {
        let numberOfNotifications = Math.min(3, notifications.count);

        return root.notificationHeight * numberOfNotifications + (numberOfNotifications - 1) * root.notificationSpacing;
    }

    anchors {
        top: true
        right: true
    }

    margins {
        top: 40
        right: 40
    }

    // Appearance
    color: "transparent"

    // List of notifications
    ListModel {
        id: notifications
    }

    NotificationList {
        notifications: notifications

        // Layout
        notificationHeight: root.notificationHeight
        notificationSpacing: root.notificationSpacing
        anchors.fill: parent

        // Signals
        onRightClicked: function (notificationData) {
            root.disableAutoExpire = true;
            root.notificationSelected(notificationData);
        }
    }

    // Timer to remove expired notifications
    Timer {
        interval: 1000
        repeat: true
        running: true

        onTriggered: function () {
            if (root.disableAutoExpire) {
                return;
            }

            // Removes expired notifications
            for (var i = notifications.count - 1; i >= 0; --i) {
                let element = notifications.get(i);

                if (element.data.expireAt < Date.now()) {
                    let notification = element.data.notification as Notification;
                    if (notification !== null) {
                        notification.expire();
                    }
                }
            }

            // Closes the widget when there are no more notifications
            if (notifications.count === 0) {
                root.done();
            }
        }
    }
}
