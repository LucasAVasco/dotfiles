pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import "../libs"

Singleton {
    id: root

    // System capabilities
    property bool canPowerOff: true
    property bool canReboot: true
    property bool canSuspend: true
    property bool canHibernate: false

    // Scheduled power action state (synced with org.freedesktop.login1)
    property bool hasScheduledAction: false
    property string scheduledType: "" // "poweroff" | "reboot" | ""
    property double scheduledTimeMs: 0
    property string remainingText: ""
    property string formattedScheduleTime: ""

    // Operation state & feedback
    property bool busy: false
    property string lastError: ""
    property string lastFeedback: ""

    // Pending operation tracking
    property string _pendingOp: "" // "schedule" | "cancel" | ""
    property string _pendingType: ""

    signal operationSucceeded(string operation, string message)
    signal operationFailed(string operation, string error)

    readonly property string scheduledActionLabel: {
        if (scheduledType === "poweroff" || scheduledType === "halt")
            return "Shutdown";
        if (scheduledType === "reboot" || scheduledType === "kexec")
            return "Reboot";
        return "";
    }

    function clearMessages() {
        lastError = "";
        lastFeedback = "";
    }

    function formatRemaining(targetMs) {
        let diffSec = Math.max(0, Math.floor((targetMs - Date.now()) / 1000));
        if (diffSec <= 0)
            return "imminent";
        let days = Math.floor(diffSec / 86400);
        let hrs = Math.floor((diffSec % 86400) / 3600);
        let mins = Math.floor((diffSec % 3600) / 60);
        let secs = diffSec % 60;

        if (days > 0)
            return days + "d " + hrs + "h " + mins + "m";
        if (hrs > 0)
            return hrs + "h " + mins + "m " + secs + "s";
        if (mins > 0)
            return mins + "m " + secs + "s";
        return secs + "s";
    }

    function formatTargetDate(dateObj) {
        if (!dateObj || isNaN(dateObj.getTime()))
            return "";
        let now = new Date();
        let sameDay = dateObj.getFullYear() === now.getFullYear()
            && dateObj.getMonth() === now.getMonth()
            && dateObj.getDate() === now.getDate();

        let tomorrow = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1);
        let isTomorrow = dateObj.getFullYear() === tomorrow.getFullYear()
            && dateObj.getMonth() === tomorrow.getMonth()
            && dateObj.getDate() === tomorrow.getDate();

        let timeStr = Qt.formatDateTime(dateObj, "HH:mm");
        if (sameDay)
            return "Today at " + timeStr;
        if (isTomorrow)
            return "Tomorrow at " + timeStr;
        return Qt.formatDateTime(dateObj, "ddd, MMM d 'at' HH:mm");
    }

    function refreshScheduled() {
        if (queryScheduledProc.running)
            return;
        queryScheduledProc.running = true;
    }

    function scheduleAction(actionType, targetDate) {
        clearMessages();

        if (actionType !== "poweroff" && actionType !== "reboot") {
            lastError = "Unsupported scheduled action type.";
            operationFailed("schedule", lastError);
            return;
        }

        if (!targetDate || isNaN(targetDate.getTime())) {
            lastError = "Invalid date or time selected.";
            operationFailed("schedule", lastError);
            return;
        }

        let targetMs = targetDate.getTime();
        if (targetMs <= Date.now() + 5000) {
            lastError = "Scheduled time must be in the future.";
            operationFailed("schedule", lastError);
            return;
        }

        let usec = Math.floor(targetMs * 1000);
        if (busy)
            return;

        busy = true;
        _pendingOp = "schedule";
        _pendingType = actionType;

        scheduleProc.command = [
            "busctl", "call",
            "org.freedesktop.login1",
            "/org/freedesktop/login1",
            "org.freedesktop.login1.Manager",
            "ScheduleShutdown",
            "st",
            actionType,
            String(usec)
        ];
        scheduleProc.running = true;
    }

    function cancelScheduled() {
        clearMessages();
        if (busy)
            return;

        busy = true;
        _pendingOp = "cancel";
        _pendingType = scheduledType;

        cancelProc.command = [
            "busctl", "call",
            "org.freedesktop.login1",
            "/org/freedesktop/login1",
            "org.freedesktop.login1.Manager",
            "CancelScheduledShutdown"
        ];
        cancelProc.running = true;
    }

    function executeImmediate(action) {
        clearMessages();
        let cmd = [];

        if (LibEnv.is_debug && action !== "lock") {
            Quickshell.execDetached({
                command: ["notify-send", "QuickShell (Dry Run)", "Power action requested: " + action]
            });
            lastFeedback = "Dry run: " + action;
            return;
        }

        switch (action) {
        case "poweroff":
            cmd = ["systemctl", "poweroff"];
            break;
        case "reboot":
            cmd = ["systemctl", "reboot"];
            break;
        case "suspend":
            cmd = ["systemctl", "suspend"];
            break;
        case "hibernate":
            cmd = ["systemctl", "hibernate"];
            break;
        case "lock":
            cmd = ["bash", Quickshell.env("HOME") + "/.config/screenlocker/manager.sh", "run"];
            break;
        case "logout":
            cmd = ["bash", Quickshell.env("HOME") + "/.config/quickshell/sessions/scripts/logout.sh"];
            break;
        default:
            lastError = "Unknown action: " + action;
            return;
        }

        Quickshell.execDetached({ command: cmd });
    }

    function _applyScheduledState(typeStr, usecVal) {
        if (typeStr && typeStr.length > 0 && usecVal > 0 && usecVal < 1e18) {
            let ms = Math.floor(usecVal / 1000);
            hasScheduledAction = true;
            scheduledType = typeStr;
            scheduledTimeMs = ms;
            formattedScheduleTime = formatTargetDate(new Date(ms));
            remainingText = formatRemaining(ms);
        } else {
            hasScheduledAction = false;
            scheduledType = "";
            scheduledTimeMs = 0;
            formattedScheduleTime = "";
            remainingText = "";
        }
    }

    // Query ScheduledShutdown property
    Process {
        id: queryScheduledProc
        command: [
            "busctl", "--json=short", "get-property",
            "org.freedesktop.login1",
            "/org/freedesktop/login1",
            "org.freedesktop.login1.Manager",
            "ScheduledShutdown"
        ]

        property string _out: ""
        property string _err: ""

        stdout: StdioCollector {
            onStreamFinished: queryScheduledProc._out = this.text
        }
        stderr: StdioCollector {
            onStreamFinished: queryScheduledProc._err = this.text
        }

        onExited: function (exitCode) {
            if (exitCode === 0) {
                try {
                    let parsed = JSON.parse(queryScheduledProc._out.trim());
                    if (parsed && Array.isArray(parsed.data) && parsed.data.length >= 2) {
                        root._applyScheduledState(String(parsed.data[0] || ""), Number(parsed.data[1]));
                    } else {
                        root._applyScheduledState("", 0);
                    }
                } catch (e) {
                    root._applyScheduledState("", 0);
                }

                // Complete pending schedule/cancel verification
                if (root._pendingOp === "schedule") {
                    root.busy = false;
                    let op = root._pendingOp;
                    root._pendingOp = "";
                    if (root.hasScheduledAction) {
                        let msg = root.scheduledActionLabel + " scheduled for " + root.formattedScheduleTime + ".";
                        root.lastFeedback = msg;
                        root.operationSucceeded(op, msg);
                    } else {
                        root.lastError = "System did not confirm the scheduled action.";
                        root.operationFailed(op, root.lastError);
                    }
                } else if (root._pendingOp === "cancel") {
                    root.busy = false;
                    let op = root._pendingOp;
                    root._pendingOp = "";
                    if (!root.hasScheduledAction) {
                        let msg = "Scheduled power action canceled.";
                        root.lastFeedback = msg;
                        root.operationSucceeded(op, msg);
                    } else {
                        root.lastError = "Scheduled action is still active on the system.";
                        root.operationFailed(op, root.lastError);
                    }
                }
            } else {
                if (root._pendingOp !== "") {
                    let op = root._pendingOp;
                    root._pendingOp = "";
                    root.busy = false;
                    root.lastError = "Failed to verify scheduled state: " + (queryScheduledProc._err.trim() || "busctl exited with code " + exitCode);
                    root.operationFailed(op, root.lastError);
                }
            }
            queryScheduledProc._out = "";
            queryScheduledProc._err = "";
        }
    }

    // ScheduleShutdown process
    Process {
        id: scheduleProc
        property string _err: ""

        stderr: StdioCollector {
            onStreamFinished: scheduleProc._err = this.text
        }

        onExited: function (exitCode) {
            if (exitCode === 0) {
                root.refreshScheduled();
            } else {
                root.busy = false;
                root._pendingOp = "";
                let errMsg = scheduleProc._err.trim();
                root.lastError = errMsg.length > 0 ? errMsg : ("Failed to schedule action (exit code " + exitCode + ").");
                root.operationFailed("schedule", root.lastError);
            }
            scheduleProc._err = "";
        }
    }

    // CancelScheduledShutdown process
    Process {
        id: cancelProc
        property string _err: ""

        stderr: StdioCollector {
            onStreamFinished: cancelProc._err = this.text
        }

        onExited: function (exitCode) {
            if (exitCode === 0) {
                root.refreshScheduled();
            } else {
                root.busy = false;
                root._pendingOp = "";
                let errMsg = cancelProc._err.trim();
                root.lastError = errMsg.length > 0 ? errMsg : ("Failed to cancel scheduled action (exit code " + exitCode + ").");
                root.operationFailed("cancel", root.lastError);
            }
            cancelProc._err = "";
        }
    }

    // Capability checks (run once on startup)
    Process {
        id: capHibernateProc
        command: ["busctl", "--json=short", "call", "org.freedesktop.login1", "/org/freedesktop/login1", "org.freedesktop.login1.Manager", "CanHibernate"]
        property string _out: ""
        stdout: StdioCollector {
            onStreamFinished: capHibernateProc._out = this.text
        }
        onExited: function (exitCode) {
            if (exitCode === 0) {
                try {
                    let p = JSON.parse(capHibernateProc._out.trim());
                    root.canHibernate = p && p.data && (p.data[0] === "yes" || p.data[0] === "challenge");
                } catch (e) {}
            }
        }
    }

    Process {
        id: capSuspendProc
        command: ["busctl", "--json=short", "call", "org.freedesktop.login1", "/org/freedesktop/login1", "org.freedesktop.login1.Manager", "CanSuspend"]
        property string _out: ""
        stdout: StdioCollector {
            onStreamFinished: capSuspendProc._out = this.text
        }
        onExited: function (exitCode) {
            if (exitCode === 0) {
                try {
                    let p = JSON.parse(capSuspendProc._out.trim());
                    root.canSuspend = p && p.data && (p.data[0] === "yes" || p.data[0] === "challenge");
                } catch (e) {}
            }
        }
    }

    // 1-second countdown timer (active ONLY when a power action is scheduled)
    Timer {
        id: countdownTimer
        interval: 1000
        repeat: true
        running: root.hasScheduledAction
        property int _ticks: 0

        onTriggered: {
            if (root.scheduledTimeMs > 0) {
                root.remainingText = root.formatRemaining(root.scheduledTimeMs);
                root.formattedScheduleTime = root.formatTargetDate(new Date(root.scheduledTimeMs));
            }
            _ticks += 1;
            if (_ticks >= 30) {
                _ticks = 0;
                root.refreshScheduled();
            }
        }
    }

    Component.onCompleted: {
        refreshScheduled();
        capHibernateProc.running = true;
        capSuspendProc.running = true;
    }
}
