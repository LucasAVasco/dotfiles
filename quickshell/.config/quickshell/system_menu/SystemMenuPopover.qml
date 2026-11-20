pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell

import "../services"
import "../theme"
import "../ui"

PanelWindow {
    id: root

    readonly property bool isOpen: ShellState.activePopover === "systemMenu"

    onIsOpenChanged: {
        if (isOpen) {
            PowerService.refreshScheduled();
            lockRow.forceActiveFocus();
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

    // Click outside to close
    MouseArea {
        anchors.fill: parent
        onClicked: ShellState.closePopovers()
    }

    Surface {
        id: menuSurface
        elevation: "popover"
        radius: Theme.radiusXl
        border.color: Theme.borderDefault

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: Theme.topBarHeight + 8
        anchors.leftMargin: 10

        width: Math.min(308, root.width - 20)
        implicitHeight: Math.min(menuCol.implicitHeight + Theme.spaceLg * 2, root.height - Theme.topBarHeight - 24)
        height: implicitHeight

        opacity: root.isOpen ? 1.0 : 0.0
        transform: Translate {
            y: root.isOpen ? 0 : -10

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

        // Prevent clicks inside menu from closing it
        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            id: menuCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.spaceLg
            spacing: Theme.spaceSm

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spaceSm

                Rectangle {
                    implicitWidth: 32
                    implicitHeight: 32
                    radius: Theme.radiusPill
                    color: Theme.accentSubtle
                    border.width: 1
                    border.color: Theme.accentBorder

                    Text {
                        anchors.centerIn: parent
                        text: "󰀄"
                        font.family: Theme.fontIcon
                        font.pixelSize: 16
                        color: Theme.accentHover
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        text: Quickshell.env("USER") || "System"
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontMd
                        font.weight: Font.DemiBold
                        color: Theme.textPrimary
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "System & Power"
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontXs
                        color: Theme.textMuted
                    }
                }
            }

            // Active Scheduled Power Action Card
            Rectangle {
                visible: PowerService.hasScheduledAction
                Layout.fillWidth: true
                Layout.topMargin: Theme.spaceXs
                implicitHeight: schedBoxCol.implicitHeight + Theme.spaceMd * 2
                radius: Theme.radiusMd
                color: Theme.warningSubtle
                border.width: 1
                border.color: Theme.warningBorder

                ColumnLayout {
                    id: schedBoxCol
                    anchors.fill: parent
                    anchors.margins: Theme.spaceMd
                    spacing: Theme.spaceSm

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spaceSm

                        Text {
                            text: PowerService.scheduledType === "reboot" ? "󰜉" : "󰐥"
                            font.family: Theme.fontIcon
                            font.pixelSize: 16
                            color: Theme.warning
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: "Scheduled " + PowerService.scheduledActionLabel
                                font.family: Theme.fontSans
                                font.pixelSize: Theme.fontSm
                                font.weight: Font.DemiBold
                                color: Theme.warning
                                Layout.fillWidth: true
                            }

                            Text {
                                text: PowerService.formattedScheduleTime
                                font.family: Theme.fontSans
                                font.pixelSize: Theme.fontXs
                                color: Theme.textPrimary
                                Layout.fillWidth: true
                            }

                            Text {
                                visible: PowerService.remainingText.length > 0
                                text: "In " + PowerService.remainingText
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontXs
                                color: Theme.textSecondary
                                Layout.fillWidth: true
                            }
                        }
                    }

                    ActionButton {
                        Layout.fillWidth: true
                        text: "Cancel Scheduled " + PowerService.scheduledActionLabel
                        icon: "󰅖"
                        variant: "warning"
                        compact: true
                        disabled: PowerService.busy
                        onClicked: ShellState.openPowerDialog("cancelSchedule", root.screen)
                    }
                }
            }

            // Inline feedback / error banner
            Rectangle {
                visible: PowerService.lastError.length > 0 || PowerService.lastFeedback.length > 0
                Layout.fillWidth: true
                implicitHeight: feedbackRow.implicitHeight + Theme.spaceSm * 2
                radius: Theme.radiusSm
                color: PowerService.lastError.length > 0 ? Theme.dangerSubtle : Theme.successSubtle
                border.width: 1
                border.color: PowerService.lastError.length > 0 ? Theme.dangerBorder : Qt.rgba(0.20, 0.82, 0.48, 0.4)

                RowLayout {
                    id: feedbackRow
                    anchors.fill: parent
                    anchors.margins: Theme.spaceSm
                    spacing: Theme.spaceSm

                    Text {
                        Layout.fillWidth: true
                        text: PowerService.lastError.length > 0 ? PowerService.lastError : PowerService.lastFeedback
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontXs
                        color: PowerService.lastError.length > 0 ? Theme.dangerHover : Theme.success
                        wrapMode: Text.Wrap
                    }

                    IconButton {
                        icon: "󰅖"
                        iconSize: 11
                        buttonSize: 20
                        iconColor: Theme.textSecondary
                        onClicked: PowerService.clearMessages()
                    }
                }
            }

            Separator {
                Layout.fillWidth: true
                Layout.topMargin: Theme.spaceXs
            }

            // Section: Session
            Text {
                text: "SESSION"
                font.family: Theme.fontSans
                font.pixelSize: 10
                font.weight: Font.DemiBold
                font.letterSpacing: 0.8
                color: Theme.textMuted
                Layout.leftMargin: Theme.spaceSm
                Layout.topMargin: Theme.spaceXxs
            }

            MenuRow {
                id: lockRow
                icon: "󰌾"
                label: "Lock Screen"
                KeyNavigation.down: logoutRow
                onClicked: {
                    ShellState.closePopovers();
                    PowerService.executeImmediate("lock");
                }
            }

            MenuRow {
                id: logoutRow
                icon: "󰍃"
                label: "Log Out…"
                trailingIcon: "󰅂"
                KeyNavigation.up: lockRow
                KeyNavigation.down: suspendRow.visible ? suspendRow : (hibernateRow.visible ? hibernateRow : rebootRow)
                onClicked: ShellState.openPowerDialog("logout", root.screen)
            }

            Separator {
                Layout.fillWidth: true
                Layout.topMargin: Theme.spaceXxs
            }

            // Section: Power
            Text {
                text: "POWER"
                font.family: Theme.fontSans
                font.pixelSize: 10
                font.weight: Font.DemiBold
                font.letterSpacing: 0.8
                color: Theme.textMuted
                Layout.leftMargin: Theme.spaceSm
                Layout.topMargin: Theme.spaceXxs
            }

            MenuRow {
                id: suspendRow
                visible: PowerService.canSuspend
                icon: "󰤄"
                label: "Suspend"
                KeyNavigation.up: logoutRow
                KeyNavigation.down: hibernateRow.visible ? hibernateRow : rebootRow
                onClicked: {
                    ShellState.closePopovers();
                    PowerService.executeImmediate("suspend");
                }
            }

            MenuRow {
                id: hibernateRow
                visible: PowerService.canHibernate
                icon: "󰒲"
                label: "Hibernate"
                KeyNavigation.up: suspendRow.visible ? suspendRow : logoutRow
                KeyNavigation.down: rebootRow
                onClicked: {
                    ShellState.closePopovers();
                    PowerService.executeImmediate("hibernate");
                }
            }

            MenuRow {
                id: rebootRow
                visible: PowerService.canReboot
                icon: "󰜉"
                label: "Restart…"
                subtitle: "Now or schedule"
                trailingIcon: "󰅂"
                KeyNavigation.up: hibernateRow.visible ? hibernateRow : (suspendRow.visible ? suspendRow : logoutRow)
                KeyNavigation.down: powerOffRow
                onClicked: ShellState.openPowerDialog("reboot", root.screen)
            }

            MenuRow {
                id: powerOffRow
                visible: PowerService.canPowerOff
                icon: "󰐥"
                label: "Power Off…"
                subtitle: "Now or schedule"
                trailingIcon: "󰅂"
                destructive: true
                KeyNavigation.up: rebootRow
                onClicked: ShellState.openPowerDialog("poweroff", root.screen)
            }
        }
    }

    // Reusable keyboard-accessible menu item row
    component MenuRow: Rectangle {
        id: rowItem
        required property string icon
        required property string label
        property string subtitle: ""
        property string trailingIcon: ""
        property bool destructive: false

        signal clicked

        readonly property bool hovered: rowMouse.containsMouse
        readonly property bool pressed: rowMouse.pressed

        activeFocusOnTab: visible
        Layout.fillWidth: true
        implicitHeight: subtitle.length > 0 ? 44 : 38
        radius: Theme.radiusMd
        antialiasing: true

        color: {
            if (destructive && pressed)
                return Theme.danger;
            if (destructive && (hovered || activeFocus))
                return Theme.dangerSubtle;
            if (pressed)
                return Theme.pressedBg;
            if (hovered || activeFocus)
                return Theme.hoverBg;
            return "transparent";
        }

        border.width: activeFocus ? 2 : 0
        border.color: destructive ? Theme.dangerHover : Theme.accentHover

        Behavior on color {
            ColorAnimation {
                duration: Theme.animFast
            }
        }

        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                event.accepted = true;
                rowItem.clicked();
            } else if (event.key === Qt.Key_Escape) {
                event.accepted = true;
                ShellState.closePopovers();
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.spaceMd
            anchors.rightMargin: Theme.spaceMd
            spacing: Theme.spaceMd

            Text {
                text: rowItem.icon
                font.family: Theme.fontIcon
                font.pixelSize: 16
                color: (rowItem.destructive && rowItem.hovered) ? Theme.dangerHover : Theme.textSecondary
                Layout.preferredWidth: 20
                horizontalAlignment: Text.AlignHCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    text: rowItem.label
                    font.family: Theme.fontSans
                    font.pixelSize: Theme.fontMd
                    font.weight: Font.Medium
                    color: (rowItem.destructive && rowItem.hovered) ? Theme.dangerHover : Theme.textPrimary
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    visible: rowItem.subtitle.length > 0
                    text: rowItem.subtitle
                    font.family: Theme.fontSans
                    font.pixelSize: Theme.fontXs
                    color: Theme.textMuted
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }

            Text {
                visible: rowItem.trailingIcon.length > 0
                text: rowItem.trailingIcon
                font.family: Theme.fontIcon
                font.pixelSize: 13
                color: Theme.textMuted
            }
        }

        MouseArea {
            id: rowMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: rowItem.clicked()
        }
    }

    // Escape key to close
    Item {
        focus: root.isOpen
        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Escape) {
                event.accepted = true;
                ShellState.closePopovers();
            }
        }
    }
}
