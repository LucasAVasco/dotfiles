pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

import "../services"
import "../theme"
import "../ui"
import "../weather"
import "./components"

PanelWindow {
    id: root

    readonly property bool isOpen: ShellState.activePopover === "notificationCenter"

    property date today: new Date()
    property int viewYear: today.getFullYear()
    property int viewMonth: today.getMonth()

    onIsOpenChanged: {
        if (isOpen) {
            today = new Date();
            viewYear = today.getFullYear();
            viewMonth = today.getMonth();
            NotificationStore.markAllRead();
            PowerService.refreshScheduled();
            ScreenLockerService.refresh();
            panel.forceActiveFocus();
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

    function prevMonth() {
        if (viewMonth === 0) {
            viewMonth = 11;
            viewYear -= 1;
        } else {
            viewMonth -= 1;
        }
    }

    function nextMonth() {
        if (viewMonth === 11) {
            viewMonth = 0;
            viewYear += 1;
        } else {
            viewMonth += 1;
        }
    }

    function jumpToToday() {
        today = new Date();
        viewYear = today.getFullYear();
        viewMonth = today.getMonth();
    }

    readonly property var calendarCells: {
        let firstDay = new Date(viewYear, viewMonth, 1);
        let startWeekday = firstDay.getDay();
        let daysInMonth = new Date(viewYear, viewMonth + 1, 0).getDate();
        let daysInPrev = new Date(viewYear, viewMonth, 0).getDate();
        let cells = [];

        for (let i = startWeekday - 1; i >= 0; i--) {
            cells.push({ day: daysInPrev - i, inMonth: false, isToday: false });
        }
        for (let d = 1; d <= daysInMonth; d++) {
            let isT = (d === today.getDate() && viewMonth === today.getMonth() && viewYear === today.getFullYear());
            cells.push({ day: d, inMonth: true, isToday: isT });
        }
        let nextDay = 1;
        while (cells.length < 42) {
            cells.push({ day: nextDay++, inMonth: false, isToday: false });
        }
        return cells;
    }

    readonly property bool compactLayout: root.width < 780

    MouseArea {
        anchors.fill: parent
        onClicked: ShellState.closePopovers()
    }

    Surface {
        id: panel
        elevation: "popover"
        radius: Theme.radiusXl
        border.color: Theme.borderDefault

        anchors.top: parent.top
        anchors.topMargin: Theme.topBarHeight + 8
        anchors.horizontalCenter: parent.horizontalCenter

        width: Math.min(root.compactLayout ? 430 : 750, root.width - Theme.spaceLg * 2)
        height: Math.min(620, root.height - Theme.topBarHeight - Theme.spaceXl * 2)

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

        RowLayout {
            anchors.fill: parent
            anchors.margins: Theme.spaceLg
            spacing: Theme.spaceLg

            // =================================================================
            // Left Column: Urgency-Grouped Notifications
            // =================================================================
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Theme.spaceMd

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spaceSm

                    Text {
                        text: "Notifications"
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontLg
                        font.weight: Font.DemiBold
                        color: Theme.textPrimary
                    }

                    Rectangle {
                        visible: NotificationStore.historyModel.count > 0
                        implicitWidth: Math.max(22, countLabel.implicitWidth + 10)
                        implicitHeight: 20
                        radius: Theme.radiusPill
                        color: Theme.accentSubtle

                        Text {
                            id: countLabel
                            anchors.centerIn: parent
                            text: String(NotificationStore.historyModel.count)
                            font.family: Theme.fontSans
                            font.pixelSize: Theme.fontXs
                            font.weight: Font.DemiBold
                            color: Theme.accentHover
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    ActionButton {
                        text: "Clear All"
                        compact: true
                        variant: "ghost"
                        disabled: NotificationStore.historyModel.count === 0
                        onClicked: NotificationStore.clearAll()
                    }
                }

                // Scrollable grouped notifications or Empty State
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    // Empty state
                    ColumnLayout {
                        visible: NotificationStore.historyModel.count === 0
                        anchors.centerIn: parent
                        spacing: Theme.spaceSm

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: NotificationStore.doNotDisturb ? "󰂛" : "󰂚"
                            font.family: Theme.fontIcon
                            font.pixelSize: 40
                            color: Theme.textMuted
                            opacity: 0.65
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "No Notifications"
                            font.family: Theme.fontSans
                            font.pixelSize: Theme.fontLg
                            font.weight: Font.Medium
                            color: Theme.textSecondary
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: NotificationStore.doNotDisturb
                                ? "Do Not Disturb is enabled"
                                : "You're all caught up"
                            font.family: Theme.fontSans
                            font.pixelSize: Theme.fontSm
                            color: Theme.textMuted
                        }
                    }

                    // Urgency-grouped list with visible GNOME-style vertical scrollbar
                    Flickable {
                        id: notifScroll
                        visible: NotificationStore.historyModel.count > 0
                        anchors.fill: parent
                        contentWidth: width
                        contentHeight: groupsCol.implicitHeight
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        readonly property bool needsScroll: contentHeight > height + 1

                        ScrollBar.vertical: ScrollBar {
                            id: notifScrollBar
                            parent: notifScroll
                            anchors.top: notifScroll.top
                            anchors.bottom: notifScroll.bottom
                            anchors.right: notifScroll.right
                            width: 8
                            policy: notifScroll.needsScroll ? ScrollBar.AlwaysOn : ScrollBar.AsNeeded
                            hoverEnabled: true

                            contentItem: Rectangle {
                                implicitWidth: 6
                                implicitHeight: 36
                                radius: 3
                                color: notifScrollBar.pressed
                                    ? Theme.accentHover
                                    : (notifScrollBar.hovered ? Theme.borderStrong : Theme.borderDefault)
                                opacity: notifScroll.needsScroll ? 1.0 : 0.0

                                Behavior on color {
                                    ColorAnimation { duration: Theme.animFast }
                                }
                            }

                            background: Rectangle {
                                implicitWidth: 6
                                radius: 3
                                color: Theme.subtleBg
                                opacity: notifScroll.needsScroll ? 0.6 : 0.0
                            }
                        }

                        ColumnLayout {
                            id: groupsCol
                            width: notifScroll.width - (notifScroll.needsScroll ? 14 : 0)
                            spacing: Theme.spaceMd

                            UrgencyGroup {
                                title: "Critical"
                                icon: "󰀦"
                                accentColor: Theme.dangerHover
                                targetUrgency: NotificationUrgency.Critical
                                itemCount: NotificationStore.criticalCount
                            }

                            UrgencyGroup {
                                title: "Normal"
                                icon: "󰂚"
                                accentColor: Theme.accentHover
                                targetUrgency: NotificationUrgency.Normal
                                itemCount: NotificationStore.normalCount
                            }

                            UrgencyGroup {
                                title: "Low Priority"
                                icon: "󰋼"
                                accentColor: Theme.textMuted
                                targetUrgency: NotificationUrgency.Low
                                itemCount: NotificationStore.lowCount
                            }
                        }
                    }
                }

                Separator {
                    Layout.fillWidth: true
                }

                // Footer: Do Not Disturb + Auto Screen Lock (shared FooterToggleRow for exact alignment)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spaceSm

                    FooterToggleRow {
                        icon: NotificationStore.doNotDisturb ? "󰂛" : "󰂚"
                        iconColor: NotificationStore.doNotDisturb ? Theme.accentHover : Theme.textSecondary
                        label: "Do Not Disturb"
                        checked: NotificationStore.doNotDisturb
                        onToggled: function (state) {
                            NotificationStore.doNotDisturb = state;
                        }
                    }

                    FooterToggleRow {
                        icon: ScreenLockerService.enabled ? "󰌾" : "󰌿"
                        iconColor: {
                            if (!ScreenLockerService.available)
                                return Theme.dangerHover;
                            return ScreenLockerService.enabled ? Theme.accentHover : Theme.textMuted;
                        }
                        label: "Auto Screen Lock"
                        errorText: (!ScreenLockerService.available || ScreenLockerService.lastError.length > 0)
                            ? (ScreenLockerService.lastError.length > 0 ? ScreenLockerService.lastError : "Screen locker unavailable")
                            : ""
                        checked: ScreenLockerService.enabled
                        disabled: ScreenLockerService.busy || !ScreenLockerService.available
                        onToggled: function () {
                            ScreenLockerService.setEnabled(!ScreenLockerService.enabled);
                        }
                    }
                }
            }

            Separator {
                visible: !root.compactLayout
                vertical: true
                Layout.fillHeight: true
            }

            // =================================================================
            // Right Column: Calendar + Compact Weather Summary
            // =================================================================
            ColumnLayout {
                visible: !root.compactLayout
                Layout.preferredWidth: 276
                Layout.fillHeight: true
                spacing: Theme.spaceSm

                // Date header
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        text: Qt.formatDate(root.today, "dddd")
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontSm
                        font.weight: Font.Medium
                        color: Theme.textSecondary
                    }

                    Text {
                        text: Qt.formatDate(root.today, "MMMM d, yyyy")
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontXl
                        font.weight: Font.DemiBold
                        color: Theme.textPrimary
                    }
                }

                // Month navigation bar
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spaceXs

                    IconButton {
                        icon: "󰅁"
                        iconSize: 15
                        buttonSize: 26
                        onClicked: root.prevMonth()
                    }

                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: Qt.formatDate(new Date(root.viewYear, root.viewMonth, 1), "MMMM yyyy")
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontSm
                        font.weight: Font.DemiBold
                        color: Theme.textPrimary

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.jumpToToday()
                        }
                    }

                    IconButton {
                        icon: "󰅂"
                        iconSize: 15
                        buttonSize: 26
                        onClicked: root.nextMonth()
                    }
                }

                // Weekday labels
                GridLayout {
                    Layout.fillWidth: true
                    columns: 7
                    rowSpacing: 2
                    columnSpacing: 2

                    Repeater {
                        model: ["S", "M", "T", "W", "T", "F", "S"]

                        Text {
                            required property string modelData
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            text: modelData
                            font.family: Theme.fontSans
                            font.pixelSize: Theme.fontXs
                            font.weight: Font.DemiBold
                            color: Theme.textMuted
                        }
                    }
                }

                // Calendar grid
                GridLayout {
                    Layout.fillWidth: true
                    columns: 7
                    rowSpacing: 2
                    columnSpacing: 2

                    Repeater {
                        model: root.calendarCells

                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 28
                            radius: Theme.radiusPill
                            color: modelData.isToday ? Theme.accent : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: String(modelData.day)
                                font.family: Theme.fontSans
                                font.pixelSize: Theme.fontSm
                                font.weight: modelData.isToday ? Font.Bold : Font.Normal
                                color: {
                                    if (modelData.isToday)
                                        return Theme.textOnAccent;
                                    if (modelData.inMonth)
                                        return Theme.textPrimary;
                                    return Theme.textMuted;
                                }
                                opacity: modelData.inMonth || modelData.isToday ? 1.0 : 0.45
                            }
                        }
                    }
                }

                Separator {
                    Layout.fillWidth: true
                    Layout.topMargin: Theme.spaceXs
                }

                // Compact Weather Summary below Calendar
                WeatherSummary {
                    Layout.fillWidth: true
                    barScreen: root.screen
                }

                Item {
                    Layout.fillHeight: true
                }

                // Scheduled power action indicator (if active)
                Rectangle {
                    visible: PowerService.hasScheduledAction
                    Layout.fillWidth: true
                    implicitHeight: schedCol.implicitHeight + Theme.spaceSm * 2
                    radius: Theme.radiusMd
                    color: Theme.warningSubtle
                    border.width: 1
                    border.color: Theme.warningBorder

                    ColumnLayout {
                        id: schedCol
                        anchors.fill: parent
                        anchors.margins: Theme.spaceSm
                        spacing: 2

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spaceXs

                            Text {
                                text: PowerService.scheduledType === "reboot" ? "󰜉" : "󰐥"
                                font.family: Theme.fontIcon
                                font.pixelSize: 13
                                color: Theme.warning
                            }

                            Text {
                                text: "Scheduled " + PowerService.scheduledActionLabel
                                font.family: Theme.fontSans
                                font.pixelSize: Theme.fontXs
                                font.weight: Font.DemiBold
                                color: Theme.warning
                                Layout.fillWidth: true
                            }
                        }

                        Text {
                            text: PowerService.formattedScheduleTime + " (" + PowerService.remainingText + ")"
                            font.family: Theme.fontSans
                            font.pixelSize: Theme.fontXs
                            color: Theme.textPrimary
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ShellState.openPopover("systemMenu", root.screen)
                    }
                }
            }
        }
    }

    // Shared footer toggle row guaranteeing exact vertical alignment across all sizes
    component FooterToggleRow: RowLayout {
        id: fRow
        required property string icon
        required property color iconColor
        required property string label
        property string errorText: ""
        property bool checked: false
        property bool disabled: false

        signal toggled(bool state)

        Layout.fillWidth: true
        spacing: Theme.spaceSm

        Text {
            text: fRow.icon
            font.family: Theme.fontIcon
            font.pixelSize: 15
            color: fRow.iconColor
            Layout.preferredWidth: 20
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            Text {
                text: fRow.label
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontSm
                font.weight: Font.Medium
                color: Theme.textPrimary
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                visible: fRow.errorText.length > 0
                text: fRow.errorText
                font.family: Theme.fontSans
                font.pixelSize: 10
                color: Theme.dangerHover
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        SwitchControl {
            Layout.preferredWidth: 42
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            checked: fRow.checked
            disabled: fRow.disabled
            onToggled: function (state) {
                fRow.toggled(state);
            }
        }
    }

    // Reusable Urgency Section component (collapsible, synchronized with Toast Area)
    component UrgencyGroup: ColumnLayout {
        id: grp
        required property string title
        required property string icon
        required property color accentColor
        required property int targetUrgency
        required property int itemCount

        readonly property bool isCollapsed: NotificationStore.isGroupCollapsed(targetUrgency)

        visible: itemCount > 0
        Layout.fillWidth: true
        spacing: Theme.spaceSm

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spaceXs

            IconButton {
                icon: grp.isCollapsed ? "󰅂" : "󰅀"
                iconSize: 12
                buttonSize: 22
                iconColor: grp.accentColor
                onClicked: NotificationStore.toggleGroupCollapsed(grp.targetUrgency)
            }

            Item {
                Layout.fillWidth: true
                implicitHeight: headerLblRow.implicitHeight

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NotificationStore.toggleGroupCollapsed(grp.targetUrgency)
                }

                RowLayout {
                    id: headerLblRow
                    anchors.fill: parent
                    spacing: Theme.spaceXs

                    Text {
                        text: grp.icon
                        font.family: Theme.fontIcon
                        font.pixelSize: 12
                        color: grp.accentColor
                    }

                    Text {
                        text: grp.title.toUpperCase()
                        font.family: Theme.fontSans
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        font.letterSpacing: 0.7
                        color: grp.accentColor
                    }

                    Rectangle {
                        implicitWidth: Math.max(18, grpCount.implicitWidth + 8)
                        implicitHeight: 16
                        radius: Theme.radiusPill
                        color: Theme.subtleBg

                        Text {
                            id: grpCount
                            anchors.centerIn: parent
                            text: String(grp.itemCount)
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
                implicitHeight: 22
                onClicked: NotificationStore.dismissGroup(grp.targetUrgency)
            }
        }

        ColumnLayout {
            visible: !grp.isCollapsed
            Layout.fillWidth: true
            spacing: Theme.spaceSm

            Repeater {
                model: NotificationStore.historyModel

                delegate: Item {
                    id: rowWrap
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

                    readonly property bool matchesGroup: urgency === grp.targetUrgency

                    visible: matchesGroup
                    Layout.fillWidth: true
                    implicitHeight: matchesGroup ? cardItem.implicitHeight : 0

                    NotificationCard {
                        id: cardItem
                        visible: rowWrap.matchesGroup
                        anchors.left: parent.left
                        anchors.right: parent.right
                        mode: "center"

                        entryId: rowWrap.entryId
                        version: rowWrap.version
                        appName: rowWrap.appName
                        summary: rowWrap.summary
                        body: rowWrap.body
                        appIcon: rowWrap.appIcon
                        image: rowWrap.image
                        category: rowWrap.category
                        urgency: rowWrap.urgency
                        receivedAtMs: rowWrap.receivedAtMs
                        hasInlineReply: rowWrap.hasInlineReply
                        inlineReplyPlaceholder: rowWrap.inlineReplyPlaceholder
                        hasActionIcons: rowWrap.hasActionIcons

                        onDismissRequested: function (id) {
                            NotificationStore.dismissNotification(id);
                        }

                        onOpenDetailsRequested: function (id) {
                            ShellState.openNotificationDetails(id, root.screen);
                        }
                    }
                }
            }
        }
    }
}
