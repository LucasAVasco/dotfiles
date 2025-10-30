import QtQuick
import QtQuick.Controls

Rectangle {
    id: root

    required property string text
    required property string command
    required property bool active

    signal clicked
    signal hoveredChanged(bool hovered)

    // Appearance
    color: "transparent"

    Button {
        id: button
        text: root.text

        // Layout
        anchors.fill: parent
        anchors.centerIn: parent
        anchors.margins: Math.max(parent.width / 80, 5)

        // Appearance
        font.pixelSize: width / 5
        background: Rectangle {
            radius: width / 4 // Rounded corners

            color: {
                if (button.pressed) {
                    return Qt.rgba(1, 0.7, 0.5, 0.8);
                } else if (root.active) {
                    return Qt.rgba(0.8, 0.8, 0.8, 0.8);
                } else {
                    return Qt.rgba(0.4, 0.4, 0.4, 0.8);
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 100
                }
            }
        }

        // Signals
        onClicked: {
            root.clicked();
        }

        onHoveredChanged: {
            root.hoveredChanged(button.hovered);
        }
    }
}
