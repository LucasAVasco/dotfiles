pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string backlightScript: Quickshell.env("HOME") + "/.config/monitor/backlight.sh"
    readonly property string tempScript: Quickshell.env("HOME") + "/.config/monitor/screen-temperature.sh"

    readonly property int defaultBacklightPercent: 10
    readonly property int defaultTemperatureWarm: 3000
    readonly property int minTemperatureWarm: 1000
    readonly property int maxTemperatureWarm: 25000

    // =========================================================================
    // Backlight state (never polled when popup is closed)
    // =========================================================================
    property int backlightPercent: defaultBacklightPercent
    property bool backlightLoaded: false
    property bool backlightReading: false
    property bool backlightBusy: false
    property string backlightError: ""

    property string _activeBacklightOp: "" // "get" | "set" | "delta" | ""
    property bool _pendingBacklightGet: false
    property int _pendingBacklightSet: -1
    property int _pendingBacklightDelta: 0
    property int _inFlightBacklight: -1
    property int _lastAppliedBacklight: -1
    property bool _backlightNeedsSync: false

    // =========================================================================
    // Screen temperature state (never polled when popup is closed)
    // =========================================================================
    property int temperatureWarm: defaultTemperatureWarm
    property bool temperatureLoaded: false
    property bool temperatureReading: false
    property bool temperatureEnabled: false
    property bool temperatureEnabledReading: false
    property bool temperatureBusy: false
    property string temperatureError: ""

    property string _activeTempOp: "" // "get-warm" | "is-enabled" | "set-warm" | "set-enabled" | ""
    property bool _pendingTempGetWarm: false
    property bool _pendingTempGetEnabled: false
    property string _pendingTempSetWarm: "" // "" | "default" | "<int>"
    property int _pendingTempSetEnabled: -1 // -1 | 0 | 1
    property string _inFlightTemp: ""
    property int _lastAppliedTemp: -1

    function clampBacklight(val) {
        return Math.max(0, Math.min(100, Math.round(val)));
    }

    function clampTemperature(val) {
        return Math.max(minTemperatureWarm, Math.min(maxTemperatureWarm, Math.round(val)));
    }

    // Called only when DisplayPopover opens
    function refreshAll() {
        refreshBacklight();
        refreshTemperature();
    }

    // =========================================================================
    // Backlight public API
    // =========================================================================
    function refreshBacklight() {
        backlightError = "";
        backlightReading = true;
        _pendingBacklightGet = true;
        _pumpBacklightQueue();
    }

    function scrollBacklightFromBar(deltaPercent) {
        if (!deltaPercent)
            return;
        backlightError = "";

        if (ShellState.activePopover === "display" && backlightLoaded && !backlightReading) {
            let target = clampBacklight(backlightPercent + deltaPercent);
            backlightPercent = target;
            _pendingBacklightSet = target;
            _pendingBacklightDelta = 0;
        } else {
            _pendingBacklightDelta += Math.round(deltaPercent);
            if (backlightLoaded) {
                backlightPercent = clampBacklight(backlightPercent + deltaPercent);
            }
        }
        backlightCommitTimer.restart();
    }

    function setBacklightLive(targetPercent, forceCommit) {
        if (backlightReading)
            return;
        backlightCommitTimer.stop();
        backlightSyncTimer.stop();
        if (!forceCommit)
            _pendingBacklightGet = false;
        let hadError = backlightError.length > 0;
        backlightError = "";
        let clamped = clampBacklight(targetPercent);
        backlightPercent = clamped;
        _pendingBacklightDelta = 0;

        if (backlightProc.running) {
            if (_activeBacklightOp === "set" && clamped === _inFlightBacklight) {
                _pendingBacklightSet = -1;
            } else {
                _pendingBacklightSet = clamped;
            }
            _backlightNeedsSync = true;
            return;
        }

        if (clamped !== _lastAppliedBacklight || (forceCommit && hadError)) {
            _pendingBacklightSet = clamped;
            _backlightNeedsSync = true;
            _pumpBacklightQueue();
        }
    }

    function releaseBacklight(targetPercent) {
        setBacklightLive(targetPercent, true);
        if (ShellState.activePopover === "display" && (_backlightNeedsSync || _pendingBacklightSet >= 0 || backlightProc.running)) {
            _pendingBacklightGet = true;
            _pumpBacklightQueue();
        }
    }

    function scrollBacklightInPopover(targetPercent) {
        setBacklightLive(targetPercent, false);
        if (ShellState.activePopover === "display")
            backlightSyncTimer.restart();
    }

    function setBacklightImmediate(targetPercent) {
        if (backlightReading)
            return;
        backlightCommitTimer.stop();
        backlightSyncTimer.stop();
        backlightError = "";
        let clamped = clampBacklight(targetPercent);
        backlightPercent = clamped;
        _pendingBacklightSet = clamped;
        _pendingBacklightDelta = 0;
        _backlightNeedsSync = true;
        _pumpBacklightQueue();
    }

    function restoreDefaultBacklight() {
        setBacklightImmediate(defaultBacklightPercent);
        if (ShellState.activePopover === "display") {
            _pendingBacklightGet = true;
            _pumpBacklightQueue();
        }
    }

    function _pumpBacklightQueue() {
        if (backlightProc.running)
            return;

        if (_pendingBacklightSet >= 0) {
            let target = _pendingBacklightSet;
            _pendingBacklightSet = -1;
            _pendingBacklightDelta = 0;
            _activeBacklightOp = "set";
            _inFlightBacklight = target;
            _backlightNeedsSync = true;
            backlightBusy = true;
            backlightProc.command = ["bash", backlightScript, "set", target + "%"];
            backlightProc.running = true;
        } else if (_pendingBacklightDelta !== 0) {
            let delta = _pendingBacklightDelta;
            _pendingBacklightDelta = 0;
            let arg = (delta > 0 ? "+" : "") + delta + "%";
            _activeBacklightOp = "delta";
            _inFlightBacklight = -1;
            _backlightNeedsSync = true;
            backlightBusy = true;
            backlightProc.command = ["bash", backlightScript, "set", arg];
            backlightProc.running = true;
        } else if (_pendingBacklightGet) {
            _pendingBacklightGet = false;
            if (ShellState.activePopover !== "display") {
                _activeBacklightOp = "";
                _inFlightBacklight = -1;
                backlightReading = false;
                backlightBusy = false;
                return;
            }
            _activeBacklightOp = "get";
            _inFlightBacklight = -1;
            backlightReading = true;
            backlightBusy = true;
            backlightProc.command = ["bash", backlightScript, "get", "--json"];
            backlightProc.running = true;
        } else {
            _activeBacklightOp = "";
            _inFlightBacklight = -1;
            backlightBusy = false;
        }
    }

    Timer {
        id: backlightCommitTimer
        interval: 250
        repeat: false
        onTriggered: root._pumpBacklightQueue()
    }

    Timer {
        id: backlightSyncTimer
        interval: 300
        repeat: false
        onTriggered: {
            if (ShellState.activePopover === "display" && (root._backlightNeedsSync || root._pendingBacklightSet >= 0 || backlightProc.running)) {
                root._pendingBacklightGet = true;
                root._pumpBacklightQueue();
            }
        }
    }

    Process {
        id: backlightProc
        property string _out: ""
        property string _err: ""

        stdout: StdioCollector {
            onStreamFinished: backlightProc._out = this.text
        }
        stderr: StdioCollector {
            onStreamFinished: backlightProc._err = this.text
        }

        onExited: function (exitCode) {
            let op = root._activeBacklightOp;
            let appliedVal = root._inFlightBacklight;
            root._activeBacklightOp = "";
            root._inFlightBacklight = -1;

            if (op === "get") {
                if (exitCode === 0) {
                    try {
                        let parsed = JSON.parse(backlightProc._out.trim());
                        if (parsed && isFinite(parsed.percent)) {
                            let val = root.clampBacklight(parsed.percent);
                            root._lastAppliedBacklight = val;
                            // Do not clobber a newer user edit queued while reading
                            if (root._pendingBacklightSet < 0 && !backlightCommitTimer.running) {
                                root.backlightPercent = val;
                                root._backlightNeedsSync = false;
                            }
                            root.backlightLoaded = true;
                            root.backlightError = "";
                        } else {
                            root.backlightError = "Invalid backlight response.";
                        }
                    } catch (e) {
                        root.backlightError = "Failed to parse backlight value.";
                    }
                } else {
                    root.backlightError = backlightProc._err.trim() || ("Failed to read backlight (exit " + exitCode + ")");
                }
                root.backlightReading = false;
            } else if (op === "set") {
                if (exitCode !== 0) {
                    root.backlightError = backlightProc._err.trim() || ("Failed to set backlight (exit " + exitCode + ")");
                } else {
                    root._lastAppliedBacklight = appliedVal;
                    root.backlightError = "";
                }
            } else if (op === "delta") {
                root._lastAppliedBacklight = -1;
                if (exitCode !== 0) {
                    root.backlightError = backlightProc._err.trim() || ("Failed to set backlight (exit " + exitCode + ")");
                } else {
                    root.backlightError = "";
                }
            }

            backlightProc._out = "";
            backlightProc._err = "";
            root.backlightBusy = false;
            root._pumpBacklightQueue();
        }
    }

    // =========================================================================
    // Screen temperature public API
    // =========================================================================
    function refreshTemperature() {
        temperatureError = "";
        temperatureReading = true;
        temperatureEnabledReading = true;
        _pendingTempGetWarm = true;
        _pendingTempGetEnabled = true;
        _pumpTempQueue();
    }

    function setTemperatureLive(targetWarm, forceCommit) {
        if (temperatureReading)
            return;
        tempCommitTimer.stop();
        let hadError = temperatureError.length > 0;
        temperatureError = "";
        let clamped = clampTemperature(targetWarm);
        temperatureWarm = clamped;
        let targetStr = String(clamped);

        if (tempProc.running) {
            if (_activeTempOp === "set-warm" && (_inFlightTemp === targetStr || (_inFlightTemp === "default" && clamped === defaultTemperatureWarm))) {
                _pendingTempSetWarm = "";
            } else {
                _pendingTempSetWarm = targetStr;
            }
            return;
        }

        if (clamped !== _lastAppliedTemp || (forceCommit && hadError)) {
            _pendingTempSetWarm = targetStr;
            _pumpTempQueue();
        }
    }

    function setTemperatureImmediate(targetWarm) {
        if (temperatureReading)
            return;
        tempCommitTimer.stop();
        temperatureError = "";
        let clamped = clampTemperature(targetWarm);
        temperatureWarm = clamped;
        _pendingTempSetWarm = String(clamped);
        _pumpTempQueue();
    }

    function restoreDefaultTemperature() {
        if (temperatureReading)
            return;
        tempCommitTimer.stop();
        temperatureError = "";
        temperatureWarm = defaultTemperatureWarm;
        _pendingTempSetWarm = "default";
        _pumpTempQueue();
    }

    function setTemperatureEnabled(enabled) {
        if (temperatureEnabledReading)
            return;
        temperatureError = "";
        temperatureEnabled = enabled;
        _pendingTempSetEnabled = enabled ? 1 : 0;
        _pumpTempQueue();
    }

    function _pumpTempQueue() {
        if (tempProc.running)
            return;

        if (_pendingTempSetEnabled !== -1) {
            let en = _pendingTempSetEnabled === 1;
            _pendingTempSetEnabled = -1;
            _activeTempOp = "set-enabled";
            _inFlightTemp = "";
            temperatureBusy = true;
            tempProc.command = ["bash", tempScript, en ? "enable" : "disable"];
            tempProc.running = true;
        } else if (_pendingTempSetWarm.length > 0) {
            let val = _pendingTempSetWarm;
            _pendingTempSetWarm = "";
            _activeTempOp = "set-warm";
            _inFlightTemp = val;
            temperatureBusy = true;
            tempProc.command = ["bash", tempScript, "set-warm", val];
            tempProc.running = true;
        } else if (_pendingTempGetWarm) {
            _pendingTempGetWarm = false;
            _activeTempOp = "get-warm";
            _inFlightTemp = "";
            temperatureReading = true;
            temperatureBusy = true;
            tempProc.command = ["bash", tempScript, "get-warm"];
            tempProc.running = true;
        } else if (_pendingTempGetEnabled) {
            _pendingTempGetEnabled = false;
            _activeTempOp = "is-enabled";
            _inFlightTemp = "";
            temperatureEnabledReading = true;
            temperatureBusy = true;
            tempProc.command = ["bash", tempScript, "is-enabled"];
            tempProc.running = true;
        } else {
            _activeTempOp = "";
            _inFlightTemp = "";
            temperatureBusy = false;
        }
    }

    Timer {
        id: tempCommitTimer
        interval: 250
        repeat: false
        onTriggered: root._pumpTempQueue()
    }

    Process {
        id: tempProc
        property string _out: ""
        property string _err: ""

        stdout: StdioCollector {
            onStreamFinished: tempProc._out = this.text
        }
        stderr: StdioCollector {
            onStreamFinished: tempProc._err = this.text
        }

        onExited: function (exitCode) {
            let op = root._activeTempOp;
            let appliedTemp = root._inFlightTemp;
            root._activeTempOp = "";
            root._inFlightTemp = "";

            if (op === "get-warm") {
                if (exitCode === 0) {
                    let parsed = parseInt(tempProc._out.trim(), 10);
                    if (!isNaN(parsed)) {
                        let val = root.clampTemperature(parsed);
                        root._lastAppliedTemp = val;
                        if (root._pendingTempSetWarm.length === 0 && !tempCommitTimer.running) {
                            root.temperatureWarm = val;
                        }
                        root.temperatureLoaded = true;
                        root.temperatureError = "";
                    } else {
                        root.temperatureError = "Invalid screen temperature value.";
                    }
                } else {
                    root.temperatureError = tempProc._err.trim() || ("Failed to read temperature (exit " + exitCode + ")");
                }
                root.temperatureReading = false;
            } else if (op === "is-enabled") {
                if (exitCode === 0) {
                    let trimmed = tempProc._out.trim();
                    if (root._pendingTempSetEnabled === -1) {
                        root.temperatureEnabled = (trimmed === "y");
                    }
                    root.temperatureError = "";
                } else {
                    root.temperatureError = tempProc._err.trim() || ("Failed to read filter state (exit " + exitCode + ")");
                }
                root.temperatureEnabledReading = false;
            } else if (op === "set-warm") {
                if (exitCode !== 0) {
                    root.temperatureError = tempProc._err.trim() || ("Failed to update screen temperature (exit " + exitCode + ")");
                } else {
                    root._lastAppliedTemp = (appliedTemp === "default")
                        ? root.defaultTemperatureWarm
                        : root.clampTemperature(parseInt(appliedTemp, 10));
                    root.temperatureError = "";
                }
            } else if (op === "set-enabled") {
                if (exitCode !== 0) {
                    root.temperatureError = tempProc._err.trim() || ("Failed to update screen temperature (exit " + exitCode + ")");
                } else {
                    root.temperatureError = "";
                }
            }

            tempProc._out = "";
            tempProc._err = "";
            root.temperatureBusy = false;
            root._pumpTempQueue();
        }
    }
}
