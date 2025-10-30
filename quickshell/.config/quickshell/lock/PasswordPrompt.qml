pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    focus: true

    property string password

    signal passwordGiven(string password)

    function givePassword() {
        root.focus = true;
        root.passwordGiven(root.password);
        root.password = "";
    }

    function showErrorMessage(message) {
        errorMessage.text = message;
        inputIndicator.color = Qt.rgba(255, 0, 0, 0.5);
    }

    function clearPassword() {
        root.password = "";
        errorMessage.text = "";
        inputIndicator.color = Qt.rgba(255, 255, 255, 0);
    }

    // Layout
    anchors.centerIn: parent
    width: 80
    height: width * 3 / 5
    radius: width / 2

    // Area of the error message
    Rectangle {
        // Position
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom
        anchors.topMargin: 10

        // Size
        width: errorMessage.width + 10
        height: errorMessage.height + 10
        radius: height / 2

        // Appearance
        color: errorMessage.text.length == 0 ? Qt.rgba(0, 0, 0, 0) : Qt.rgba(0, 0, 0, 0.8)

        // Text that displays the error message
        Text {
            id: errorMessage
            text: ""

            // Position
            anchors.centerIn: parent

            // Appearance
            font.pointSize: Math.max(root.height / 5, 10)
            color: Qt.rgba(255, 255, 255, 0.5)
        }
    }

    // Circle that changes the color when the user presses a key
    Rectangle {
        id: inputIndicator

        color: Qt.rgba(255, 255, 255, 0)

        // Position
        anchors.verticalCenter: root.verticalCenter
        anchors.left: root.left
        anchors.leftMargin: root.width / 10

        // Size
        height: parent.height / 2
        width: height
        radius: height / 2
    }

    // Click in the rectangle to focus. Must be placed at the top of the stack, so it will not overlap the button
    MouseArea {
        anchors.fill: root
        onClicked: function () {
            root.focus = true;
        }
    }

    // Button to give the password
    RoundButton {
        id: givePasswordButton

        // Position
        anchors.right: root.right
        anchors.verticalCenter: root.verticalCenter
        anchors.rightMargin: root.width / 10

        // Size
        height: parent.height * 3 / 4
        width: height
        radius: height / 2

        // Signals handling
        onClicked: function () {
            root.givePassword();
        }
    }

    // The keys pressed by the user will be handled here
    Keys.onPressed: function (event) {
        switch (event.key) {
        case Qt.Key_Enter:
        case Qt.Key_Return:
            root.givePassword();
            break;
        case Qt.Key_Escape:
            root.clearPassword();
            break;
        case Qt.Key_Backspace:
            root.password = root.password.slice(0, -1);
            break;
        default:
            if (event.text) {
                root.password += event.text;
            }
            break;
        }

        errorMessage.text = "";
        inputIndicator.color = root.password.length > 0 ? Qt.rgba(0, 1.0, 0, 0.5) : Qt.rgba(1.0, 1.0, 1.0, 0);
    }
}
