import QtQuick

import "../services"
import "../theme"

Rectangle {
    id: root

    property bool checked: false
    property bool disabled: false

    signal toggled(bool checked)

    readonly property bool showFocusRing: activeFocus && ShellState.keyboardFocusVisible

    activeFocusOnTab: !disabled
    implicitWidth: 42
    implicitHeight: 24
    radius: Theme.radiusPill
    opacity: disabled ? 0.45 : 1.0
    antialiasing: true

    color: checked ? Theme.accent : Theme.surfaceOverlay
    border.width: showFocusRing ? 2 : 1
    border.color: showFocusRing ? Theme.accentHover : (checked ? Theme.accentHover : Theme.borderDefault)

    Behavior on color {
        ColorAnimation {
            duration: Theme.animFast
        }
    }

    Keys.onPressed: function (event) {
        if (root.disabled)
            return;
        if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
            ShellState.markKeyboardNav();
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            event.accepted = true;
            root.checked = !root.checked;
            root.toggled(root.checked);
        }
    }

    Rectangle {
        id: knob
        width: 18
        height: 18
        radius: 9
        anchors.verticalCenter: parent.verticalCenter
        x: root.checked ? (root.width - width - 3) : 3
        color: "#ffffff"
        antialiasing: true

        Behavior on x {
            NumberAnimation {
                duration: Theme.animFast
                easing.type: Easing.OutCubic
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: !root.disabled
        cursorShape: root.disabled ? Qt.ArrowCursor : Qt.PointingHandCursor
        onClicked: {
            root.checked = !root.checked;
            root.toggled(root.checked);
        }
    }
}
