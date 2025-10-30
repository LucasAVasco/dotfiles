pragma ComponentBehavior: Bound

import QtQuick

Rectangle {
    id: root

    signal rightClicked(var data)

    required property ListModel notifications
    required property int notificationHeight
    required property int notificationSpacing

    // Appearance
    radius: root.width / 20
    color: "#222222"
    border.color: "#111111"

    ListView {
        id: list

        model: root.notifications

        // Layout
        anchors.fill: parent
        spacing: root.notificationSpacing

        delegate: NotificationPopup {
            id: notificationPopup

            required property var modelData

            notification: modelData.notification
            receivedAt: modelData.receivedAt

            // Layout
            implicitWidth: root.width
            implicitHeight: root.notificationHeight

            // Appearance
            visible: modelData.notification !== null

            // Mouse behavior. Left click or drag from the left to the right to remove the notification. Right click to select it.
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                property double startGrabX: Infinity

                onPressed: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        return;
                    } else if (mouse.button === Qt.LeftButton) {
                        startGrabX = mouse.x;
                    }
                }

                onReleased: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        root.rightClicked(notificationPopup.modelData);
                        return;
                    } else if (mouse.button === Qt.LeftButton) {
                        let dx = mouse.x - startGrabX;

                        // Left click or dragged from the left to the right
                        if (dx === 0 || dx > root.width / 2) {
                            removeAnimation.start();
                            startGrabX = Infinity; // Reset
                        }
                    }
                }
            }

            // Animation
            SequentialAnimation {
                id: removeAnimation

                NumberAnimation {
                    target: notificationPopup
                    property: "x"
                    to: notificationPopup.width
                    duration: 200
                }

                onFinished: {
                    notificationPopup.modelData.notification.expire();
                }
            }
        }
    }
}
