import QtQuick

import "../services"
import "../theme"

Item {
    id: root

    property real value: 0.0
    property real minValue: 0.0
    property real maxValue: 1.0
    property bool muted: false
    property bool disabled: false
    // When true, dragging previews locally and emits moved() once on release (ideal for MPRIS seek / slow scripts)
    property bool commitOnRelease: false
    property bool wheelEnabled: false
    property real wheelStep: 0.0

    signal moved(real newValue)
    signal scrolled(real newValue)
    signal released(real newValue)

    property bool _dragging: false
    property real _dragRatio: 0.0

    readonly property real valueSpan: (isFinite(maxValue) && isFinite(minValue)) ? (maxValue - minValue) : 0.0

    readonly property real validRatio: {
        if (!isFinite(valueSpan) || valueSpan <= 0 || !isFinite(value))
            return 0.0;
        return Math.max(0.0, Math.min(1.0, (value - minValue) / valueSpan));
    }

    readonly property real clampedRatio: _dragging ? _dragRatio : validRatio
    readonly property real displayValue: isFinite(valueSpan) && valueSpan > 0 ? (minValue + clampedRatio * valueSpan) : minValue
    readonly property bool showFocusRing: !disabled && activeFocus && ShellState.keyboardFocusVisible

    activeFocusOnTab: !disabled
    implicitWidth: 180
    implicitHeight: 24
    opacity: disabled ? 0.45 : 1.0

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.animFast
        }
    }

    function valueFromRatio(r) {
        if (!isFinite(valueSpan) || valueSpan <= 0)
            return minValue;
        return minValue + Math.max(0.0, Math.min(1.0, r)) * valueSpan;
    }

    function effectiveStep() {
        if (isFinite(wheelStep) && wheelStep > 0)
            return wheelStep;
        return valueSpan * 0.05;
    }

    Keys.onPressed: function (event) {
        if (root.disabled || !isFinite(root.valueSpan) || root.valueSpan <= 0)
            return;
        let step = root.effectiveStep();
        let cur = isFinite(root.value) ? root.value : root.minValue;
        if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
            ShellState.markKeyboardNav();
        } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Down) {
            ShellState.markKeyboardNav();
            event.accepted = true;
            root.moved(Math.max(root.minValue, cur - step));
        } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Up) {
            ShellState.markKeyboardNav();
            event.accepted = true;
            root.moved(Math.min(root.maxValue, cur + step));
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
            color: (root.muted || root.disabled) ? Theme.textMuted : Theme.accent

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animFast
                }
            }
        }
    }

    Rectangle {
        id: handle
        width: (!root.disabled && (dragArea.containsMouse || dragArea.pressed || root.showFocusRing)) ? 16 : 14
        height: width
        radius: width / 2
        anchors.verticalCenter: parent.verticalCenter
        x: Math.max(0, Math.min(root.width - width, root.width * root.clampedRatio - width / 2))
        color: root.disabled ? Theme.textSecondary : "#ffffff"
        border.width: 2
        border.color: root.showFocusRing ? Theme.accentHover : ((root.muted || root.disabled) ? Theme.textMuted : Theme.accent)
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
        enabled: !root.disabled
        cursorShape: root.disabled ? Qt.ArrowCursor : Qt.PointingHandCursor

        function ratioFromX(mouseX) {
            return Math.max(0.0, Math.min(1.0, mouseX / Math.max(1, root.width)));
        }

        onPressed: function (mouse) {
            ShellState.markPointerNav();
            if (root.disabled || !isFinite(root.valueSpan) || root.valueSpan <= 0)
                return;
            let r = ratioFromX(mouse.x);
            root._dragRatio = r;
            if (root.commitOnRelease) {
                root._dragging = true;
            } else {
                root.moved(root.valueFromRatio(r));
            }
        }

        onPositionChanged: function (mouse) {
            if (!pressed || root.disabled || !isFinite(root.valueSpan) || root.valueSpan <= 0)
                return;
            let r = ratioFromX(mouse.x);
            root._dragRatio = r;
            if (!root.commitOnRelease) {
                root.moved(root.valueFromRatio(r));
            }
        }

        onReleased: function (mouse) {
            if (root.disabled || !isFinite(root.valueSpan) || root.valueSpan <= 0) {
                root._dragging = false;
                return;
            }
            let r = ratioFromX(mouse.x);
            root._dragRatio = r;
            let finalVal = root.valueFromRatio(r);
            if (root.commitOnRelease && root._dragging) {
                root._dragging = false;
                root.moved(finalVal);
            } else {
                root._dragging = false;
            }
            root.released(finalVal);
        }

        onCanceled: {
            root._dragging = false;
        }

        onWheel: function (wheel) {
            if (!root.wheelEnabled || root.disabled || !isFinite(root.valueSpan) || root.valueSpan <= 0)
                return;
            wheel.accepted = true;
            let step = root.effectiveStep();
            let dir = wheel.angleDelta.y > 0 ? 1 : (wheel.angleDelta.y < 0 ? -1 : 0);
            if (dir === 0)
                return;
            let cur = isFinite(root.value) ? root.value : root.minValue;
            let nextVal = Math.max(root.minValue, Math.min(root.maxValue, cur + dir * step));
            root.scrolled(nextVal);
        }
    }
}
