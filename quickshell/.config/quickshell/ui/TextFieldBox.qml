import QtQuick
import QtQuick.Layouts

import "../theme"

Rectangle {
    id: root

    property alias text: input.text
    property string placeholderText: ""
    property string leadingIcon: ""
    property bool showClearButton: true
    property int echoMode: TextInput.Normal
    property alias inputItem: input

    signal accepted
    signal escapePressed
    signal upPressed
    signal downPressed

    function focusInput() {
        input.forceActiveFocus();
    }

    implicitHeight: 38
    radius: Theme.radiusMd
    color: Theme.surfaceInput
    border.width: 1
    border.color: input.activeFocus ? Theme.accent : Theme.borderDefault
    antialiasing: true

    Behavior on border.color {
        ColorAnimation {
            duration: Theme.animFast
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spaceMd
        anchors.rightMargin: Theme.spaceSm
        spacing: Theme.spaceSm

        Text {
            visible: root.leadingIcon.length > 0
            text: root.leadingIcon
            font.family: Theme.fontIcon
            font.pixelSize: 15
            color: input.activeFocus ? Theme.accentHover : Theme.textMuted

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animFast
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                visible: input.text.length === 0 && root.placeholderText.length > 0
                text: root.placeholderText
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontMd
                color: Theme.textMuted
                elide: Text.ElideRight
            }

            TextInput {
                id: input
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                color: Theme.textPrimary
                selectionColor: Theme.accent
                selectedTextColor: Theme.textOnAccent
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontMd
                echoMode: root.echoMode
                verticalAlignment: TextInput.AlignVCenter
                clip: true

                Keys.onPressed: function (event) {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        event.accepted = true;
                        root.accepted();
                    } else if (event.key === Qt.Key_Escape) {
                        event.accepted = true;
                        root.escapePressed();
                    } else if (event.key === Qt.Key_Up) {
                        event.accepted = true;
                        root.upPressed();
                    } else if (event.key === Qt.Key_Down) {
                        event.accepted = true;
                        root.downPressed();
                    }
                }
            }
        }

        IconButton {
            visible: root.showClearButton && input.text.length > 0
            icon: "󰅖"
            iconSize: 13
            buttonSize: 24
            iconColor: Theme.textMuted
            onClicked: {
                input.text = "";
                input.forceActiveFocus();
            }
        }
    }
}
