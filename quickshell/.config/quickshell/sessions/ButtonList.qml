pragma ComponentBehavior: Bound

import QtQuick

Rectangle {
    id: root

    signal selected(PopupButton button)

    readonly property PopupButton currentButton: list.currentItem as PopupButton || null

    function nextButton() {
        list.incrementCurrentIndex();
    }

    function prevButton() {
        list.decrementCurrentIndex();
    }

    function executeCurrentButton() {
        selected(currentButton);
    }

    // Layout
    implicitHeight: root.width / buttons.count // Each button is a square (width = height)

    // Appearance
    color: "transparent"

    // Buttons
    ListModel {
        id: buttons

        ListElement {
            text: ""
            command: "shutdown now"
        }

        ListElement {
            text: ""
            command: "reboot"
        }

        ListElement {
            text: "󰏤"
            command: "systemctl suspend"
        }

        ListElement {
            text: "󰒲"
            command: "systemctl hibernate"
        }

        ListElement {
            text: "󰌾"
            command: "~/.config/screenlocker/manager.sh run"
        }

        ListElement {
            text: "󰍃"
            command: "~/.config/quickshell/sessions/scripts/logout.sh"
        }
    }

    ListView {
        id: list

        currentIndex: 0

        // Layout
        anchors.fill: parent
        orientation: Qt.Horizontal

        // Models
        model: buttons
        delegate: PopupButton {
            required property int index

            active: root.currentButton == this

            // Layout
            implicitWidth: root.width / buttons.count
            implicitHeight: root.height

            // Signals
            onClicked: {
                root.selected(this);
            }

            onHoveredChanged: {
                list.currentIndex = index;
            }
        }
    }
}
