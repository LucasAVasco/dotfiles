import QtQuick
import QtQuick.Layouts

import "../services"
import "../theme"

Rectangle {
    id: root

    property string text: ""
    property string icon: ""
    // "secondary" | "primary" | "danger" | "ghost" | "warning"
    property string variant: "secondary"
    property bool disabled: false
    property bool compact: false
    property bool active: false

    signal clicked

    readonly property bool hovered: mouseArea.containsMouse && !disabled
    readonly property bool pressed: mouseArea.pressed && !disabled
    readonly property bool showFocusRing: activeFocus && ShellState.keyboardFocusVisible

    activeFocusOnTab: !disabled
    implicitWidth: contentRow.implicitWidth + (compact ? Theme.spaceMd * 2 : Theme.spaceLg * 2)
    implicitHeight: compact ? 30 : 36
    radius: Theme.radiusMd
    opacity: disabled ? 0.45 : 1.0
    antialiasing: true

    color: {
        if (variant === "primary") {
            if (pressed)
                return Theme.accentActive;
            if (hovered || showFocusRing)
                return Theme.accentHover;
            return Theme.accent;
        }
        if (variant === "danger") {
            if (pressed)
                return Theme.dangerActive;
            if (hovered || showFocusRing)
                return Theme.dangerHover;
            return Theme.danger;
        }
        if (variant === "warning") {
            if (pressed)
                return Theme.warningBorder;
            if (hovered || showFocusRing)
                return Qt.rgba(0.96, 0.76, 0.07, 0.26);
            return Theme.warningSubtle;
        }
        if (variant === "ghost") {
            if (pressed)
                return Theme.pressedBg;
            if (hovered || active || showFocusRing)
                return Theme.hoverBg;
            return "transparent";
        }
        if (pressed)
            return Theme.pressedBg;
        if (hovered || active || showFocusRing)
            return Theme.surfaceOverlay;
        return Theme.surfaceElevated;
    }

    border.width: showFocusRing ? 2 : ((variant === "ghost" && !active) ? 0 : 1)
    border.color: {
        if (showFocusRing)
            return Theme.accentHover;
        if (variant === "primary" || variant === "danger")
            return Qt.rgba(1, 1, 1, 0.12);
        if (variant === "warning")
            return Theme.warningBorder;
        if (active)
            return Theme.accentBorder;
        return Theme.borderSubtle;
    }

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

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: Theme.spaceSm

        Text {
            visible: root.icon.length > 0
            text: root.icon
            font.family: Theme.fontIcon
            font.pixelSize: root.compact ? 13 : 15
            color: labelText.color
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            id: labelText
            visible: root.text.length > 0
            text: root.text
            font.family: Theme.fontSans
            font.pixelSize: root.compact ? Theme.fontSm : Theme.fontMd
            font.weight: (root.variant === "primary" || root.variant === "danger") ? Font.DemiBold : Font.Medium
            color: {
                if (root.variant === "primary" || root.variant === "danger")
                    return Theme.textOnAccent;
                if (root.variant === "warning")
                    return Theme.warning;
                return Theme.textPrimary;
            }
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: !root.disabled
        cursorShape: root.disabled ? Qt.ArrowCursor : Qt.PointingHandCursor

        onClicked: root.clicked()
    }
}
