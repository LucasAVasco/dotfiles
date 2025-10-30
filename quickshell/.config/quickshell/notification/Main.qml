pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import Quickshell.Services.Notifications

import "../components"
import "./focused_notification"
import "./inline_reply"
import "./notification_viewer"

Item {
    // Notification preview
    TempItem {
        id: notificationViewerLoader

        NotificationViewer {
            onNotificationSelected: function (data) {
                focusedNotificationLoader.notificationData = data;
                focusedNotificationLoader.load();
                inlineReplyLoader.active = false;
            }
        }
    }

    // Focused notification PopUp
    TempItem {
        id: focusedNotificationLoader

        property var notificationData

        FocusedNotificationPopup {
            notificationData: focusedNotificationLoader.notificationData

            // Signals
            onInlineReply: function (notification) {
                inlineReplyLoader.notification = notification;
                inlineReplyLoader.load();
            }

            onDone: function () {
                // Enable automatic expiration of old notifications
                let item = notificationViewerLoader.item as NotificationViewer;
                item.disableAutoExpire = false;

                // Closes the inline reply
                inlineReplyLoader.active = false;
            }
        }
    }

    // Inline reply PopUp
    TempItem {
        id: inlineReplyLoader

        property Notification notification

        InlineReplyPopup {
            notification: inlineReplyLoader.notification
        }
    }

    // Server that receives the notifications
    NotificationServer {
        actionIconsSupported: true
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        bodySupported: true
        imageSupported: true
        inlineReplySupported: true

        // Signals
        onNotification: function (notification) {
            notificationViewerLoader.load();
            let item = notificationViewerLoader.item as NotificationViewer;
            item.addNotification(notification);
        }
    }

    // Receives the commands from the user
    IpcHandler {
        target: "notification"

        function dismissAll() {
            if (notificationViewerLoader.item !== null) {
                let item = notificationViewerLoader.item as NotificationViewer;
                item.dismissAll();
            }
        }
    }
}
