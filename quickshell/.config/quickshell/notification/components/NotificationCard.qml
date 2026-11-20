pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets

import "../../libs"
import "../../services"
import "../../theme"
import "../../timers"
import "../../ui"

ClippingRectangle {
    id: root

    required property int entryId
    property int version: 1
    required property string appName
    required property string summary
    required property string body
    required property string appIcon
    required property string image
    property string category: ""
    required property int urgency
    required property double receivedAtMs
    required property bool hasInlineReply
    required property string inlineReplyPlaceholder
    required property bool hasActionIcons

    // "toast" | "center"
    property string mode: "toast"

    signal dismissRequested(int entryId)
    signal openDetailsRequested(int entryId)
    signal hoverChanged(bool hovered)

    // Re-evaluates when version increments on replacement
    readonly property Notification liveNotification: version > 0 ? NotificationStore.getNotification(entryId) : null
    readonly property bool isCritical: urgency === NotificationUrgency.Critical
    readonly property bool isLow: urgency === NotificationUrgency.Low
    readonly property bool hasActions: (liveNotification && liveNotification.actions && liveNotification.actions.length > 0) || false
    readonly property bool hasImage: image.length > 0
    readonly property var catInfo: NotificationStore.categoryMeta(category)
    readonly property bool hasCategory: catInfo.label.length > 0

    property bool replyOpen: false

    activeFocusOnTab: mode === "center"
    implicitHeight: contentCol.implicitHeight + Theme.spaceMd * 2
    radius: Theme.radiusLg
    contentInsideBorder: true
    antialiasing: true

    color: {
        if (isCritical)
            return Qt.rgba(0.20, 0.13, 0.14, 0.96);
        if (mode === "center")
            return (cardHover.containsMouse || root.activeFocus) ? Theme.surfaceElevated : Theme.surfaceRaised;
        return Theme.cardBg;
    }

    border.width: root.activeFocus ? 2 : 1
    border.color: {
        if (root.activeFocus)
            return Theme.accentHover;
        if (isCritical)
            return Theme.dangerBorder;
        if (cardHover.containsMouse)
            return Theme.borderStrong;
        return Theme.borderDefault;
    }

    Behavior on color {
        ColorAnimation {
            duration: Theme.animFast
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: Theme.animFast
        }
    }

    Keys.onPressed: function (event) {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            event.accepted = true;
            root.openDetailsRequested(root.entryId);
        } else if (event.key === Qt.Key_Delete) {
            event.accepted = true;
            root.dismissRequested(root.entryId);
        }
    }

    // Bug 8.2 fix: Inset rounded accent bar clipped cleanly inside ClippingRectangle
    Rectangle {
        visible: root.isCritical
        anchors.left: parent.left
        anchors.leftMargin: 3
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 8
        anchors.bottomMargin: 8
        width: 3
        radius: 2
        color: Theme.danger
        antialiasing: true
    }

    // Hover tracking for pause-on-hover and dismiss button visibility
    MouseArea {
        id: cardHover
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton

        onContainsMouseChanged: {
            root.hoverChanged(containsMouse);
        }
    }

    ColumnLayout {
        id: contentCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Theme.spaceMd
        anchors.leftMargin: root.isCritical ? Theme.spaceMd + 5 : Theme.spaceMd
        spacing: Theme.spaceSm

        // Header: App icon + App name + Timestamp + Category + Urgency badge + Dismiss
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spaceXs

            // App icon
            Rectangle {
                implicitWidth: 20
                implicitHeight: 20
                radius: Theme.radiusXs
                color: Theme.subtleBg

                IconImage {
                    anchors.centerIn: parent
                    implicitSize: 16
                    source: LibIcon.getIconPath(root.appIcon.length > 0 ? root.appIcon : undefined)
                    visible: root.appIcon.length > 0
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.appIcon.length === 0
                    text: root.hasCategory ? root.catInfo.icon : (root.isCritical ? "󰀦" : "󰂚")
                    font.family: Theme.fontIcon
                    font.pixelSize: 12
                    color: root.isCritical ? Theme.dangerHover : Theme.textSecondary
                }
            }

            // App name
            Text {
                text: root.appName
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontXs
                font.weight: Font.Medium
                color: Theme.textSecondary
                elide: Text.ElideRight
                Layout.maximumWidth: 120
            }

            Text {
                text: "·"
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontXs
                color: Theme.textMuted
            }

            // Relative time
            Text {
                text: NotificationStore.formatRelativeTime(root.receivedAtMs, root.mode === "toast" ? Timer1Sec.now : Timer1Min.now)
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontXs
                color: Theme.textMuted
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            // Category chip (independent of urgency)
            Rectangle {
                visible: root.hasCategory
                implicitWidth: catRow.implicitWidth + 10
                implicitHeight: 18
                radius: Theme.radiusPill
                color: Theme.subtleBg
                border.width: 1
                border.color: Theme.borderSubtle

                RowLayout {
                    id: catRow
                    anchors.centerIn: parent
                    spacing: 3

                    Text {
                        text: root.catInfo.icon
                        font.family: Theme.fontIcon
                        font.pixelSize: 10
                        color: Theme.textSecondary
                    }

                    Text {
                        text: root.catInfo.label
                        font.family: Theme.fontSans
                        font.pixelSize: 10
                        color: Theme.textSecondary
                    }
                }
            }

            // Non-color urgency badge (Critical / Low)
            Rectangle {
                visible: root.isCritical || root.isLow
                implicitWidth: urgText.implicitWidth + 10
                implicitHeight: 18
                radius: Theme.radiusPill
                color: root.isCritical ? Theme.dangerSubtle : Theme.subtleBg
                border.width: 1
                border.color: root.isCritical ? Theme.dangerBorder : Theme.borderSubtle

                Text {
                    id: urgText
                    anchors.centerIn: parent
                    text: root.isCritical ? "Critical" : "Low"
                    font.family: Theme.fontSans
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    color: root.isCritical ? Theme.dangerHover : Theme.textMuted
                }
            }

            // Dismiss button (separate from main clickable body)
            IconButton {
                icon: "󰅖"
                iconSize: 12
                buttonSize: 22
                iconColor: Theme.textSecondary
                dangerHover: true
                opacity: (cardHover.containsMouse || root.mode === "center" || root.isCritical || activeFocus) ? 1.0 : 0.45

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.animFast
                    }
                }

                onClicked: root.dismissRequested(root.entryId)
            }
        }

        // Main clickable content area -> Opens Notification Details window
        Item {
            Layout.fillWidth: true
            implicitHeight: mainContentRow.implicitHeight

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.openDetailsRequested(root.entryId)
            }

            RowLayout {
                id: mainContentRow
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: Theme.spaceMd

                ClippingRectangle {
                    visible: root.hasImage
                    Layout.alignment: Qt.AlignTop
                    implicitWidth: 46
                    implicitHeight: 46
                    radius: Theme.radiusMd
                    color: Theme.surfaceElevated

                    Image {
                        anchors.fill: parent
                        source: root.hasImage ? Qt.url(root.image) : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        smooth: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spaceXxs

                    Text {
                        visible: root.summary.length > 0
                        Layout.fillWidth: true
                        text: root.summary
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontMd
                        font.weight: Font.DemiBold
                        color: Theme.textPrimary
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }

                    Text {
                        visible: root.body.length > 0
                        Layout.fillWidth: true
                        text: root.body
                        textFormat: Text.StyledText
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontSm
                        color: Theme.textSecondary
                        linkColor: Theme.accentHover
                        wrapMode: Text.Wrap
                        maximumLineCount: root.mode === "toast" ? 3 : 4
                        elide: Text.ElideRight

                        onLinkActivated: function (link) {
                            Qt.openUrlExternally(link);
                        }
                    }
                }
            }
        }

        // Separate Action Buttons & Inline Reply row
        Flow {
            visible: root.hasActions || root.hasInlineReply
            Layout.fillWidth: true
            Layout.topMargin: Theme.spaceXxs
            spacing: Theme.spaceXs

            Repeater {
                model: root.liveNotification ? root.liveNotification.actions : []

                delegate: Rectangle {
                    id: actBtn
                    required property NotificationAction modelData

                    readonly property bool hovered: actMouse.containsMouse
                    readonly property bool pressed: actMouse.pressed

                    activeFocusOnTab: true
                    implicitWidth: Math.min(actRow.implicitWidth + Theme.spaceMd * 2, root.width - Theme.spaceMd * 2)
                    implicitHeight: 28
                    radius: Theme.radiusSm
                    color: pressed ? Theme.pressedBg : ((hovered || activeFocus) ? Theme.surfaceOverlay : Theme.surfaceElevated)
                    border.width: activeFocus ? 2 : 1
                    border.color: activeFocus ? Theme.accentHover : (hovered ? Theme.borderStrong : Theme.borderSubtle)
                    antialiasing: true

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animFast
                        }
                    }

                    Keys.onPressed: function (event) {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                            event.accepted = true;
                            actBtn.modelData.invoke();
                            if (root.mode === "toast")
                                NotificationStore.dismissToast(root.entryId);
                        }
                    }

                    RowLayout {
                        id: actRow
                        anchors.centerIn: parent
                        spacing: Theme.spaceXs

                        IconImage {
                            visible: root.hasActionIcons && actBtn.modelData.identifier.length > 0
                            implicitSize: 14
                            source: root.hasActionIcons ? LibIcon.getIconPath(actBtn.modelData.identifier) : ""
                        }

                        Text {
                            text: actBtn.modelData.text || actBtn.modelData.identifier
                            font.family: Theme.fontSans
                            font.pixelSize: Theme.fontXs
                            font.weight: Font.Medium
                            color: Theme.textPrimary
                            elide: Text.ElideRight
                            Layout.maximumWidth: 180
                        }
                    }

                    MouseArea {
                        id: actMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            actBtn.modelData.invoke();
                            if (root.mode === "toast")
                                NotificationStore.dismissToast(root.entryId);
                        }
                    }
                }
            }

            ActionButton {
                visible: root.hasInlineReply && !root.replyOpen
                text: "Reply"
                icon: "󰑚"
                compact: true
                variant: "secondary"
                implicitHeight: 28
                onClicked: {
                    root.replyOpen = true;
                    replyInput.focusInput();
                }
            }
        }

        // Inline reply input field
        RowLayout {
            visible: root.hasInlineReply && root.replyOpen
            Layout.fillWidth: true
            Layout.topMargin: Theme.spaceXxs
            spacing: Theme.spaceXs

            TextFieldBox {
                id: replyInput
                Layout.fillWidth: true
                implicitHeight: 32
                placeholderText: root.inlineReplyPlaceholder
                showClearButton: false

                onAccepted: sendReply()
                onEscapePressed: root.replyOpen = false

                function sendReply() {
                    let msg = replyInput.text.trim();
                    if (msg.length === 0 || !root.liveNotification)
                        return;
                    root.liveNotification.sendInlineReply(msg);
                    replyInput.text = "";
                    root.replyOpen = false;
                    if (root.mode === "toast")
                        NotificationStore.dismissToast(root.entryId);
                }
            }

            ActionButton {
                text: "Send"
                compact: true
                variant: "primary"
                implicitHeight: 32
                disabled: replyInput.text.trim().length === 0
                onClicked: replyInput.sendReply()
            }
        }
    }
}
