pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import "../theme"
import "../ui"

ColumnLayout {
    id: root
    focus: true

    property string password: ""
    property bool authenticating: false
    property string errorText: ""

    signal passwordGiven(string password)

    spacing: Theme.spaceSm

    function givePassword() {
        if (authenticating || password.length === 0)
            return;
        root.focus = true;
        let pwd = root.password;
        root.password = "";
        root.errorText = "";
        root.passwordGiven(pwd);
    }

    function showErrorMessage(message) {
        errorText = message;
        shakeAnim.restart();
    }

    function clearPassword() {
        root.password = "";
        root.errorText = "";
    }

    // Pill password input container
    Rectangle {
        id: inputBox
        Layout.fillWidth: true
        implicitHeight: 46
        radius: Theme.radiusPill
        color: Theme.popoverBg
        border.width: 1
        border.color: root.errorText.length > 0 ? Theme.danger : (root.activeFocus ? Theme.accent : Theme.borderDefault)
        antialiasing: true

        transform: Translate {
            id: shakeTransform
            x: 0
        }

        SequentialAnimation {
            id: shakeAnim
            NumberAnimation { target: shakeTransform; property: "x"; to: -8; duration: 50 }
            NumberAnimation { target: shakeTransform; property: "x"; to: 8; duration: 50 }
            NumberAnimation { target: shakeTransform; property: "x"; to: -5; duration: 50 }
            NumberAnimation { target: shakeTransform; property: "x"; to: 5; duration: 50 }
            NumberAnimation { target: shakeTransform; property: "x"; to: 0; duration: 40 }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: Theme.animFast
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.focus = true
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.spaceLg
            anchors.rightMargin: Theme.spaceXs
            spacing: Theme.spaceSm

            Text {
                text: "󰌾"
                font.family: Theme.fontIcon
                font.pixelSize: 15
                color: Theme.textMuted
            }

            // Masked password dots or placeholder
            Text {
                Layout.fillWidth: true
                text: {
                    if (root.authenticating)
                        return "Unlocking…";
                    if (root.password.length === 0)
                        return "Enter password";
                    return "•".repeat(Math.min(root.password.length, 32));
                }
                font.family: Theme.fontSans
                font.pixelSize: root.password.length > 0 ? 18 : Theme.fontMd
                font.letterSpacing: root.password.length > 0 ? 3 : 0
                color: (root.password.length > 0 && !root.authenticating) ? Theme.textPrimary : Theme.textMuted
                elide: Text.ElideLeft
                verticalAlignment: Text.AlignVCenter
            }

            IconButton {
                icon: root.authenticating ? "󰔟" : "󰁔"
                iconSize: 16
                buttonSize: 36
                disabled: root.authenticating || root.password.length === 0
                active: root.password.length > 0
                onClicked: root.givePassword()
            }
        }
    }

    // Error message pill
    Rectangle {
        visible: root.errorText.length > 0
        Layout.alignment: Qt.AlignHCenter
        implicitWidth: errLabel.implicitWidth + Theme.spaceLg * 2
        implicitHeight: 28
        radius: Theme.radiusPill
        color: Theme.dangerSubtle
        border.width: 1
        border.color: Theme.dangerBorder

        Text {
            id: errLabel
            anchors.centerIn: parent
            text: root.errorText
            font.family: Theme.fontSans
            font.pixelSize: Theme.fontXs
            font.weight: Font.Medium
            color: Theme.dangerHover
        }
    }

    Keys.onPressed: function (event) {
        if (root.authenticating)
            return;

        switch (event.key) {
        case Qt.Key_Enter:
        case Qt.Key_Return:
            root.givePassword();
            break;
        case Qt.Key_Escape:
            root.clearPassword();
            break;
        case Qt.Key_Backspace:
            if (event.modifiers & Qt.ControlModifier) {
                root.password = "";
            } else {
                root.password = root.password.slice(0, -1);
            }
            root.errorText = "";
            break;
        default:
            if (event.text && event.text.length > 0 && !(event.modifiers & Qt.ControlModifier)) {
                root.password += event.text;
                root.errorText = "";
            }
            break;
        }
    }
}
