import QtQuick

import "../services"
import "../theme"

Rectangle {
    id: root

    property string icon: ""
    property int iconSize: 15
    property int buttonSize: 28
    property bool active: false
    property bool disabled: false
    property bool dangerHover: false
    property color iconColor: Theme.textPrimary

    signal clicked
    signal middleClicked
    signal rightClicked

    readonly property bool hovered: mouseArea.containsMouse && !disabled
    readonly property bool pressed: mouseArea.pressed && !disabled
    readonly property bool showFocusRing: activeFocus && ShellState.keyboardFocusVisible

    activeFocusOnTab: !disabled
    implicitWidth: buttonSize
    implicitHeight: buttonSize
    radius: Theme.radiusPill
    opacity: disabled ? 0.45 : 1.0
    antialiasing: true

    color: {
        if (dangerHover && pressed)
            return Theme.danger;
        if (dangerHover && (hovered || showFocusRing))
            return Theme.dangerSubtle;
        if (pressed)
            return Theme.pressedBg;
        if (hovered || showFocusRing)
            return Theme.hoverBg;
        if (active)
            return Theme.accentSubtle;
        return "transparent";
    }

    border.width: showFocusRing ? 2 : 0
    border.color: Theme.accentHover

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
            root.clicked();
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        font.family: Theme.fontIcon
        font.pixelSize: root.iconSize
        color: {
            if (root.dangerHover && (root.hovered || root.activeFocus))
                return Theme.dangerHover;
            if (root.active)
                return Theme.accentHover;
            return root.iconColor;
        }

        Behavior on color {
            ColorAnimation {
                duration: Theme.animFast
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: !root.disabled
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        cursorShape: root.disabled ? Qt.ArrowCursor : Qt.PointingHandCursor

        onClicked: function (mouse) {
            if (mouse.button === Qt.LeftButton)
                root.clicked();
            else if (mouse.button === Qt.MiddleButton)
                root.middleClicked();
            else if (mouse.button === Qt.RightButton)
                root.rightClicked();
        }
    }
}
