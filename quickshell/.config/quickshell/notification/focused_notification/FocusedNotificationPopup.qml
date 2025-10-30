pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

PanelWindow {
    id: root

    signal done
    signal inlineReply(Notification notification)

    required property var notificationData
    readonly property Notification notification: notificationData.notification // Required to track the state of the notification

    // Layout
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: Math.max(screen.width / 4, 300)
    implicitHeight: Math.max(screen.height / 2, 400)

    margins {
        bottom: 40
        right: 40
    }

    anchors {
        bottom: true
        right: true
    }

    // Appearance
    color: "transparent"

    Rectangle {
        // Layout
        anchors.fill: parent
        radius: height / 20

        // Appearance
        color: "#222222"
        border.color: "#111111"

        ColumnLayout {
            // Layout
            anchors.fill: parent
            anchors.margins: height / 30
            spacing: height / 30

            Preview {
                notification: root.notification
                receivedAt: root.notificationData?.receivedAt

                // Layout
                implicitHeight: 20
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            Body {
                notification: root.notification

                // Layout
                implicitHeight: 70
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            // Action buttons (from notification and custom actions)
            Rectangle {
                // Layout
                implicitHeight: 10
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Appearance
                color: "transparent"

                RowLayout {
                    // Layout
                    anchors.fill: parent
                    spacing: width / 40

                    // List of action buttons
                    ActionList {
                        notification: root.notification
                        orientation: Qt.Horizontal

                        implicitWidth: 60
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    // Custom action buttons
                    Rectangle {
                        // Layout
                        implicitWidth: 40
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        // Appearance
                        color: "#222222"

                        RowLayout {
                            // Layout
                            anchors.fill: parent
                            anchors.leftMargin: width / 20

                            // Inline reply button
                            DefaultActionButton {
                                visible: root.notification?.hasInlineReply || false

                                text: root.notification?.inlineReplyPlaceholder || "Reply"

                                onClicked: {
                                    root.inlineReply(root.notification);
                                }
                            }

                            // Expire button
                            DefaultActionButton {
                                text: "Expire"

                                onClicked: {
                                    root.notification.expire();
                                }
                            }

                            // Exit button
                            DefaultActionButton {
                                text: "Exit"

                                onClicked: {
                                    root.done();
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    component DefaultActionButton: Button {
        // Layout
        Layout.fillHeight: true
        Layout.fillWidth: true

        // Appearance
        background: Rectangle {
            anchors.fill: parent
            color: "#444444"
            radius: height / 4
        }

        palette.buttonText: "white"
    }

    // Closes the PopUp when the notification is null
    onNotificationChanged: {
        if (notification === null) {
            root.done();
        }
    }
}
