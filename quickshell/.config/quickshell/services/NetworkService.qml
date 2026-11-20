pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool available: true
    property bool hasEthernet: false
    property bool hasWifi: false
    property bool wifiEnabled: false
    property bool connected: false
    property string activeType: "" // "ethernet" | "wifi" | ""
    property string activeName: ""
    property int activeWifiSignal: 0
    property string wifiDevice: ""

    // Lists of plain JS objects
    property var ethernetDevices: [] // [{ device, state, connection, connected }]
    property var wifiNetworks: [] // [{ ssid, signal, security, inUse, secured }]

    property bool scanning: false
    property bool busy: false
    property string lastError: ""

    function clearError() {
        lastError = "";
    }

    function refreshAll() {
        if (!devicesProc.running)
            devicesProc.running = true;
        if (!radioProc.running)
            radioProc.running = true;
    }

    function refreshWifiList() {
        if (!hasWifi || !wifiEnabled || wifiListProc.running)
            return;
        wifiListProc.running = true;
    }

    function setWifiEnabled(enabled) {
        clearError();
        if (actionProc.running)
            return;
        busy = true;
        actionProc.command = ["nmcli", "radio", "wifi", enabled ? "on" : "off"];
        actionProc.running = true;
    }

    function rescanWifi() {
        clearError();
        if (!hasWifi || !wifiEnabled || rescanProc.running)
            return;
        scanning = true;
        rescanProc.running = true;
    }

    function connectWifi(ssid, password) {
        clearError();
        if (!ssid || ssid.length === 0 || actionProc.running)
            return;
        busy = true;
        if (password && password.length > 0) {
            actionProc.command = ["nmcli", "device", "wifi", "connect", ssid, "password", password];
        } else {
            actionProc.command = ["nmcli", "device", "wifi", "connect", ssid];
        }
        actionProc.running = true;
    }

    function disconnectDevice(device) {
        clearError();
        if (!device || actionProc.running)
            return;
        busy = true;
        actionProc.command = ["nmcli", "device", "disconnect", device];
        actionProc.running = true;
    }

    function connectDevice(device) {
        clearError();
        if (!device || actionProc.running)
            return;
        busy = true;
        actionProc.command = ["nmcli", "device", "connect", device];
        actionProc.running = true;
    }

    // Parse nmcli terse lines (handling escaped colons \:)
    function _splitTerse(line) {
        let parts = [];
        let cur = "";
        for (let i = 0; i < line.length; i++) {
            if (line[i] === "\\" && i + 1 < line.length && line[i + 1] === ":") {
                cur += ":";
                i++;
            } else if (line[i] === ":") {
                parts.push(cur);
                cur = "";
            } else {
                cur += line[i];
            }
        }
        parts.push(cur);
        return parts;
    }

    // Debounce timer for nmcli monitor events
    Timer {
        id: refreshDebounce
        interval: 350
        repeat: false
        onTriggered: root.refreshAll()
    }

    // Event-driven NetworkManager monitor (no polling)
    Process {
        id: monitorProc
        command: ["nmcli", "monitor"]
        running: true
        stdout: SplitParser {
            onRead: function () {
                refreshDebounce.restart();
            }
        }
        onExited: function () {
            // Do not spin if nmcli is unavailable
        }
    }

    // Query devices
    Process {
        id: devicesProc
        command: ["nmcli", "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "device"]
        property string _out: ""
        stdout: StdioCollector {
            onStreamFinished: devicesProc._out = this.text
        }
        onExited: function (exitCode) {
            if (exitCode !== 0) {
                root.available = false;
                return;
            }
            root.available = true;
            let lines = devicesProc._out.trim().split("\n").filter(l => l.length > 0);
            let eths = [];
            let foundEth = false;
            let foundWifi = false;
            let wDev = "";
            let actType = "";
            let actName = "";
            let isConn = false;

            for (let i = 0; i < lines.length; i++) {
                let cols = root._splitTerse(lines[i]);
                if (cols.length < 4)
                    continue;
                let dev = cols[0];
                let typ = cols[1];
                let st = cols[2];
                let conn = cols[3];

                if (typ === "ethernet") {
                    foundEth = true;
                    let c = st === "connected";
                    eths.push({ device: dev, state: st, connection: conn, connected: c });
                    if (c) {
                        isConn = true;
                        actType = "ethernet";
                        actName = conn || dev;
                    }
                } else if (typ === "wifi") {
                    foundWifi = true;
                    if (wDev.length === 0)
                        wDev = dev;
                    if (st === "connected" && actType !== "ethernet") {
                        isConn = true;
                        actType = "wifi";
                        actName = conn || dev;
                    }
                }
            }

            root.hasEthernet = foundEth;
            root.hasWifi = foundWifi;
            root.wifiDevice = wDev;
            root.ethernetDevices = eths;
            root.connected = isConn;
            root.activeType = actType;
            root.activeName = actName;
            devicesProc._out = "";

            if (foundWifi && root.wifiEnabled) {
                root.refreshWifiList();
            } else {
                root.wifiNetworks = [];
            }
        }
    }

    // Query Wi-Fi radio state
    Process {
        id: radioProc
        command: ["nmcli", "radio", "wifi"]
        property string _out: ""
        stdout: StdioCollector {
            onStreamFinished: radioProc._out = this.text
        }
        onExited: function (exitCode) {
            if (exitCode === 0) {
                root.wifiEnabled = radioProc._out.trim() === "enabled";
                if (root.hasWifi && root.wifiEnabled)
                    root.refreshWifiList();
                else if (!root.wifiEnabled)
                    root.wifiNetworks = [];
            }
            radioProc._out = "";
        }
    }

    // Query Wi-Fi networks
    Process {
        id: wifiListProc
        command: ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "device", "wifi", "list"]
        property string _out: ""
        stdout: StdioCollector {
            onStreamFinished: wifiListProc._out = this.text
        }
        onExited: function (exitCode) {
            if (exitCode === 0) {
                let lines = wifiListProc._out.trim().split("\n").filter(l => l.length > 0);
                let bySsid = ({});
                let actSig = 0;

                for (let i = 0; i < lines.length; i++) {
                    let cols = root._splitTerse(lines[i]);
                    if (cols.length < 4)
                        continue;
                    let inUse = cols[0].trim() === "*";
                    let ssid = cols[1].trim();
                    let sig = parseInt(cols[2], 10) || 0;
                    let sec = cols[3].trim();
                    if (ssid.length === 0)
                        continue;

                    if (inUse)
                        actSig = sig;

                    if (!bySsid[ssid] || inUse || sig > bySsid[ssid].signal) {
                        bySsid[ssid] = {
                            ssid: ssid,
                            signal: sig,
                            security: sec,
                            inUse: inUse || (bySsid[ssid] ? bySsid[ssid].inUse : false),
                            secured: sec.length > 0 && sec !== "--"
                        };
                    }
                }

                let list = Object.values(bySsid);
                list.sort((a, b) => {
                    if (a.inUse !== b.inUse)
                        return a.inUse ? -1 : 1;
                    return b.signal - a.signal;
                });

                root.wifiNetworks = list;
                root.activeWifiSignal = actSig;
            }
            wifiListProc._out = "";
        }
    }

    // Rescan Wi-Fi
    Process {
        id: rescanProc
        command: ["nmcli", "device", "wifi", "rescan"]
        onExited: function () {
            root.scanning = false;
            root.refreshWifiList();
        }
    }

    // Action runner (connect / disconnect / toggle)
    Process {
        id: actionProc
        property string _err: ""
        stderr: StdioCollector {
            onStreamFinished: actionProc._err = this.text
        }
        onExited: function (exitCode) {
            root.busy = false;
            if (exitCode !== 0) {
                let msg = actionProc._err.trim();
                root.lastError = msg.length > 0 ? msg : "Network operation failed.";
            }
            actionProc._err = "";
            root.refreshAll();
        }
    }

    Component.onCompleted: refreshAll()
}
