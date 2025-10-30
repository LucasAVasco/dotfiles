import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

PanelWindow {
    id: root

    signal done

    required property Notification notification

    focusable: true

    // Layout
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: Math.max(screen.width / 4, 300)
    implicitHeight: Math.max(screen.height / 3, 300)

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
        anchors.fill: parent

        // Appearance
        color: "#222222"
        radius: height / 20
        border.color: "#111111"

        ColumnLayout {
            // Layout
            anchors.fill: parent
            anchors.margins: height / 20
            spacing: height / 20

            // First line
            Rectangle {
                // Layout
                implicitHeight: 10
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Appearance
                color: "transparent"

                RowLayout {
                    anchors.fill: parent

                    Text {
                        text: root.notification?.inlineReplyPlaceholder || "Reply"
                        color: "#aaaaaa"
                    }

                    Button {
                        text: "Cancel"

                        // Layout
                        Layout.alignment: Qt.AlignRight

                        // Appearance
                        background: Rectangle {
                            anchors.fill: parent
                            color: "#444444"
                            radius: height / 4
                        }
                        palette.buttonText: "white"

                        // Signals
                        onClicked: {
                            root.done();
                        }
                    }
                }
            }

            // Second line
            Rectangle {
                id: inputArea

                // Layout
                implicitHeight: 80
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Appearance
                color: "#444444"
                radius: height / 20

                // Contents
                ScrollView {
                    anchors.fill: parent

                    TextArea {
                        id: response

                        wrapMode: Text.WordWrap // Limit the text

                        // Layout
                        anchors.fill: parent

                        // Appearance
                        color: "white"
                        placeholderText: "Insert your message here"
                        placeholderTextColor: "#aaaaaa"
                        font.pointSize: Math.max(inputArea.height / 20, 10)
                    }
                }
            }

            // Third line
            Button {
                // Content
                text: "Send"

                // Layout
                implicitHeight: 10
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Appearance
                background: Rectangle {
                    anchors.fill: parent
                    color: "#444444"
                    radius: height / 4
                }

                palette.buttonText: "white"

                // Signals
                onClicked: {
                    root.notification.sendInlineReply(response.text);
                    root.done();
                }
            }
        }
    }

    // Closes the PopUp if the notification expired
    onNotificationChanged: {
        if (notification === null) {
            root.done();
        }
    }
}
