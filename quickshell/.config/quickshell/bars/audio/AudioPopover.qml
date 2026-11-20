pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

import "../../services"
import "../../theme"
import "../../ui"

PanelWindow {
    id: root

    readonly property bool isOpen: ShellState.activePopover === "audio"

    // Filter PipeWire nodes cleanly into outputs, inputs, and app streams
    readonly property var allAudioNodes: {
        if (!Pipewire.ready || !Pipewire.nodes)
            return [];
        return [...Pipewire.nodes.values].filter(n => n && n.audio !== null);
    }

    readonly property var outputDevices: allAudioNodes.filter(n => !n.isStream && n.isSink)
    readonly property var inputDevices: allAudioNodes.filter(n => {
        if (n.isStream || n.isSink)
            return false;
        let nm = (n.name || "").toLowerCase();
        return !nm.includes(".monitor");
    })
    readonly property var appStreams: allAudioNodes.filter(n => n.isStream)

    readonly property var defaultSink: Pipewire.ready ? Pipewire.defaultAudioSink : null
    readonly property var defaultSource: Pipewire.ready ? Pipewire.defaultAudioSource : null
    readonly property var sinkAudio: defaultSink ? defaultSink.audio : null
    readonly property var sourceAudio: defaultSource ? defaultSource.audio : null

    onIsOpenChanged: {
        if (isOpen) {
            outputSlider.forceActiveFocus();
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

    PwObjectTracker {
        objects: root.allAudioNodes
    }

    MouseArea {
        anchors.fill: parent
        onClicked: ShellState.closePopovers()
    }

    Surface {
        elevation: "popover"
        radius: Theme.radiusXl
        border.color: Theme.borderDefault

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: Theme.topBarHeight + 8
        anchors.rightMargin: 12

        width: Math.min(360, root.width - 24)
        height: Math.min(audioFlick.contentHeight + Theme.spaceLg * 2, root.height - Theme.topBarHeight - 32)

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
            if (event.key === Qt.Key_Escape) {
                event.accepted = true;
                ShellState.closePopovers();
            }
        }

        Flickable {
            id: audioFlick
            anchors.fill: parent
            anchors.margins: Theme.spaceLg
            contentWidth: width
            contentHeight: audioCol.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: audioCol
                width: audioFlick.width
                spacing: Theme.spaceMd

                // =============================================================
                // Output (Master Volume & Device Switcher)
                // =============================================================
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spaceSm

                    Text {
                        text: "Output"
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontLg
                        font.weight: Font.DemiBold
                        color: Theme.textPrimary
                        Layout.fillWidth: true
                    }

                    Text {
                        text: (root.sinkAudio && root.sinkAudio.muted)
                            ? "Muted"
                            : (Math.round((root.sinkAudio ? root.sinkAudio.volume : 0) * 100) + "%")
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSm
                        font.weight: Font.Medium
                        color: (root.sinkAudio && root.sinkAudio.muted) ? Theme.textMuted : Theme.accentHover
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spaceSm

                    IconButton {
                        icon: (root.sinkAudio && root.sinkAudio.muted) ? "󰖁" : "󰕾"
                        iconSize: 16
                        buttonSize: 32
                        active: root.sinkAudio !== null && !root.sinkAudio.muted
                        onClicked: {
                            if (root.sinkAudio)
                                root.sinkAudio.muted = !root.sinkAudio.muted;
                        }
                    }

                    ProgressSlider {
                        id: outputSlider
                        Layout.fillWidth: true
                        value: root.sinkAudio ? root.sinkAudio.volume : 0
                        maxValue: 1.0
                        muted: root.sinkAudio ? root.sinkAudio.muted : false
                        onMoved: function (newVal) {
                            if (root.sinkAudio) {
                                root.sinkAudio.volume = newVal;
                                if (root.sinkAudio.muted && newVal > 0)
                                    root.sinkAudio.muted = false;
                            }
                        }
                    }
                }

                // Output device list
                ColumnLayout {
                    visible: root.outputDevices.length > 0
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: "OUTPUT DEVICES"
                        font.family: Theme.fontSans
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        font.letterSpacing: 0.7
                        color: Theme.textMuted
                        Layout.leftMargin: 4
                    }

                    Repeater {
                        model: root.outputDevices

                        delegate: DeviceRow {
                            required property PwNode modelData
                            label: modelData.description || modelData.nickname || modelData.name || "Output"
                            icon: "󰓃"
                            selected: root.defaultSink !== null && root.defaultSink.id === modelData.id
                            onClicked: Pipewire.preferredDefaultAudioSink = modelData
                        }
                    }
                }

                // =============================================================
                // Input (Microphone Volume & Device Switcher)
                // =============================================================
                Separator {
                    visible: root.inputDevices.length > 0 || root.sourceAudio !== null
                    Layout.fillWidth: true
                }

                ColumnLayout {
                    visible: root.inputDevices.length > 0 || root.sourceAudio !== null
                    Layout.fillWidth: true
                    spacing: Theme.spaceSm

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spaceSm

                        Text {
                            text: "Input"
                            font.family: Theme.fontSans
                            font.pixelSize: Theme.fontMd
                            font.weight: Font.DemiBold
                            color: Theme.textPrimary
                            Layout.fillWidth: true
                        }

                        Text {
                            text: (root.sourceAudio && root.sourceAudio.muted)
                                ? "Muted"
                                : (Math.round((root.sourceAudio ? root.sourceAudio.volume : 0) * 100) + "%")
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontXs
                            font.weight: Font.Medium
                            color: (root.sourceAudio && root.sourceAudio.muted) ? Theme.textMuted : Theme.textSecondary
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spaceSm

                        IconButton {
                            icon: (root.sourceAudio && root.sourceAudio.muted) ? "󰍭" : "󰍬"
                            iconSize: 15
                            buttonSize: 30
                            active: root.sourceAudio !== null && !root.sourceAudio.muted
                            onClicked: {
                                if (root.sourceAudio)
                                    root.sourceAudio.muted = !root.sourceAudio.muted;
                            }
                        }

                        ProgressSlider {
                            Layout.fillWidth: true
                            value: root.sourceAudio ? root.sourceAudio.volume : 0
                            maxValue: 1.0
                            muted: root.sourceAudio ? root.sourceAudio.muted : false
                            onMoved: function (newVal) {
                                if (root.sourceAudio) {
                                    root.sourceAudio.volume = newVal;
                                    if (root.sourceAudio.muted && newVal > 0)
                                        root.sourceAudio.muted = false;
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        visible: root.inputDevices.length > 0
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: "INPUT DEVICES"
                            font.family: Theme.fontSans
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            font.letterSpacing: 0.7
                            color: Theme.textMuted
                            Layout.leftMargin: 4
                        }

                        Repeater {
                            model: root.inputDevices

                            delegate: DeviceRow {
                                required property PwNode modelData
                                label: modelData.description || modelData.nickname || modelData.name || "Input"
                                icon: "󰍬"
                                selected: root.defaultSource !== null && root.defaultSource.id === modelData.id
                                onClicked: Pipewire.preferredDefaultAudioSource = modelData
                            }
                        }
                    }
                }

                // =============================================================
                // Application Streams
                // =============================================================
                Separator {
                    visible: root.appStreams.length > 0
                    Layout.fillWidth: true
                }

                ColumnLayout {
                    visible: root.appStreams.length > 0
                    Layout.fillWidth: true
                    spacing: Theme.spaceSm

                    Text {
                        text: "APPLICATIONS"
                        font.family: Theme.fontSans
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        font.letterSpacing: 0.7
                        color: Theme.textMuted
                        Layout.leftMargin: 4
                    }

                    Repeater {
                        model: root.appStreams

                        delegate: ColumnLayout {
                            id: streamRow
                            required property PwNode modelData
                            readonly property var stAudio: modelData.audio
                            readonly property string appLabel: {
                                if (modelData.properties && modelData.properties["application.name"])
                                    return String(modelData.properties["application.name"]);
                                return modelData.nickname || modelData.description || modelData.name || "Application";
                            }

                            Layout.fillWidth: true
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Theme.spaceXs

                                Text {
                                    text: streamRow.appLabel
                                    font.family: Theme.fontSans
                                    font.pixelSize: Theme.fontSm
                                    font.weight: Font.Medium
                                    color: Theme.textPrimary
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: (streamRow.stAudio && streamRow.stAudio.muted)
                                        ? "Muted"
                                        : (Math.round((streamRow.stAudio ? streamRow.stAudio.volume : 0) * 100) + "%")
                                    font.family: Theme.fontMono
                                    font.pixelSize: Theme.fontXs
                                    color: Theme.textMuted
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Theme.spaceSm

                                IconButton {
                                    icon: (streamRow.stAudio && streamRow.stAudio.muted) ? "󰖁" : "󰕾"
                                    iconSize: 14
                                    buttonSize: 26
                                    onClicked: {
                                        if (streamRow.stAudio)
                                            streamRow.stAudio.muted = !streamRow.stAudio.muted;
                                    }
                                }

                                ProgressSlider {
                                    Layout.fillWidth: true
                                    value: streamRow.stAudio ? streamRow.stAudio.volume : 0
                                    maxValue: 1.0
                                    muted: streamRow.stAudio ? streamRow.stAudio.muted : false
                                    onMoved: function (newVal) {
                                        if (streamRow.stAudio) {
                                            streamRow.stAudio.volume = newVal;
                                            if (streamRow.stAudio.muted && newVal > 0)
                                                streamRow.stAudio.muted = false;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    component DeviceRow: Rectangle {
        id: devRow
        required property string label
        required property string icon
        property bool selected: false
        signal clicked

        activeFocusOnTab: true
        Layout.fillWidth: true
        implicitHeight: 34
        radius: Theme.radiusMd
        antialiasing: true

        color: {
            if (devMouse.pressed)
                return Theme.pressedBg;
            if (selected)
                return Theme.accentSubtle;
            if (devMouse.containsMouse || activeFocus)
                return Theme.hoverBg;
            return "transparent";
        }

        border.width: activeFocus ? 2 : (selected ? 1 : 0)
        border.color: activeFocus ? Theme.accentHover : Theme.accentBorder

        Behavior on color {
            ColorAnimation {
                duration: Theme.animFast
            }
        }

        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                event.accepted = true;
                devRow.clicked();
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.spaceSm
            anchors.rightMargin: Theme.spaceSm
            spacing: Theme.spaceSm

            Text {
                text: devRow.icon
                font.family: Theme.fontIcon
                font.pixelSize: 13
                color: devRow.selected ? Theme.accentHover : Theme.textSecondary
            }

            Text {
                text: devRow.label
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontSm
                font.weight: devRow.selected ? Font.DemiBold : Font.Normal
                color: Theme.textPrimary
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                visible: devRow.selected
                text: "󰄬"
                font.family: Theme.fontIcon
                font.pixelSize: 13
                color: Theme.accentHover
            }
        }

        MouseArea {
            id: devMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: devRow.clicked()
        }
    }
}
