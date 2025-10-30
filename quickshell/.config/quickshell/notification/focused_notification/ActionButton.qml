import QtQuick
import QtQuick.Controls
import Quickshell.Services.Notifications

import "../../libs"

Button {
    id: root

    required property NotificationAction notificationAction
    required property bool hasActionIcons

    // Content
    text: root.notificationAction?.text || ""

    icon.source: {
        if (root.hasActionIcons) {
            return LibIcon.getIconPath(root.notificationAction.identifier);
        }
    }

    // Appearance
    palette.buttonText: "white"
    padding: height / 5
    font.pixelSize: height / 3

    background: Rectangle {
        radius: height / 4
        color: "#444444"
    }

    // Signal
    onClicked: function () {
        root.notificationAction.invoke();
    }
}
