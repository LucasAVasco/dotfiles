pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell

import "../services"
import "../theme"
import "../ui"

ModalDialog {
    id: root

    readonly property string mode: ShellState.powerDialogMode
    readonly property bool isPowerMode: mode === "poweroff" || mode === "reboot"
    readonly property bool isLogoutMode: mode === "logout"
    readonly property bool isCancelMode: mode === "cancelSchedule"

    // "now" | "schedule"
    property string timingMode: "now"

    // Scheduled date/time state
    property int dayOffset: 0 // 0 = Today, 1 = Tomorrow, etc.
    property int selectedHour: 0
    property int selectedMinute: 0
    property double nowTickMs: Date.now()
    property string localError: ""

    open: mode !== ""
    screen: ShellState.resolveScreen(ShellState.activeScreen)
    dialogWidth: isPowerMode && timingMode === "schedule" ? 460 : 420

    onDismissed: {
        if (!PowerService.busy)
            ShellState.closePowerDialog();
    }

    onModeChanged: {
        if (mode !== "") {
            PowerService.clearMessages();
            localError = "";
            timingMode = "now";
            applyPresetMinutes(30);
            PowerService.refreshScheduled();
            cancelBtn.forceActiveFocus();
        }
    }

    // Keep live validation & preview fresh while scheduling
    Timer {
        interval: 1000
        repeat: true
        running: root.open && root.isPowerMode && root.timingMode === "schedule"
        onTriggered: root.nowTickMs = Date.now()
    }

    // Close dialog automatically when PowerService confirms schedule/cancel succeeded
    Connections {
        target: PowerService

        function onOperationSucceeded(operation, message) {
            if (root.open) {
                ShellState.closePowerDialog();
            }
        }

        function onOperationFailed(operation, error) {
            if (root.open) {
                root.localError = error;
            }
        }
    }

    function applyPresetMinutes(mins) {
        let base = new Date(Date.now() + mins * 60 * 1000);
        let todayStart = new Date();
        todayStart.setHours(0, 0, 0, 0);
        let targetStart = new Date(base.getFullYear(), base.getMonth(), base.getDate());
        dayOffset = Math.max(0, Math.round((targetStart.getTime() - todayStart.getTime()) / 86400000));
        selectedHour = base.getHours();
        selectedMinute = base.getMinutes();
        nowTickMs = Date.now();
        localError = "";
    }

    function stepHour(delta) {
        selectedHour = (selectedHour + delta + 24) % 24;
        nowTickMs = Date.now();
        localError = "";
    }

    function stepMinute(delta) {
        let total = selectedHour * 60 + selectedMinute + delta;
        if (total < 0)
            total += 1440;
        total = total % 1440;
        selectedHour = Math.floor(total / 60);
        selectedMinute = total % 60;
        nowTickMs = Date.now();
        localError = "";
    }

    function stepDay(delta) {
        dayOffset = Math.max(0, Math.min(365, dayOffset + delta));
        nowTickMs = Date.now();
        localError = "";
    }

    readonly property date computedTargetDate: {
        let _tick = nowTickMs; // reactive dependency
        let d = new Date();
        d.setHours(0, 0, 0, 0);
        d.setDate(d.getDate() + dayOffset);
        d.setHours(selectedHour, selectedMinute, 0, 0);
        return d;
    }

    readonly property bool isTargetValid: {
        let _tick = nowTickMs;
        return computedTargetDate.getTime() > Date.now() + 30000;
    }

    readonly property string actionTitle: {
        if (mode === "poweroff")
            return "Power Off";
        if (mode === "reboot")
            return "Restart System";
        if (mode === "logout")
            return "Log Out";
        if (mode === "cancelSchedule")
            return "Cancel Scheduled " + (PowerService.scheduledActionLabel || "Action");
        return "";
    }

    readonly property string actionIcon: {
        if (mode === "poweroff")
            return "󰐥";
        if (mode === "reboot")
            return "󰜉";
        if (mode === "logout")
            return "󰍃";
        return "󰅖";
    }

    function pad2(n) {
        return (n < 10 ? "0" : "") + String(n);
    }

    // =========================================================================
    // Dialog Header
    // =========================================================================
    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spaceMd

        Rectangle {
            implicitWidth: 42
            implicitHeight: 42
            radius: Theme.radiusPill
            color: root.isCancelMode ? Theme.warningSubtle : Theme.dangerSubtle
            border.width: 1
            border.color: root.isCancelMode ? Theme.warningBorder : Theme.dangerBorder

            Text {
                anchors.centerIn: parent
                text: root.actionIcon
                font.family: Theme.fontIcon
                font.pixelSize: 20
                color: root.isCancelMode ? Theme.warning : Theme.dangerHover
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: root.actionTitle
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontXl
                font.weight: Font.DemiBold
                color: Theme.textPrimary
                Layout.fillWidth: true
            }

            Text {
                text: {
                    if (root.isPowerMode)
                        return root.timingMode === "now"
                            ? "Confirm immediate power action"
                            : "Choose when to execute this action";
                    if (root.isLogoutMode)
                        return "End the current desktop session";
                    if (root.isCancelMode)
                        return "Abort the pending system power operation";
                    return "";
                }
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontSm
                color: Theme.textSecondary
                Layout.fillWidth: true
            }
        }
    }

    // =========================================================================
    // Mode Switcher (Now vs Schedule) — Only for Power Off / Reboot
    // =========================================================================
    Rectangle {
        visible: root.isPowerMode
        Layout.fillWidth: true
        implicitHeight: 38
        radius: Theme.radiusMd
        color: Theme.surfaceInput
        border.width: 1
        border.color: Theme.borderSubtle

        RowLayout {
            anchors.fill: parent
            anchors.margins: 3
            spacing: 3

            SegmentTab {
                text: "Execute Now"
                icon: "󱐋"
                selected: root.timingMode === "now"
                onClicked: {
                    root.timingMode = "now";
                    root.localError = "";
                }
            }

            SegmentTab {
                text: "Schedule for Later"
                icon: "󰥔"
                selected: root.timingMode === "schedule"
                onClicked: {
                    root.timingMode = "schedule";
                    root.nowTickMs = Date.now();
                    root.localError = "";
                }
            }
        }
    }

    // =========================================================================
    // Body — Immediate Power / Log Out / Cancel Schedule
    // =========================================================================
    Text {
        visible: (root.isPowerMode && root.timingMode === "now") || root.isLogoutMode || root.isCancelMode
        Layout.fillWidth: true
        wrapMode: Text.Wrap
        font.family: Theme.fontSans
        font.pixelSize: Theme.fontMd
        color: Theme.textSecondary
        lineHeight: 1.35
        text: {
            if (root.mode === "poweroff")
                return "All open applications will be closed and the computer will power off immediately. Any unsaved work will be lost.";
            if (root.mode === "reboot")
                return "All open applications will be closed and the computer will restart immediately. Any unsaved work will be lost.";
            if (root.mode === "logout")
                return "All running applications in your current session will be closed and you will return to the login screen. Any unsaved work will be lost.";
            if (root.mode === "cancelSchedule")
                return "Are you sure you want to cancel the scheduled "
                    + (PowerService.scheduledActionLabel || "power action").toLowerCase()
                    + " set for " + PowerService.formattedScheduleTime
                    + (PowerService.remainingText.length > 0 ? (" (in " + PowerService.remainingText + ")") : "") + "?";
            return "";
        }
    }

    // =========================================================================
    // Body — Schedule Picker (for Power Off / Reboot in Schedule mode)
    // =========================================================================
    ColumnLayout {
        visible: root.isPowerMode && root.timingMode === "schedule"
        Layout.fillWidth: true
        spacing: Theme.spaceMd

        // Quick preset chips
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spaceXs

            Text {
                text: "Quick:"
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontXs
                color: Theme.textMuted
                Layout.rightMargin: Theme.spaceXs
            }

            Repeater {
                model: [
                    { label: "+15m", mins: 15 },
                    { label: "+30m", mins: 30 },
                    { label: "+1h", mins: 60 },
                    { label: "+2h", mins: 120 }
                ]

                delegate: ActionButton {
                    required property var modelData
                    text: modelData.label
                    compact: true
                    variant: "secondary"
                    implicitHeight: 28
                    Layout.fillWidth: true
                    onClicked: root.applyPresetMinutes(modelData.mins)
                }
            }
        }

        // Date & Time Stepper Row
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spaceMd

            // Date selector
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 84
                radius: Theme.radiusMd
                color: Theme.surfaceRaised
                border.width: 1
                border.color: Theme.borderSubtle

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.spaceSm
                    spacing: Theme.spaceXs

                    Text {
                        text: "DATE"
                        font.family: Theme.fontSans
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        font.letterSpacing: 0.7
                        color: Theme.textMuted
                        Layout.alignment: Qt.AlignHCenter
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spaceXs

                        IconButton {
                            icon: "󰅁"
                            iconSize: 14
                            buttonSize: 28
                            disabled: root.dayOffset <= 0
                            onClicked: root.stepDay(-1)
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: root.dayOffset === 0 ? "Today" : (root.dayOffset === 1 ? "Tomorrow" : Qt.formatDate(root.computedTargetDate, "ddd"))
                                font.family: Theme.fontSans
                                font.pixelSize: Theme.fontSm
                                font.weight: Font.DemiBold
                                color: Theme.textPrimary
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: Qt.formatDate(root.computedTargetDate, "MMM d, yyyy")
                                font.family: Theme.fontSans
                                font.pixelSize: Theme.fontXs
                                color: Theme.textSecondary
                            }
                        }

                        IconButton {
                            icon: "󰅂"
                            iconSize: 14
                            buttonSize: 28
                            onClicked: root.stepDay(1)
                        }
                    }
                }
            }

            // Time selector (24h HH:MM)
            Rectangle {
                Layout.preferredWidth: 176
                implicitHeight: 84
                radius: Theme.radiusMd
                color: Theme.surfaceRaised
                border.width: 1
                border.color: Theme.borderSubtle

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.spaceSm
                    spacing: Theme.spaceXs

                    Text {
                        text: "TIME (24H)"
                        font.family: Theme.fontSans
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        font.letterSpacing: 0.7
                        color: Theme.textMuted
                        Layout.alignment: Qt.AlignHCenter
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Theme.spaceXs

                        // Hour stepper
                        ColumnLayout {
                            spacing: 0
                            IconButton {
                                Layout.alignment: Qt.AlignHCenter
                                icon: "󰅃"
                                iconSize: 13
                                buttonSize: 20
                                onClicked: root.stepHour(1)
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: root.pad2(root.selectedHour)
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontXl
                                font.weight: Font.DemiBold
                                color: Theme.textPrimary
                            }
                            IconButton {
                                Layout.alignment: Qt.AlignHCenter
                                icon: "󰅀"
                                iconSize: 13
                                buttonSize: 20
                                onClicked: root.stepHour(-1)
                            }
                        }

                        Text {
                            text: ":"
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontXl
                            font.weight: Font.DemiBold
                            color: Theme.textMuted
                        }

                        // Minute stepper
                        ColumnLayout {
                            spacing: 0
                            IconButton {
                                Layout.alignment: Qt.AlignHCenter
                                icon: "󰅃"
                                iconSize: 13
                                buttonSize: 20
                                onClicked: root.stepMinute(5)
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: root.pad2(root.selectedMinute)
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontXl
                                font.weight: Font.DemiBold
                                color: Theme.textPrimary
                            }
                            IconButton {
                                Layout.alignment: Qt.AlignHCenter
                                icon: "󰅀"
                                iconSize: 13
                                buttonSize: 20
                                onClicked: root.stepMinute(-5)
                            }
                        }

                        // Fine ±1 min buttons
                        ColumnLayout {
                            spacing: 2
                            Layout.leftMargin: 4
                            IconButton {
                                icon: "+"
                                iconSize: 12
                                buttonSize: 20
                                onClicked: root.stepMinute(1)
                            }
                            IconButton {
                                icon: "−"
                                iconSize: 12
                                buttonSize: 20
                                onClicked: root.stepMinute(-1)
                            }
                        }
                    }
                }
            }
        }

        // Confirmation preview / validation box
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: previewText.implicitHeight + Theme.spaceMd * 2
            radius: Theme.radiusMd
            color: root.isTargetValid ? Theme.accentSubtle : Theme.dangerSubtle
            border.width: 1
            border.color: root.isTargetValid ? Theme.accentBorder : Theme.dangerBorder

            Text {
                id: previewText
                anchors.fill: parent
                anchors.margins: Theme.spaceMd
                wrapMode: Text.Wrap
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontSm
                font.weight: Font.Medium
                color: root.isTargetValid ? Theme.textPrimary : Theme.dangerHover
                text: {
                    if (!root.isTargetValid)
                        return "Please choose a time at least 1 minute in the future.";
                    let verb = root.mode === "reboot" ? "restart" : "power off";
                    return "System will " + verb + " " + PowerService.formatTargetDate(root.computedTargetDate)
                        + " (in " + PowerService.formatRemaining(root.computedTargetDate.getTime()) + ").";
                }
            }
        }

        // Notice if replacing an existing scheduled action
        Text {
            visible: PowerService.hasScheduledAction
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            font.family: Theme.fontSans
            font.pixelSize: Theme.fontXs
            color: Theme.warning
            text: "Note: This will replace the currently scheduled "
                + PowerService.scheduledActionLabel.toLowerCase()
                + " (" + PowerService.formattedScheduleTime + ")."
        }
    }

    // =========================================================================
    // Error Banner (if system command failed)
    // =========================================================================
    Rectangle {
        visible: root.localError.length > 0
        Layout.fillWidth: true
        implicitHeight: errText.implicitHeight + Theme.spaceSm * 2
        radius: Theme.radiusSm
        color: Theme.dangerSubtle
        border.width: 1
        border.color: Theme.dangerBorder

        Text {
            id: errText
            anchors.fill: parent
            anchors.margins: Theme.spaceSm
            text: root.localError
            font.family: Theme.fontSans
            font.pixelSize: Theme.fontXs
            color: Theme.dangerHover
            wrapMode: Text.Wrap
        }
    }

    // =========================================================================
    // Footer Action Buttons
    // =========================================================================
    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: Theme.spaceXs
        spacing: Theme.spaceSm

        Item {
            Layout.fillWidth: true
        }

        ActionButton {
            id: cancelBtn
            text: "Cancel"
            variant: "secondary"
            disabled: PowerService.busy
            onClicked: ShellState.closePowerDialog()
        }

        ActionButton {
            variant: {
                if (root.isCancelMode)
                    return "warning";
                if (root.isPowerMode && root.timingMode === "schedule")
                    return "primary";
                return "danger";
            }
            disabled: PowerService.busy || (root.isPowerMode && root.timingMode === "schedule" && !root.isTargetValid)
            text: {
                if (PowerService.busy)
                    return "Working…";
                if (root.isCancelMode)
                    return "Cancel Schedule";
                if (root.isLogoutMode)
                    return "Log Out";
                if (root.timingMode === "schedule")
                    return root.mode === "reboot" ? "Schedule Restart" : "Schedule Power Off";
                return root.mode === "reboot" ? "Restart Now" : "Power Off Now";
            }

            onClicked: {
                root.localError = "";
                if (root.isCancelMode) {
                    PowerService.cancelScheduled();
                } else if (root.isLogoutMode) {
                    ShellState.closePowerDialog();
                    PowerService.executeImmediate("logout");
                } else if (root.isPowerMode && root.timingMode === "schedule") {
                    PowerService.scheduleAction(root.mode, root.computedTargetDate);
                } else if (root.isPowerMode && root.timingMode === "now") {
                    let act = root.mode;
                    ShellState.closePowerDialog();
                    PowerService.executeImmediate(act);
                }
            }
        }
    }

    // Segmented control tab component
    component SegmentTab: Rectangle {
        id: seg
        required property string text
        property string icon: ""
        property bool selected: false
        signal clicked

        activeFocusOnTab: true
        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: Theme.radiusSm
        color: selected ? Theme.surfaceElevated : ((segMouse.containsMouse || activeFocus) ? Theme.hoverBg : "transparent")
        border.width: activeFocus ? 2 : (selected ? 1 : 0)
        border.color: activeFocus ? Theme.accentHover : Theme.borderDefault
        antialiasing: true

        Behavior on color {
            ColorAnimation {
                duration: Theme.animFast
            }
        }

        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                event.accepted = true;
                seg.clicked();
            }
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: Theme.spaceXs

            Text {
                visible: seg.icon.length > 0
                text: seg.icon
                font.family: Theme.fontIcon
                font.pixelSize: 13
                color: seg.selected ? Theme.accentHover : Theme.textMuted
            }

            Text {
                text: seg.text
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontSm
                font.weight: seg.selected ? Font.DemiBold : Font.Medium
                color: seg.selected ? Theme.textPrimary : Theme.textSecondary
            }
        }

        MouseArea {
            id: segMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: seg.clicked()
        }
    }
}
