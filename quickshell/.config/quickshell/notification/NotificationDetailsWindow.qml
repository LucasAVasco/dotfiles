pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets

import "../libs"
import "../services"
import "../theme"
import "../ui"

ModalDialog {
    id: root

    readonly property int entryId: ShellState.notificationDetailsEntryId
    readonly property var entry: entryId > 0 ? NotificationStore.getEntryData(entryId) : null
    readonly property Notification liveNotification: entryId > 0 ? NotificationStore.getNotification(entryId) : null
    readonly property bool isCritical: entry ? entry.urgency === NotificationUrgency.Critical : false
    readonly property bool isLow: entry ? entry.urgency === NotificationUrgency.Low : false
    readonly property var catInfo: entry ? NotificationStore.categoryMeta(entry.category) : ({ label: "", icon: "" })

    open: entryId > 0 && entry !== null
    screen: ShellState.resolveScreen(ShellState.activeScreen)
    dialogWidth: 560

    onOpenChanged: {
        if (open) {
            closeBtn.forceActiveFocus();
        }
    }

    onDismissed: ShellState.closeNotificationDetails()

    // Header
    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spaceMd

        Rectangle {
            implicitWidth: 38
            implicitHeight: 38
            radius: Theme.radiusMd
            color: root.isCritical ? Theme.dangerSubtle : Theme.subtleBg
            border.width: 1
            border.color: root.isCritical ? Theme.dangerBorder : Theme.borderSubtle

            IconImage {
                anchors.centerIn: parent
                implicitSize: 24
                visible: root.entry && root.entry.appIcon && root.entry.appIcon.length > 0
                source: (root.entry && root.entry.appIcon) ? LibIcon.getIconPath(root.entry.appIcon) : ""
            }

            Text {
                anchors.centerIn: parent
                visible: !root.entry || !root.entry.appIcon || root.entry.appIcon.length === 0
                text: root.catInfo.icon.length > 0 ? root.catInfo.icon : "󰂚"
                font.family: Theme.fontIcon
                font.pixelSize: 18
                color: root.isCritical ? Theme.dangerHover : Theme.textSecondary
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: root.entry ? root.entry.appName : ""
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontMd
                font.weight: Font.DemiBold
                color: Theme.textPrimary
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: root.entry
                    ? (Qt.formatDateTime(new Date(root.entry.receivedAtMs), "ddd, MMM d · HH:mm:ss")
                       + " (" + NotificationStore.formatRelativeTime(root.entry.receivedAtMs, null) + ")")
                    : ""
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontXs
                color: Theme.textMuted
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        // Category badge
        Rectangle {
            visible: root.catInfo.label.length > 0
            implicitWidth: detCatRow.implicitWidth + 12
            implicitHeight: 22
            radius: Theme.radiusPill
            color: Theme.subtleBg
            border.width: 1
            border.color: Theme.borderSubtle

            RowLayout {
                id: detCatRow
                anchors.centerIn: parent
                spacing: 4

                Text {
                    text: root.catInfo.icon
                    font.family: Theme.fontIcon
                    font.pixelSize: 11
                    color: Theme.textSecondary
                }

                Text {
                    text: root.entry && root.entry.category ? root.entry.category : root.catInfo.label
                    font.family: Theme.fontSans
                    font.pixelSize: Theme.fontXs
                    color: Theme.textSecondary
                }
            }
        }

        // Urgency badge
        Rectangle {
            implicitWidth: detUrgLabel.implicitWidth + 12
            implicitHeight: 22
            radius: Theme.radiusPill
            color: root.isCritical ? Theme.dangerSubtle : Theme.subtleBg
            border.width: 1
            border.color: root.isCritical ? Theme.dangerBorder : Theme.borderSubtle

            Text {
                id: detUrgLabel
                anchors.centerIn: parent
                text: root.isCritical ? "Critical" : (root.isLow ? "Low" : "Normal")
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontXs
                font.weight: Font.DemiBold
                color: root.isCritical ? Theme.dangerHover : (root.isLow ? Theme.textMuted : Theme.textSecondary)
            }
        }
    }

    Separator {
        Layout.fillWidth: true
    }

    // Scrollable title, image, and full body
    Flickable {
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(340, Math.max(100, detailsCol.implicitHeight))
        contentWidth: width
        contentHeight: detailsCol.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: detailsCol
            width: parent.width
            spacing: Theme.spaceMd

            Text {
                visible: root.entry && root.entry.summary.length > 0
                Layout.fillWidth: true
                text: root.entry ? root.entry.summary : ""
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontLg
                font.weight: Font.DemiBold
                color: Theme.textPrimary
                wrapMode: Text.Wrap
            }

            ClippingRectangle {
                visible: root.entry && root.entry.image && root.entry.image.length > 0
                Layout.alignment: Qt.AlignLeft
                implicitWidth: Math.min(260, detailsCol.width)
                implicitHeight: 150
                radius: Theme.radiusMd
                color: Theme.surfaceRaised

                Image {
                    anchors.fill: parent
                    source: (root.entry && root.entry.image) ? Qt.url(root.entry.image) : ""
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    smooth: true
                }
            }

            Text {
                visible: root.entry && root.entry.body.length > 0
                Layout.fillWidth: true
                text: root.entry ? root.entry.body : ""
                textFormat: Text.StyledText
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontMd
                color: Theme.textSecondary
                linkColor: Theme.accentHover
                wrapMode: Text.Wrap
                lineHeight: 1.4

                onLinkActivated: function (link) {
                    Qt.openUrlExternally(link);
                }
            }
        }
    }

    // Notification actions (kept completely separate from opening details)
    Flow {
        visible: (root.liveNotification && root.liveNotification.actions && root.liveNotification.actions.length > 0) || false
        Layout.fillWidth: true
        spacing: Theme.spaceSm

        Repeater {
            model: root.liveNotification ? root.liveNotification.actions : []

            delegate: ActionButton {
                required property NotificationAction modelData
                text: modelData.text || modelData.identifier
                compact: true
                variant: "secondary"
                onClicked: modelData.invoke()
            }
        }
    }

    // Inline reply inside details window if supported
    RowLayout {
        visible: root.entry ? root.entry.hasInlineReply : false
        Layout.fillWidth: true
        spacing: Theme.spaceSm

        TextFieldBox {
            id: detailsReply
            Layout.fillWidth: true
            placeholderText: root.entry ? root.entry.inlineReplyPlaceholder : "Write a reply…"
            onAccepted: sendDetailsReply()

            function sendDetailsReply() {
                let msg = detailsReply.text.trim();
                if (msg.length === 0 || !root.liveNotification)
                    return;
                root.liveNotification.sendInlineReply(msg);
                detailsReply.text = "";
            }
        }

        ActionButton {
            text: "Send"
            variant: "primary"
            disabled: detailsReply.text.trim().length === 0
            onClicked: detailsReply.sendDetailsReply()
        }
    }

    Separator {
        Layout.fillWidth: true
    }

    // Footer: Dismiss & Close (Close is focused by default for safety)
    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spaceSm

        ActionButton {
            text: "Dismiss Notification"
            icon: "󰆴"
            variant: "ghost"
            onClicked: {
                let id = root.entryId;
                ShellState.closeNotificationDetails();
                NotificationStore.dismissNotification(id);
            }
        }

        Item {
            Layout.fillWidth: true
        }

        ActionButton {
            id: closeBtn
            text: "Close"
            variant: "secondary"
            onClicked: ShellState.closeNotificationDetails()
        }
    }
}
