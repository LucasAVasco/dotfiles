import QtQuick

import "../services"
import "../theme"

Item {
    id: root

    property real value: 0.0
    property real maxValue: 1.0
    property bool muted: false
    // When true, dragging previews locally and emits moved() once on release (ideal for MPRIS seek)
    property bool commitOnRelease: false

    signal moved(real newValue)

    property bool _dragging: false
    property real _dragRatio: 0.0

    readonly property real validRatio: {
        if (!isFinite(maxValue) || maxValue <= 0 || !isFinite(value) || value <= 0)
            return 0.0;
        return Math.max(0.0, Math.min(1.0, value / maxValue));
    }

    readonly property real clampedRatio: _dragging ? _dragRatio : validRatio
    readonly property bool showFocusRing: activeFocus && ShellState.keyboardFocusVisible

    activeFocusOnTab: true
    implicitWidth: 180
    implicitHeight: 24

    Keys.onPressed: function (event) {
        if (!isFinite(maxValue) || maxValue <= 0)
            return;
        let step = maxValue * 0.05;
        if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
            ShellState.markKeyboardNav();
        } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Down) {
            ShellState.markKeyboardNav();
            event.accepted = true;
            root.moved(Math.max(0, (isFinite(root.value) ? root.value : 0) - step));
        } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Up) {
            ShellState.markKeyboardNav();
            event.accepted = true;
            root.moved(Math.min(root.maxValue, (isFinite(root.value) ? root.value : 0) + step));
        }
    }

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        height: 6
        radius: 3
        color: Theme.surfaceOverlay
        border.width: root.showFocusRing ? 1 : 0
        border.color: Theme.accentHover

        Rectangle {
            id: fill
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: root.clampedRatio > 0 ? Math.max(height, parent.width * root.clampedRatio) : 0
            radius: 3
            color: root.muted ? Theme.textMuted : Theme.accent

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animFast
                }
            }
        }
    }

    Rectangle {
        id: handle
        width: (dragArea.containsMouse || dragArea.pressed || root.showFocusRing) ? 16 : 14
        height: width
        radius: width / 2
        anchors.verticalCenter: parent.verticalCenter
        x: Math.max(0, Math.min(root.width - width, root.width * root.clampedRatio - width / 2))
        color: "#ffffff"
        border.width: 2
        border.color: root.showFocusRing ? Theme.accentHover : (root.muted ? Theme.textMuted : Theme.accent)
        antialiasing: true

        Behavior on width {
            NumberAnimation {
                duration: Theme.animFast
            }
        }
    }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        function ratioFromX(mouseX) {
            return Math.max(0.0, Math.min(1.0, mouseX / Math.max(1, root.width)));
        }

        onPressed: function (mouse) {
            ShellState.markPointerNav();
            if (!isFinite(root.maxValue) || root.maxValue <= 0)
                return;
            let r = ratioFromX(mouse.x);
            root._dragRatio = r;
            if (root.commitOnRelease) {
                root._dragging = true;
            } else {
                root.moved(r * root.maxValue);
            }
        }

        onPositionChanged: function (mouse) {
            if (!pressed || !isFinite(root.maxValue) || root.maxValue <= 0)
                return;
            let r = ratioFromX(mouse.x);
            root._dragRatio = r;
            if (!root.commitOnRelease) {
                root.moved(r * root.maxValue);
            }
        }

        onReleased: function (mouse) {
            if (root.commitOnRelease && root._dragging) {
                let r = ratioFromX(mouse.x);
                root._dragRatio = r;
                root._dragging = false;
                if (isFinite(root.maxValue) && root.maxValue > 0)
                    root.moved(r * root.maxValue);
            }
        }

        onCanceled: {
            root._dragging = false;
        }
    }
}
