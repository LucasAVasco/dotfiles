pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell

import "../../services"
import "../../theme"
import "../../ui"

PanelWindow {
    id: root

    readonly property bool isOpen: ShellState.activePopover === "sysmon"

    onIsOpenChanged: {
        if (isOpen)
            monSurface.forceActiveFocus();
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
        id: monSurface
        elevation: "popover"
        radius: Theme.radiusXl
        border.color: Theme.borderDefault

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: Theme.topBarHeight + 8
        anchors.rightMargin: 12

        width: Math.min(380, root.width - 24)
        height: Math.min(monFlick.contentHeight + Theme.spaceLg * 2, root.height - Theme.topBarHeight - 32)

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

        Flickable {
            id: monFlick
            anchors.fill: parent
            anchors.margins: Theme.spaceLg
            contentWidth: width
            contentHeight: monCol.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: monCol
                width: monFlick.width
                spacing: Theme.spaceMd

                Text {
                    text: "System Performance"
                    font.family: Theme.fontSans
                    font.pixelSize: Theme.fontLg
                    font.weight: Font.DemiBold
                    color: Theme.textPrimary
                }

                // =============================================================
                // CPU Section
                // =============================================================
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: cpuBox.implicitHeight + Theme.spaceMd * 2
                    radius: Theme.radiusMd
                    color: Theme.surfaceRaised
                    border.width: 1
                    border.color: Theme.borderSubtle

                    ColumnLayout {
                        id: cpuBox
                        anchors.fill: parent
                        anchors.margins: Theme.spaceMd
                        spacing: Theme.spaceSm

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spaceSm

                            Text {
                                text: "󰍛"
                                font.family: Theme.fontIcon
                                font.pixelSize: 15
                                color: Theme.accentHover
                            }

                            Text {
                                text: "CPU"
                                font.family: Theme.fontSans
                                font.pixelSize: Theme.fontMd
                                font.weight: Font.DemiBold
                                color: Theme.textPrimary
                                Layout.fillWidth: true
                            }

                            // CPU Temperature pill (distinguishes unavailable vs 0°C)
                            Rectangle {
                                implicitWidth: tempLbl.implicitWidth + 10
                                implicitHeight: 20
                                radius: Theme.radiusPill
                                color: SystemMonitorService.cpuTempC >= 80 ? Theme.dangerSubtle : Theme.subtleBg

                                Text {
                                    id: tempLbl
                                    anchors.centerIn: parent
                                    text: SystemMonitorService.cpuTempC >= 0
                                        ? (Math.round(SystemMonitorService.cpuTempC) + "°C")
                                        : "Temp N/A"
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                    color: SystemMonitorService.cpuTempC >= 80 ? Theme.dangerHover : Theme.textSecondary
                                }
                            }

                            Text {
                                text: SystemMonitorService.formatPercent(SystemMonitorService.cpuPercent)
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSm
                                font.weight: Font.DemiBold
                                color: Theme.textPrimary
                            }
                        }

                        UsageBar {
                            Layout.fillWidth: true
                            percent: SystemMonitorService.cpuPercent
                        }

                        // Per-core CPU usage grid
                        GridLayout {
                            visible: SystemMonitorService.perCorePercents.length > 0
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: Theme.spaceMd
                            rowSpacing: 6

                            Repeater {
                                model: SystemMonitorService.perCorePercents

                                delegate: ColumnLayout {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    spacing: 2

                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            text: "Core " + modelData.core
                                            font.family: Theme.fontSans
                                            font.pixelSize: 10
                                            color: Theme.textMuted
                                            Layout.fillWidth: true
                                        }

                                        Text {
                                            text: Math.round(modelData.percent) + "%"
                                            font.family: Theme.fontMono
                                            font.pixelSize: 10
                                            color: Theme.textSecondary
                                        }
                                    }

                                    UsageBar {
                                        Layout.fillWidth: true
                                        barHeight: 4
                                        percent: modelData.percent
                                    }
                                }
                            }
                        }
                    }
                }

                // =============================================================
                // Memory Section
                // =============================================================
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: memBox.implicitHeight + Theme.spaceMd * 2
                    radius: Theme.radiusMd
                    color: Theme.surfaceRaised
                    border.width: 1
                    border.color: Theme.borderSubtle

                    ColumnLayout {
                        id: memBox
                        anchors.fill: parent
                        anchors.margins: Theme.spaceMd
                        spacing: Theme.spaceSm

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spaceSm

                            Text {
                                text: "󰘚"
                                font.family: Theme.fontIcon
                                font.pixelSize: 15
                                color: Theme.accentHover
                            }

                            Text {
                                text: "Memory"
                                font.family: Theme.fontSans
                                font.pixelSize: Theme.fontMd
                                font.weight: Font.DemiBold
                                color: Theme.textPrimary
                                Layout.fillWidth: true
                            }

                            Text {
                                text: SystemMonitorService.formatPercent(SystemMonitorService.memPercent)
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSm
                                font.weight: Font.DemiBold
                                color: Theme.textPrimary
                            }
                        }

                        UsageBar {
                            Layout.fillWidth: true
                            percent: SystemMonitorService.memPercent
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spaceSm

                            Text {
                                text: "Used: " + SystemMonitorService.formatBytes(SystemMonitorService.memUsedBytes)
                                font.family: Theme.fontSans
                                font.pixelSize: Theme.fontXs
                                color: Theme.textSecondary
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "Avail: " + SystemMonitorService.formatBytes(SystemMonitorService.memAvailableBytes)
                                font.family: Theme.fontSans
                                font.pixelSize: Theme.fontXs
                                color: Theme.textMuted
                            }

                            Text {
                                text: "Total: " + SystemMonitorService.formatBytes(SystemMonitorService.memTotalBytes)
                                font.family: Theme.fontSans
                                font.pixelSize: Theme.fontXs
                                color: Theme.textMuted
                            }
                        }
                    }
                }

                // =============================================================
                // Storage Section (Capacity, not I/O)
                // =============================================================
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: diskBox.implicitHeight + Theme.spaceMd * 2
                    radius: Theme.radiusMd
                    color: Theme.surfaceRaised
                    border.width: 1
                    border.color: Theme.borderSubtle

                    ColumnLayout {
                        id: diskBox
                        anchors.fill: parent
                        anchors.margins: Theme.spaceMd
                        spacing: Theme.spaceSm

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spaceSm

                            Text {
                                text: "󰋊"
                                font.family: Theme.fontIcon
                                font.pixelSize: 15
                                color: Theme.accentHover
                            }

                            Text {
                                text: "Storage (" + SystemMonitorService.diskMount + ")"
                                font.family: Theme.fontSans
                                font.pixelSize: Theme.fontMd
                                font.weight: Font.DemiBold
                                color: Theme.textPrimary
                                Layout.fillWidth: true
                            }

                            Text {
                                text: SystemMonitorService.formatPercent(SystemMonitorService.diskPercent)
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSm
                                font.weight: Font.DemiBold
                                color: SystemMonitorService.diskPercent >= 90 ? Theme.warning : Theme.textPrimary
                            }
                        }

                        UsageBar {
                            Layout.fillWidth: true
                            percent: SystemMonitorService.diskPercent
                            warnThreshold: 90
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spaceSm

                            Text {
                                text: "Used: " + SystemMonitorService.formatBytes(SystemMonitorService.diskUsedBytes)
                                font.family: Theme.fontSans
                                font.pixelSize: Theme.fontXs
                                color: Theme.textSecondary
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "Free: " + SystemMonitorService.formatBytes(SystemMonitorService.diskFreeBytes)
                                font.family: Theme.fontSans
                                font.pixelSize: Theme.fontXs
                                color: Theme.textMuted
                            }

                            Text {
                                text: "Total: " + SystemMonitorService.formatBytes(SystemMonitorService.diskTotalBytes)
                                font.family: Theme.fontSans
                                font.pixelSize: Theme.fontXs
                                color: Theme.textMuted
                            }
                        }
                    }
                }
            }
        }
    }

    component UsageBar: Rectangle {
        property real percent: -1
        property int barHeight: 6
        property real warnThreshold: 85

        implicitHeight: barHeight
        radius: barHeight / 2
        color: Theme.surfaceOverlay

        Rectangle {
            visible: parent.percent >= 0
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Math.max(parent.barHeight, parent.width * Math.max(0, Math.min(1, parent.percent / 100.0)))
            radius: parent.barHeight / 2
            color: parent.percent >= parent.warnThreshold ? Theme.warning : Theme.accent

            Behavior on width {
                NumberAnimation {
                    duration: Theme.animFast
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}
