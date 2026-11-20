pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property bool expanded: ShellState.activePopover === "sysmon"

    // CPU metrics (-1 indicates unavailable, distinct from real 0%)
    property real cpuPercent: -1
    property var perCorePercents: [] // [{ core: 0, percent: 12.3 }]
    property real cpuTempC: -1
    property string cpuTempPath: ""

    // Memory metrics (-1 indicates unavailable)
    property real memPercent: -1
    property double memTotalBytes: -1
    property double memAvailableBytes: -1
    property double memUsedBytes: -1

    // Storage capacity metrics (strictly capacity, NOT disk I/O)
    property real diskPercent: -1
    property double diskTotalBytes: -1
    property double diskUsedBytes: -1
    property double diskFreeBytes: -1
    property string diskMount: "/"

    // Previous /proc/stat ticks for delta calculation
    property var _prevCpuMap: ({})

    function formatBytes(bytes) {
        if (bytes < 0 || isNaN(bytes))
            return "N/A";
        let units = ["B", "KiB", "MiB", "GiB", "TiB"];
        let v = bytes;
        let idx = 0;
        while (v >= 1024 && idx < units.length - 1) {
            v /= 1024;
            idx++;
        }
        return (idx >= 3 ? v.toFixed(1) : Math.round(v)) + " " + units[idx];
    }

    function formatPercent(val) {
        if (val < 0 || isNaN(val))
            return "N/A";
        return Math.round(val) + "%";
    }

    function _parseProcStat(content) {
        if (!content || content.length === 0)
            return;
        let lines = content.split("\n");
        let nextMap = ({});
        let cores = [];

        for (let i = 0; i < lines.length; i++) {
            let line = lines[i].trim();
            if (!line.startsWith("cpu"))
                break;

            let parts = line.split(/\s+/);
            if (parts.length < 5)
                continue;
            let key = parts[0];
            let isTotal = key === "cpu";
            if (!isTotal && !root.expanded)
                continue; // Skip per-core math when popover is closed!

            let user = Number(parts[1]) || 0;
            let nice = Number(parts[2]) || 0;
            let sys = Number(parts[3]) || 0;
            let idle = Number(parts[4]) || 0;
            let iowait = Number(parts[5]) || 0;
            let irq = Number(parts[6]) || 0;
            let softirq = Number(parts[7]) || 0;
            let steal = Number(parts[8]) || 0;

            let total = user + nice + sys + idle + iowait + irq + softirq + steal;
            let busy = total - idle - iowait;
            nextMap[key] = { total: total, busy: busy };

            let prev = _prevCpuMap[key];
            if (prev) {
                let dTotal = total - prev.total;
                let dBusy = busy - prev.busy;
                let pct = dTotal > 0 ? Math.max(0, Math.min(100, (dBusy / dTotal) * 100.0)) : 0;
                if (isTotal) {
                    cpuPercent = pct;
                } else {
                    let coreNum = parseInt(key.slice(3), 10);
                    cores.push({ core: isNaN(coreNum) ? cores.length : coreNum, percent: pct });
                }
            }
        }

        _prevCpuMap = nextMap;
        if (root.expanded && cores.length > 0) {
            perCorePercents = cores;
        }
    }

    function _parseMemInfo(content) {
        if (!content || content.length === 0)
            return;
        let totalKb = -1;
        let availKb = -1;
        let lines = content.split("\n");
        for (let i = 0; i < lines.length; i++) {
            let line = lines[i];
            if (line.startsWith("MemTotal:")) {
                totalKb = parseInt(line.replace(/[^0-9]/g, ""), 10);
            } else if (line.startsWith("MemAvailable:")) {
                availKb = parseInt(line.replace(/[^0-9]/g, ""), 10);
            }
            if (totalKb > 0 && availKb >= 0)
                break;
        }

        if (totalKb > 0 && availKb >= 0) {
            let totalB = totalKb * 1024;
            let availB = availKb * 1024;
            let usedB = Math.max(0, totalB - availB);
            memTotalBytes = totalB;
            memAvailableBytes = availB;
            memUsedBytes = usedB;
            memPercent = Math.max(0, Math.min(100, (usedB / totalB) * 100.0));
        }
    }

    function refreshDisk() {
        if (!dfProc.running)
            dfProc.running = true;
    }

    onExpandedChanged: {
        if (expanded) {
            procStatView.reload();
            procMemView.reload();
            if (cpuTempPath.length > 0)
                tempView.reload();
            refreshDisk();
        }
    }

    // Zero-subprocess /proc/stat reader
    FileView {
        id: procStatView
        path: "/proc/stat"
        onLoaded: root._parseProcStat(this.text())
    }

    // Zero-subprocess /proc/meminfo reader
    FileView {
        id: procMemView
        path: "/proc/meminfo"
        onLoaded: root._parseMemInfo(this.text())
    }

    // Zero-subprocess CPU temperature reader (only reloaded when expanded)
    FileView {
        id: tempView
        path: root.cpuTempPath
        onLoaded: {
            let raw = parseInt(this.text().trim(), 10);
            if (!isNaN(raw) && raw > 0)
                root.cpuTempC = raw / 1000.0;
            else
                root.cpuTempC = -1;
        }
    }

    // Discover CPU hwmon sensor once on startup (prefers k10temp, coretemp, zenpower, acpitz)
    Process {
        id: discoverTempProc
        command: [
            "python3", "-c",
            "import glob,os\n"
            + "prefs=['k10temp','coretemp','zenpower','cpu_thermal','acpitz']\n"
            + "found={}\n"
            + "for d in sorted(glob.glob('/sys/class/hwmon/hwmon*')):\n"
            + "  try:\n"
            + "    name=open(os.path.join(d,'name')).read().strip().lower()\n"
            + "    inp=os.path.join(d,'temp1_input')\n"
            + "    if os.path.isfile(inp) and os.access(inp, os.R_OK): found.setdefault(name, inp)\n"
            + "  except Exception: pass\n"
            + "for p in prefs:\n"
            + "  if p in found: print(found[p]); raise SystemExit(0)\n"
            + "print('')"
        ]
        property string _out: ""
        stdout: StdioCollector {
            onStreamFinished: discoverTempProc._out = this.text
        }
        onExited: function (exitCode) {
            if (exitCode === 0) {
                let p = discoverTempProc._out.trim();
                root.cpuTempPath = p;
                if (p.length > 0 && root.expanded)
                    tempView.reload();
            }
            discoverTempProc._out = "";
        }
    }

    // Disk capacity query (strictly filesystem capacity, not disk I/O)
    Process {
        id: dfProc
        command: ["df", "-B1", "/"]
        property string _out: ""
        stdout: StdioCollector {
            onStreamFinished: dfProc._out = this.text
        }
        onExited: function (exitCode) {
            if (exitCode === 0) {
                let lines = dfProc._out.trim().split("\n");
                if (lines.length >= 2) {
                    let parts = lines[lines.length - 1].trim().split(/\s+/);
                    if (parts.length >= 6) {
                        let total = Number(parts[1]);
                        let used = Number(parts[2]);
                        let avail = Number(parts[3]);
                        let mount = parts[5];
                        if (!isNaN(total) && total > 0) {
                            root.diskTotalBytes = total;
                            root.diskUsedBytes = used;
                            root.diskFreeBytes = avail;
                            root.diskMount = mount || "/";
                            root.diskPercent = Math.max(0, Math.min(100, (used / total) * 100.0));
                        }
                    }
                }
            }
            dfProc._out = "";
        }
    }

    // Lightweight timer: 3s when closed, 2s when expanded
    Timer {
        interval: root.expanded ? 2000 : 3000
        repeat: true
        running: true
        onTriggered: {
            procStatView.reload();
            procMemView.reload();
            if (root.expanded && root.cpuTempPath.length > 0)
                tempView.reload();
        }
    }

    // Slow disk capacity timer (30s)
    Timer {
        interval: 30000
        repeat: true
        running: true
        onTriggered: root.refreshDisk()
    }

    Component.onCompleted: {
        discoverTempProc.running = true;
        procStatView.reload();
        procMemView.reload();
        refreshDisk();
    }
}
