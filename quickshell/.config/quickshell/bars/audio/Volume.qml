import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

import "../../services"
import "../../theme"

Rectangle {
    id: root

    property var barScreen: null

    readonly property bool isOpen: ShellState.activePopover === "audio"
    readonly property var sink: Pipewire.ready ? Pipewire.defaultAudioSink : null
    readonly property var audio: sink ? sink.audio : null
    readonly property bool muted: audio ? audio.muted : false
    readonly property int volumePercent: audio ? Math.round(audio.volume * 100) : 0

    readonly property string volumeIcon: {
        if (!Pipewire.ready || !audio)
            return "󰕾";
        if (muted || volumePercent === 0)
            return "󰖁";
        if (volumePercent < 35)
            return "󰕿";
        if (volumePercent < 70)
            return "󰖀";
        return "󰕾";
    }

    implicitHeight: 26
    implicitWidth: volRow.implicitWidth + Theme.spaceMd * 2
    radius: Theme.radiusPill
    antialiasing: true

    color: {
        if (isOpen)
            return Theme.accentSubtle;
        if (volMouse.pressed)
            return Theme.pressedBg;
        if (volMouse.containsMouse)
            return Theme.hoverBg;
        return "transparent";
    }

    border.width: isOpen ? 1 : 0
    border.color: Theme.accentBorder

    Behavior on color {
        ColorAnimation {
            duration: Theme.animFast
        }
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    RowLayout {
        id: volRow
        anchors.centerIn: parent
        spacing: 5

        Text {
            text: root.volumeIcon
            font.family: Theme.fontIcon
            font.pixelSize: 14
            color: {
                if (root.isOpen)
                    return Theme.accentHover;
                if (root.muted)
                    return Theme.textMuted;
                return Theme.textPrimary;
            }
        }

        Text {
            visible: Pipewire.ready && root.audio !== null
            text: root.muted ? "Muted" : (root.volumePercent + "%")
            font.family: Theme.fontSans
            font.pixelSize: Theme.fontXs
            font.weight: Font.Medium
            color: root.muted ? Theme.textMuted : Theme.textSecondary
        }
    }

    MouseArea {
        id: volMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

        onClicked: function (mouse) {
            if (mouse.button === Qt.RightButton || mouse.button === Qt.MiddleButton) {
                // Immediate mute/unmute without opening the popup
                if (root.audio)
                    root.audio.muted = !root.audio.muted;
            } else {
                ShellState.togglePopover("audio", root.barScreen);
            }
        }

        onWheel: function (wheel) {
            if (!root.audio)
                return;
            let step = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
            root.audio.volume = Math.max(0.0, Math.min(1.0, root.audio.volume + step));
        }
    }
}
