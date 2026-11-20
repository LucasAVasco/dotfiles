pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

import "../services"
import "../theme"
import "../ui"
import "./components"

PanelWindow {
    id: root

    readonly property int toastCount: NotificationStore.toastModel.count
    readonly property int maxPanelHeight: Math.max(200, (screen ? screen.height : 1080) - Theme.topBarHeight - 24)

    property int activeReplies: 0

    visible: toastCount > 0
    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    color: "transparent"
    focusable: activeReplies > 0

    anchors {
        top: true
        right: true
    }

    margins {
        top: Theme.topBarHeight + 10
        right: 12
    }

    implicitWidth: Math.min(380, Math.max(300, (screen ? screen.width : 1920) - 24))
    implicitHeight: Math.min(stackCol.implicitHeight + 8, maxPanelHeight)

    // Scrollable container (mouse-wheel / touchpad) with NO scrollbar displayed
    Flickable {
        id: toastScroll
        anchors.fill: parent
        contentWidth: width
        contentHeight: stackCol.implicitHeight + 4
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height

        ColumnLayout {
            id: stackCol
            width: toastScroll.width
            spacing: Theme.spaceSm

            ToastUrgencyGroup {
                title: "Critical"
                icon: "󰀦"
                accentColor: Theme.dangerHover
                targetUrgency: NotificationUrgency.Critical
                itemCount: NotificationStore.toastCriticalCount
            }

            ToastUrgencyGroup {
                title: "Normal"
                icon: "󰂚"
                accentColor: Theme.accentHover
                targetUrgency: NotificationUrgency.Normal
                itemCount: NotificationStore.toastNormalCount
            }

            ToastUrgencyGroup {
                title: "Low Priority"
                icon: "󰋼"
                accentColor: Theme.textMuted
                targetUrgency: NotificationUrgency.Low
                itemCount: NotificationStore.toastLowCount
            }
        }
    }

    component ToastUrgencyGroup: ColumnLayout {
        id: tGrp
        required property string title
        required property string icon
        required property color accentColor
        required property int targetUrgency
        required property int itemCount

        readonly property bool isCollapsed: NotificationStore.isGroupCollapsed(targetUrgency)

        visible: itemCount > 0
        Layout.fillWidth: true
        spacing: Theme.spaceXs

        // Compact floating urgency header with synchronized collapse/expand + real group dismiss
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 28
            radius: Theme.radiusMd
            color: Theme.popoverBg
            border.width: 1
            border.color: tGrp.targetUrgency === NotificationUrgency.Critical ? Theme.dangerBorder : Theme.borderSubtle

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.spaceXs
                anchors.rightMargin: Theme.spaceXs
                spacing: Theme.spaceXs

                IconButton {
                    icon: tGrp.isCollapsed ? "󰅂" : "󰅀"
                    iconSize: 12
                    buttonSize: 22
                    iconColor: tGrp.accentColor
                    onClicked: NotificationStore.toggleGroupCollapsed(tGrp.targetUrgency)
                }

                Item {
                    Layout.fillWidth: true
                    implicitHeight: toastHeaderRow.implicitHeight

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NotificationStore.toggleGroupCollapsed(tGrp.targetUrgency)
                    }

                    RowLayout {
                        id: toastHeaderRow
                        anchors.fill: parent
                        spacing: Theme.spaceXs

                        Text {
                            text: tGrp.icon
                            font.family: Theme.fontIcon
                            font.pixelSize: 11
                            color: tGrp.accentColor
                        }

                        Text {
                            text: tGrp.title.toUpperCase()
                            font.family: Theme.fontSans
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            font.letterSpacing: 0.7
                            color: tGrp.accentColor
                        }

                        Rectangle {
                            implicitWidth: Math.max(18, tCount.implicitWidth + 8)
                            implicitHeight: 16
                            radius: Theme.radiusPill
                            color: Theme.subtleBg

                            Text {
                                id: tCount
                                anchors.centerIn: parent
                                text: String(tGrp.itemCount)
                                font.family: Theme.fontSans
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                color: Theme.textSecondary
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }
                    }
                }

                ActionButton {
                    text: "Dismiss"
                    compact: true
                    variant: "ghost"
                    implicitHeight: 20
                    onClicked: NotificationStore.dismissGroup(tGrp.targetUrgency)
                }
            }
        }

        ColumnLayout {
            visible: !tGrp.isCollapsed
            Layout.fillWidth: true
            spacing: Theme.spaceXs

            Repeater {
                model: NotificationStore.toastModel

                delegate: Item {
                    id: toastWrapper

                    required property int index
                    required property int entryId
                    required property int version
                    required property string appName
                    required property string summary
                    required property string body
                    required property string appIcon
                    required property string image
                    required property string category
                    required property int urgency
                    required property double receivedAtMs
                    required property bool hasInlineReply
                    required property string inlineReplyPlaceholder
                    required property bool hasActionIcons

                    readonly property bool matchesGroup: urgency === tGrp.targetUrgency

                    visible: matchesGroup
                    Layout.fillWidth: true
                    implicitHeight: matchesGroup ? card.implicitHeight : 0

                    property real enterProgress: 0
                    opacity: enterProgress
                    transform: Translate {
                        x: (1 - toastWrapper.enterProgress) * 24
                    }

                    Component.onCompleted: enterAnim.start()

                    NumberAnimation {
                        id: enterAnim
                        target: toastWrapper
                        property: "enterProgress"
                        from: 0
                        to: 1
                        duration: Theme.animNormal
                        easing.type: Easing.OutCubic
                    }

                    NotificationCard {
                        id: card
                        visible: toastWrapper.matchesGroup
                        anchors.left: parent.left
                        anchors.right: parent.right
                        mode: "toast"

                        entryId: toastWrapper.entryId
                        version: toastWrapper.version
                        appName: toastWrapper.appName
                        summary: toastWrapper.summary
                        body: toastWrapper.body
                        appIcon: toastWrapper.appIcon
                        image: toastWrapper.image
                        category: toastWrapper.category
                        urgency: toastWrapper.urgency
                        receivedAtMs: toastWrapper.receivedAtMs
                        hasInlineReply: toastWrapper.hasInlineReply
                        inlineReplyPlaceholder: toastWrapper.inlineReplyPlaceholder
                        hasActionIcons: toastWrapper.hasActionIcons

                        onDismissRequested: function (id) {
                            NotificationStore.dismissNotification(id);
                        }

                        onOpenDetailsRequested: function (id) {
                            ShellState.openNotificationDetails(id, root.screen);
                        }

                        onHoverChanged: function (hovered) {
                            NotificationStore.pauseToast(toastWrapper.entryId, hovered);
                        }

                        onReplyOpenChanged: {
                            root.activeReplies = Math.max(0, root.activeReplies + (card.replyOpen ? 1 : -1));
                        }
                    }
                }
            }
        }
    }
}
