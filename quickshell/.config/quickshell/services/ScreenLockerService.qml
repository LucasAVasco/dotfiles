pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string scriptPath: Quickshell.env("HOME") + "/.config/screenlocker/manager.sh"

    // "enabled" | "disabled" | "unavailable" | "unknown"
    property string state: "unknown"
    property bool busy: false
    property string lastError: ""

    readonly property bool enabled: state === "enabled"
    readonly property bool available: state === "enabled" || state === "disabled"

    function refresh() {
        if (queryProc.running)
            return;
        queryProc.running = true;
    }

    function setEnabled(targetEnabled) {
        if (busy || !available)
            return;
        let subcmd = targetEnabled ? "enable" : "disable";
        lastError = "";
        busy = true;
        toggleProc.command = ["bash", scriptPath, subcmd];
        toggleProc.running = true;
    }

    Process {
        id: queryProc
        command: ["bash", root.scriptPath, "is-enabled"]
        property string _out: ""
        property string _err: ""

        stdout: StdioCollector {
            onStreamFinished: queryProc._out = this.text
        }
        stderr: StdioCollector {
            onStreamFinished: queryProc._err = this.text
        }

        onExited: function (exitCode) {
            let trimmed = queryProc._out.trim();
            if (exitCode === 0 && trimmed === "y") {
                root.state = "enabled";
                root.lastError = "";
            } else if (exitCode === 0 && trimmed === "n") {
                root.state = "disabled";
                root.lastError = "";
            } else {
                root.state = "unavailable";
                root.lastError = queryProc._err.trim() || ("Unexpected output: " + (trimmed || ("exit " + exitCode)));
            }
            queryProc._out = "";
            queryProc._err = "";
            root.busy = false;
        }
    }

    Process {
        id: toggleProc
        property string _err: ""

        stderr: StdioCollector {
            onStreamFinished: toggleProc._err = this.text
        }

        onExited: function (exitCode) {
            if (exitCode !== 0) {
                root.lastError = toggleProc._err.trim() || ("Screen locker command failed (exit " + exitCode + ")");
            }
            toggleProc._err = "";
            // Always re-query actual state after enable/disable
            root.refresh();
        }
    }

    Component.onCompleted: refresh()
}
