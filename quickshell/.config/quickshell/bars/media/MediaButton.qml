import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

import "../../services"
import "../../theme"

Rectangle {
    id: root

    property var barScreen: null

    readonly property MprisPlayer player: MediaService.activePlayer
    readonly property bool isOpen: ShellState.activePopover === "media"
    readonly property bool isPlaying: player !== null && player.playbackState === MprisPlaybackState.Playing

    // Hidden completely when no MPRIS media players exist
    visible: MediaService.hasPlayers && player !== null
    implicitHeight: 26
    implicitWidth: Math.min(180, mediaRow.implicitWidth + Theme.spaceMd * 2)
    radius: Theme.radiusPill
    antialiasing: true

    color: {
        if (isOpen)
            return Theme.accentSubtle;
        if (mediaMouse.pressed)
            return Theme.pressedBg;
        if (mediaMouse.containsMouse)
            return Theme.hoverBg;
        return Theme.subtleBg;
    }

    border.width: isOpen ? 1 : 0
    border.color: Theme.accentBorder

    Behavior on color {
        ColorAnimation {
            duration: Theme.animFast
        }
    }

    RowLayout {
        id: mediaRow
        anchors.fill: parent
        anchors.leftMargin: Theme.spaceSm
        anchors.rightMargin: Theme.spaceSm
        spacing: 6

        Text {
            text: root.isPlaying ? "" : ""
            font.family: Theme.fontIcon
            font.pixelSize: 11
            color: root.isPlaying ? Theme.accentHover : Theme.textSecondary
        }

        Text {
            Layout.fillWidth: true
            text: root.player ? (root.player.trackTitle || root.player.identity || "Media") : ""
            font.family: Theme.fontSans
            font.pixelSize: Theme.fontXs
            font.weight: Font.Medium
            color: Theme.textPrimary
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: mediaMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

        onClicked: function (mouse) {
            if (mouse.button === Qt.RightButton || mouse.button === Qt.MiddleButton) {
                if (root.player && root.player.canTogglePlaying)
                    root.player.togglePlaying();
            } else {
                ShellState.togglePopover("media", root.barScreen);
            }
        }
    }
}
