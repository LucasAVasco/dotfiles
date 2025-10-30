import QtQuick
import QtQuick.Controls
import Quickshell.Services.Notifications

Rectangle {
    id: root

    required property Notification notification

    // Appearance
    color: "#444444"
    radius: height / 6

    ScrollView {
        // Layout
        anchors.fill: parent
        anchors.margins: height / 10

        TextArea {
            id: body

            text: root.notification?.body || ""
            readOnly: true
            wrapMode: Text.WordWrap // Limit the text

            // Layout
            anchors.fill: parent

            // Appearance
            color: "#ffffff"
            textFormat: TextEdit.RichText
        }
    }
}
