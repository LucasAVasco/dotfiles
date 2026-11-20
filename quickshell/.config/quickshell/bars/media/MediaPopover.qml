pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Widgets

import "../../services"
import "../../theme"
import "../../ui"

PanelWindow {
    id: root

    readonly property MprisPlayer player: MediaService.activePlayer
    readonly property bool isOpen: ShellState.activePopover === "media" && player !== null
    readonly property bool isPlaying: player !== null && player.playbackState === MprisPlaybackState.Playing
    readonly property bool hasProgress: player !== null && (player.positionSupported || player.lengthSupported)
    readonly property bool canSeekSlider: player !== null && player.canSeek && player.positionSupported && MediaService.reportedLength > 0

    onIsOpenChanged: {
        if (isOpen) {
            MediaService.syncNow(false);
            mediaSurface.forceActiveFocus();
        }
    }

    screen: ShellState.resolveScreen(ShellState.activeScreen)
    visible: isOpen
    focusable: true
    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: ShellState.closePopovers()
    }

    Surface {
        id: mediaSurface
        elevation: "popover"
        radius: Theme.radiusXl
        border.color: Theme.borderDefault

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: Theme.topBarHeight + 8
        anchors.rightMargin: 12

        width: Math.min(368, root.width - 24)
        height: Math.min(mediaCol.implicitHeight + Theme.spaceLg * 2, root.height - Theme.topBarHeight - 32)

        opacity: root.isOpen ? 1.0 : 0.0
        transform: Translate {
            y: root.isOpen ? 0 : -8

            Behavior on y {
                NumberAnimation {
                    duration: Theme.animNormal
                    easing.type: Easing.OutCubic
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            anchors.fill: parent
        }

        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
                ShellState.markKeyboardNav();
            } else if (event.key === Qt.Key_Escape) {
                event.accepted = true;
                ShellState.closePopovers();
            }
        }

        ColumnLayout {
            id: mediaCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.spaceLg
            spacing: Theme.spaceMd

            // Multi-player switcher tabs (only when >1 player is active)
            Flow {
                visible: MediaService.players.length > 1
                Layout.fillWidth: true
                spacing: Theme.spaceXs

                Repeater {
                    model: MediaService.players

                    delegate: ActionButton {
                        required property MprisPlayer modelData
                        text: modelData.identity || "Player"
                        icon: modelData.playbackState === MprisPlaybackState.Playing ? "" : ""
                        compact: true
                        variant: (root.player && root.player.dbusName === modelData.dbusName) ? "primary" : "secondary"
                        onClicked: MediaService.selectPlayer(modelData.dbusName)
                    }
                }
            }

            // Artwork + Metadata Row
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spaceMd

                ClippingRectangle {
                    implicitWidth: 72
                    implicitHeight: 72
                    radius: Theme.radiusMd
                    color: Theme.surfaceElevated

                    Image {
                        anchors.fill: parent
                        visible: root.player !== null && root.player.trackArtUrl && String(root.player.trackArtUrl).length > 0
                        source: (root.player && root.player.trackArtUrl) ? root.player.trackArtUrl : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        smooth: true
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: !root.player || !root.player.trackArtUrl || String(root.player.trackArtUrl).length === 0
                        text: "󰝚"
                        font.family: Theme.fontIcon
                        font.pixelSize: 28
                        color: Theme.textMuted
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spaceXs

                        Text {
                            text: root.player ? (root.player.identity || "Media Player") : ""
                            font.family: Theme.fontSans
                            font.pixelSize: Theme.fontXs
                            font.weight: Font.Medium
                            color: Theme.accentHover
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            implicitWidth: stTxt.implicitWidth + 10
                            implicitHeight: 18
                            radius: Theme.radiusPill
                            color: root.isPlaying ? Theme.accentSubtle : Theme.subtleBg

                            Text {
                                id: stTxt
                                anchors.centerIn: parent
                                text: root.player ? MediaService.stateLabel(root.player.playbackState) : ""
                                font.family: Theme.fontSans
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                color: root.isPlaying ? Theme.accentHover : Theme.textMuted
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.player ? (root.player.trackTitle || "Unknown Track") : ""
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontMd
                        font.weight: Font.DemiBold
                        color: Theme.textPrimary
                        elide: Text.ElideRight
                        maximumLineCount: 2
                        wrapMode: Text.Wrap
                    }

                    Text {
                        visible: root.player !== null && (root.player.trackArtist || "").length > 0
                        Layout.fillWidth: true
                        text: root.player ? (root.player.trackArtist || "") : ""
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontSm
                        color: Theme.textSecondary
                        elide: Text.ElideRight
                    }

                    Text {
                        visible: root.player !== null && (root.player.trackAlbum || "").length > 0
                        Layout.fillWidth: true
                        text: root.player ? (root.player.trackAlbum || "") : ""
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontXs
                        color: Theme.textMuted
                        elide: Text.ElideRight
                    }
                }
            }

            // Progress Bar + Position / Duration (remains visible on track changes, seeks, and pause)
            ColumnLayout {
                visible: root.hasProgress
                Layout.fillWidth: true
                spacing: 4

                ProgressSlider {
                    Layout.fillWidth: true
                    value: MediaService.displayPosition
                    maxValue: MediaService.reportedLength
                    commitOnRelease: true
                    muted: !root.canSeekSlider
                    onMoved: function (newPos) {
                        if (root.canSeekSlider)
                            MediaService.seekTo(newPos);
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: MediaService.formatTime(MediaService.displayPosition)
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontXs
                        color: Theme.textMuted
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: MediaService.reportedLength > 0 ? MediaService.formatTime(MediaService.reportedLength) : "--:--"
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontXs
                        color: Theme.textMuted
                    }
                }
            }

            // Transport Controls (consistent FontAwesome media glyphs)
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Theme.spaceSm

                IconButton {
                    icon: ""
                    iconSize: 14
                    buttonSize: 34
                    disabled: !root.player || !root.player.canGoPrevious
                    onClicked: MediaService.previousTrack()
                }

                IconButton {
                    visible: root.player !== null && root.player.canSeek
                    icon: ""
                    iconSize: 13
                    buttonSize: 32
                    onClicked: MediaService.seekBy(-10)
                }

                ActionButton {
                    icon: root.isPlaying ? "" : ""
                    variant: "primary"
                    implicitWidth: 46
                    implicitHeight: 38
                    radius: Theme.radiusPill
                    disabled: !root.player || !root.player.canTogglePlaying
                    onClicked: MediaService.togglePlaying()
                }

                IconButton {
                    visible: root.player !== null && root.player.canSeek
                    icon: ""
                    iconSize: 13
                    buttonSize: 32
                    onClicked: MediaService.seekBy(10)
                }

                IconButton {
                    icon: ""
                    iconSize: 14
                    buttonSize: 34
                    disabled: !root.player || !root.player.canGoNext
                    onClicked: MediaService.nextTrack()
                }
            }

            Separator {
                Layout.fillWidth: true
            }

            // Player Window Actions: Raise & Quit
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spaceSm

                ActionButton {
                    Layout.fillWidth: true
                    text: "Raise Player"
                    icon: "󰏌"
                    compact: true
                    variant: "secondary"
                    disabled: !MediaService.canRaiseActive
                    onClicked: MediaService.raiseActivePlayer()
                }

                ActionButton {
                    Layout.fillWidth: true
                    text: "Quit Player"
                    icon: "󰅖"
                    compact: true
                    variant: "ghost"
                    disabled: !MediaService.canQuitActive
                    onClicked: MediaService.quitActivePlayer()
                }
            }
        }
    }
}
