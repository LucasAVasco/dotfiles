pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell

import "../../services"
import "../../theme"
import "../../ui"

PanelWindow {
    id: root

    readonly property bool isOpen: ShellState.activePopover === "display"

    onIsOpenChanged: {
        if (isOpen) {
            DisplayService.refreshAll();
            displaySurface.forceActiveFocus();
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
        id: displaySurface
        elevation: "popover"
        radius: Theme.radiusXl
        border.color: Theme.borderDefault

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: Theme.topBarHeight + 8
        anchors.rightMargin: 12

        width: Math.min(350, root.width - 24)
        height: Math.min(dispCol.implicitHeight + Theme.spaceLg * 2, root.height - Theme.topBarHeight - 32)

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
            id: dispCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.spaceLg
            spacing: Theme.spaceMd

            Text {
                text: "Display"
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontLg
                font.weight: Font.DemiBold
                color: Theme.textPrimary
            }

            // =================================================================
            // Backlight Section
            // =================================================================
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spaceSm

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spaceSm

                    Text {
                        text: "BACKLIGHT"
                        font.family: Theme.fontSans
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        font.letterSpacing: 0.7
                        color: Theme.textMuted
                        Layout.fillWidth: true
                    }

                    Text {
                        text: DisplayService.backlightReading
                            ? "Loading…"
                            : (Math.round(backlightSlider.displayValue) + "%")
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSm
                        font.weight: Font.Medium
                        color: DisplayService.backlightReading ? Theme.textMuted : Theme.accentHover
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spaceSm

                    Text {
                        text: "󰃠"
                        font.family: Theme.fontIcon
                        font.pixelSize: 15
                        color: DisplayService.backlightReading ? Theme.textMuted : Theme.textSecondary
                    }

                    ProgressSlider {
                        id: backlightSlider
                        Layout.fillWidth: true
                        minValue: 0
                        maxValue: 100
                        value: DisplayService.backlightPercent
                        disabled: DisplayService.backlightReading
                        commitOnRelease: false
                        wheelEnabled: true
                        wheelStep: 5
                        onMoved: function (newVal) {
                            DisplayService.setBacklightLive(newVal, false);
                        }
                        onScrolled: function (newVal) {
                            DisplayService.setBacklightLive(newVal, false);
                        }
                        onReleased: function (newVal) {
                            DisplayService.setBacklightLive(newVal, true);
                        }
                    }

                    ActionButton {
                        text: "10%"
                        icon: "󰑐"
                        compact: true
                        variant: "secondary"
                        disabled: DisplayService.backlightReading
                        onClicked: DisplayService.restoreDefaultBacklight()
                    }
                }

                Text {
                    visible: DisplayService.backlightError.length > 0
                    Layout.fillWidth: true
                    text: DisplayService.backlightError
                    font.family: Theme.fontSans
                    font.pixelSize: Theme.fontXs
                    color: Theme.dangerHover
                    wrapMode: Text.Wrap
                }
            }

            Separator {
                Layout.fillWidth: true
            }

            // =================================================================
            // Screen Temperature Filter Section
            // =================================================================
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spaceSm

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spaceSm

                    Text {
                        text: "SCREEN TEMPERATURE"
                        font.family: Theme.fontSans
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        font.letterSpacing: 0.7
                        color: Theme.textMuted
                        Layout.fillWidth: true
                    }

                    SwitchControl {
                        id: tempSwitch
                        checked: DisplayService.temperatureEnabled
                        disabled: DisplayService.temperatureEnabledReading
                        onToggled: function (state) {
                            DisplayService.setTemperatureEnabled(state);
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spaceSm

                    Text {
                        text: "Warmth"
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontSm
                        font.weight: Font.Medium
                        color: DisplayService.temperatureReading ? Theme.textMuted : Theme.textSecondary
                        Layout.fillWidth: true
                    }

                    Text {
                        text: DisplayService.temperatureReading
                            ? "Loading…"
                            : (Math.round(tempSlider.displayValue) + "K")
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSm
                        font.weight: Font.Medium
                        color: DisplayService.temperatureReading
                            ? Theme.textMuted
                            : (DisplayService.temperatureEnabled ? Theme.accentHover : Theme.textSecondary)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spaceSm

                    Text {
                        text: "󰔏"
                        font.family: Theme.fontIcon
                        font.pixelSize: 15
                        color: DisplayService.temperatureReading ? Theme.textMuted : Theme.textSecondary
                    }

                    ProgressSlider {
                        id: tempSlider
                        Layout.fillWidth: true
                        minValue: DisplayService.minTemperatureWarm
                        maxValue: DisplayService.maxTemperatureWarm
                        value: DisplayService.temperatureWarm
                        disabled: DisplayService.temperatureReading
                        muted: !DisplayService.temperatureEnabled
                        commitOnRelease: false
                        wheelEnabled: true
                        wheelStep: 250
                        onMoved: function (newVal) {
                            DisplayService.setTemperatureLive(newVal, false);
                        }
                        onScrolled: function (newVal) {
                            DisplayService.setTemperatureLive(newVal, false);
                        }
                        onReleased: function (newVal) {
                            DisplayService.setTemperatureLive(newVal, true);
                        }
                    }

                    ActionButton {
                        text: "Default"
                        icon: "󰑐"
                        compact: true
                        variant: "secondary"
                        disabled: DisplayService.temperatureReading
                        onClicked: DisplayService.restoreDefaultTemperature()
                    }
                }

                Text {
                    visible: DisplayService.temperatureError.length > 0
                    Layout.fillWidth: true
                    text: DisplayService.temperatureError
                    font.family: Theme.fontSans
                    font.pixelSize: Theme.fontXs
                    color: Theme.dangerHover
                    wrapMode: Text.Wrap
                }
            }
        }
    }
}
