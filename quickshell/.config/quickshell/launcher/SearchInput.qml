import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    signal enter
    signal abort
    signal nextApp
    signal previousApp

    readonly property string text: input.text

    // Appearance
    color: Qt.rgba(0.5, 0.5, 0.5, 0.2)
    radius: height / 2

    RowLayout {
        anchors.fill: parent

        Text {
            text: "󰍉"
            Layout.leftMargin: Math.max(parent.height / 2, 20)
            Layout.rightMargin: Layout.leftMargin / 2
            font.pointSize: Math.max(parent.height / 2, 10)
        }

        TextInput {
            id: input
            focus: true

            // Layout
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Appearance
            color: "#ffffff"
            font.pointSize: Math.max(parent.height / 2, 10)
        }
    }

    // Fallback actions (only the key events that the text input does not use are handled here)
    Keys.onPressed: function (event) {
        switch (event.key) {
        case Qt.Key_Escape:
            abort();
            break;
        case Qt.Key_Enter:
        case Qt.Key_Return:
            enter();
            break;
        case Qt.Key_Up:
            previousApp();
            break;
        case Qt.Key_Down:
            nextApp();
            break;
        default:
            break;
        }
    }
}
