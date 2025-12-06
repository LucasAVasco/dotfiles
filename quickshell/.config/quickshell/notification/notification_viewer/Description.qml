import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Notifications

import "../../components"
import "../../timers"

// Notification description and actions
Rectangle {
    id: root

    required property Notification notification
    required property date receivedAt

    // Appearance
    color: "#444444"
    radius: height / 4

    ColumnLayout {
        // Layout
        anchors.fill: parent
        anchors.margins: height / 10

        // Notification texts
        Rectangle {
            // Layout
            Layout.fillWidth: true
            Layout.fillHeight: true
            implicitHeight: parent.height * 3 / 4
            Layout.margins: height / 10

            // Appearance
            color: "#444444"

            ColumnLayout {
                id: description
                anchors.fill: parent

                // Header
                Rectangle {
                    // Layout
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    implicitHeight: 40

                    // Appearance
                    color: "transparent"

                    // Summary and application name
                    Rectangle {
                        // Layout
                        anchors.left: parent.left
                        anchors.top: parent.top
                        width: parent.width * 0.8
                        height: parent.height

                        // Appearance
                        color: "transparent"

                        LimitedText {
                            text: {
                                let content = root.notification?.summary || "";

                                if (root.notification?.appName) {
                                    content += "    󰋇   " + root.notification?.appName;
                                }

                                if (root.notification?.desktopEntry) {
                                    content += " (" + root.notification?.desktopEntry + ")";
                                }

                                return content;
                            }

                            // Layout
                            anchors.fill: parent

                            // Appearance
                            color: "#aaaaaa"
                        }
                    }

                    // Time
                    Rectangle {
                        // Layout
                        anchors.right: parent.right
                        anchors.top: parent.top
                        width: parent.width * 0.2
                        height: parent.height

                        // Appearance
                        color: "transparent"

                        LimitedText {
                            text: {
                                let content = "";

                                if (root.receivedAt) {
                                    let differenceSeconds = (Timer1Sec.now - root.receivedAt) / 1000;
                                    differenceSeconds = differenceSeconds.toFixed(0); // Round
                                    content += "   " + ((differenceSeconds < 1) ? "now" : "at " + differenceSeconds + "s");
                                }

                                return content;
                            }

                            // Layout
                            anchors.fill: parent

                            // Appearance
                            color: "#aaaaaa"
                        }
                    }
                }

                // Body
                Rectangle {
                    // Layout
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    implicitHeight: 60

                    // Appearance
                    color: "transparent"

                    ScrollView {
                        anchors.fill: parent

                        TextArea {
                            id: body

                            text: root.notification?.body || ""
                            readOnly: true
                            wrapMode: Text.WordWrap // Limit the text

                            // Layout
                            anchors.fill: parent

                            // Appearance
                            background: Rectangle {
                                color: "transparent"
                            }
                            color: "#ffffff"
                            textFormat: TextEdit.RichText
                        }
                    }
                }
            }
        }
    }
}
