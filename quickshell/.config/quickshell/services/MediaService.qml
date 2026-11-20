pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris

import "../libs"

Singleton {
    id: root

    // Store only dbusName string so we never retain stale references to destroyed MprisPlayer objects
    property string preferredDbusName: ""

    // Distinct state: player-reported vs locally displayed position & validated duration (all in seconds)
    property real reportedPosition: 0
    property real reportedLength: 0
    property real displayPosition: 0

    property string _trackKey: ""
    property double _lastTickMs: 0
    property int _ticksSinceSync: 0
    property bool _inSync: false
    property double _seekLockUntilMs: 0

    readonly property var players: Mpris.players ? [...Mpris.players.values].filter(p => p !== null) : []
    readonly property bool hasPlayers: players.length > 0

    readonly property MprisPlayer activePlayer: {
        if (players.length === 0)
            return null;

        if (preferredDbusName.length > 0) {
            let chosen = players.find(p => p.dbusName === preferredDbusName);
            if (chosen)
                return chosen;
        }

        let playing = players.find(p => p.playbackState === MprisPlaybackState.Playing);
        if (playing)
            return playing;

        return players[0];
    }

    readonly property real normalizedProgress: {
        if (!isFinite(reportedLength) || reportedLength <= 0)
            return 0.0;
        if (!isFinite(displayPosition) || displayPosition <= 0)
            return 0.0;
        return Math.max(0.0, Math.min(1.0, displayPosition / reportedLength));
    }

    readonly property bool canRaiseActive: {
        if (!activePlayer)
            return false;
        if (activePlayer.canRaise)
            return true;
        return LibEnv.is_wayland && (activePlayer.desktopEntry || "").trim().length > 0;
    }

    readonly property bool canQuitActive: activePlayer !== null && activePlayer.canQuit

    function _computeTrackKey(player) {
        if (!player)
            return "";
        return (player.dbusName || "") + "|" + (player.trackTitle || "") + "|" + (player.trackArtist || "") + "|" + (player.trackAlbum || "");
    }

    function _sanitizeDuration(raw) {
        let n = Number(raw);
        if (!isFinite(n) || n <= 0)
            return 0;
        return n;
    }

    function _sanitizePosition(raw, maxLen) {
        let n = Number(raw);
        if (!isFinite(n) || n < 0)
            return 0;
        if (isFinite(maxLen) && maxLen > 0)
            return Math.min(n, maxLen);
        return n;
    }

    onActivePlayerChanged: {
        _seekLockUntilMs = 0;
        _trackKey = _computeTrackKey(activePlayer);
        reportedPosition = 0;
        reportedLength = 0;
        displayPosition = 0;
        _lastTickMs = Date.now();
        syncNow(true);
    }

    function selectPlayer(dbusName) {
        preferredDbusName = dbusName || "";
        _seekLockUntilMs = 0;
        _trackKey = _computeTrackKey(activePlayer);
        reportedPosition = 0;
        reportedLength = 0;
        displayPosition = 0;
        syncNow(true);
    }

    function syncNow(resetOnTrackChange) {
        if (_inSync)
            return;
        _inSync = true;

        try {
            if (!activePlayer) {
                _trackKey = "";
                reportedPosition = 0;
                reportedLength = 0;
                displayPosition = 0;
                return;
            }

            let newKey = _computeTrackKey(activePlayer);
            let trackChanged = newKey !== _trackKey;
            if (trackChanged) {
                _trackKey = newKey;
                reportedLength = 0;
                reportedPosition = 0;
                displayPosition = 0;
            }

            // CRITICAL: Only read activePlayer.length when lengthSupported === true.
            // In Quickshell v0.3.2, when lengthSupported is false (e.g. Firefox dropping
            // mpris:length on seek), activePlayer.length returns activePlayer.position,
            // which would make displayPosition / reportedLength == 1.0 (end of track).
            if (activePlayer.lengthSupported) {
                let len = _sanitizeDuration(activePlayer.length);
                if (len > 0) {
                    reportedLength = len;
                } else if (resetOnTrackChange && trackChanged) {
                    reportedLength = 0;
                }
            } else if (resetOnTrackChange && trackChanged) {
                reportedLength = 0;
            }

            if (activePlayer.positionSupported) {
                activePlayer.positionChanged();
                let pos = _sanitizePosition(activePlayer.position, reportedLength);

                // Guard against browsers (e.g. Firefox) transiently reporting pos=0 &
                // lengthSupported=false right after a seek on the same track.
                let transientBrowserDrop = !trackChanged
                    && !activePlayer.lengthSupported
                    && pos === 0
                    && displayPosition > 0;

                if (!transientBrowserDrop) {
                    reportedPosition = pos;
                    if (Date.now() >= _seekLockUntilMs) {
                        displayPosition = pos;
                    }
                }
            } else if (resetOnTrackChange && trackChanged) {
                reportedPosition = 0;
                displayPosition = 0;
            }

            _lastTickMs = Date.now();
            _ticksSinceSync = 0;
        } finally {
            _inSync = false;
        }
    }

    function scheduleResync(delayMs) {
        resyncTimer.interval = delayMs || 250;
        resyncTimer.restart();
    }

    function seekTo(targetSec) {
        if (!activePlayer || !activePlayer.canSeek || !activePlayer.positionSupported)
            return;
        if (!isFinite(reportedLength) || reportedLength <= 0)
            return;

        let clamped = _sanitizePosition(targetSec, reportedLength);
        _seekLockUntilMs = Date.now() + 450;
        displayPosition = clamped;
        reportedPosition = clamped;
        _lastTickMs = Date.now();
        _ticksSinceSync = 0;

        activePlayer.position = clamped;
        scheduleResync(500);
    }

    function seekBy(offsetSec) {
        if (!activePlayer || !activePlayer.canSeek)
            return;
        let base = isFinite(displayPosition) ? displayPosition : 0;
        let next = _sanitizePosition(base + offsetSec, reportedLength);
        _seekLockUntilMs = Date.now() + 450;
        displayPosition = next;
        reportedPosition = next;
        _lastTickMs = Date.now();
        _ticksSinceSync = 0;

        activePlayer.seek(offsetSec);
        scheduleResync(500);
    }

    function nextTrack() {
        if (!activePlayer || !activePlayer.canGoNext)
            return;
        _seekLockUntilMs = 0;
        activePlayer.next();
        scheduleResync(350);
    }

    function previousTrack() {
        if (!activePlayer || !activePlayer.canGoPrevious)
            return;
        _seekLockUntilMs = 0;
        activePlayer.previous();
        scheduleResync(350);
    }

    function togglePlaying() {
        if (!activePlayer || !activePlayer.canTogglePlaying)
            return;
        activePlayer.togglePlaying();
        scheduleResync(250);
    }

    function raiseActivePlayer() {
        if (!activePlayer)
            return;
        if (activePlayer.canRaise) {
            activePlayer.raise();
            ShellState.closePopovers();
            return;
        }
        let entry = (activePlayer.desktopEntry || "").trim();
        if (LibEnv.is_wayland && entry.length > 0) {
            let safeClass = entry.replace(/[^a-zA-Z0-9._-]/g, "");
            if (safeClass.length > 0) {
                Hyprland.dispatch("focuswindow class:^(?i)" + safeClass + "$");
                ShellState.closePopovers();
            }
        }
    }

    function quitActivePlayer() {
        if (!activePlayer || !activePlayer.canQuit)
            return;
        activePlayer.quit();
        ShellState.closePopovers();
    }

    function formatTime(seconds) {
        let n = Number(seconds);
        if (!isFinite(n) || n < 0)
            return "0:00";
        let s = Math.floor(n);
        let hrs = Math.floor(s / 3600);
        let mins = Math.floor((s % 3600) / 60);
        let secs = s % 60;
        let pad = v => (v < 10 ? "0" : "") + String(v);
        if (hrs > 0)
            return hrs + ":" + pad(mins) + ":" + pad(secs);
        return mins + ":" + pad(secs);
    }

    function stateLabel(st) {
        switch (st) {
        case MprisPlaybackState.Playing:
            return "Playing";
        case MprisPlaybackState.Paused:
            return "Paused";
        default:
            return "Stopped";
        }
    }

    Timer {
        id: resyncTimer
        interval: 250
        repeat: false
        onTriggered: root.syncNow(false)
    }

    // Lightweight playback progress timer: runs ONLY while Playing and media popover is open.
    Timer {
        interval: 500
        repeat: true
        running: root.activePlayer !== null
            && root.activePlayer.positionSupported
            && root.activePlayer.playbackState === MprisPlaybackState.Playing
            && ShellState.activePopover === "media"

        onRunningChanged: {
            if (running) {
                root._lastTickMs = Date.now();
                root.syncNow(false);
            }
        }

        onTriggered: {
            if (!root.activePlayer)
                return;
            let now = Date.now();
            root._ticksSinceSync += 1;

            if (root._ticksSinceSync >= 6) {
                root.syncNow(false);
                return;
            }

            let rawDt = root._lastTickMs > 0 ? (now - root._lastTickMs) / 1000.0 : 0.5;
            let dt = Math.max(0.0, Math.min(1.5, rawDt));
            root._lastTickMs = now;

            let rate = (root.activePlayer.rate && isFinite(root.activePlayer.rate) && root.activePlayer.rate > 0)
                ? root.activePlayer.rate
                : 1.0;

            let nextPos = (isFinite(root.displayPosition) ? root.displayPosition : 0) + dt * rate;
            root.displayPosition = root._sanitizePosition(nextPos, root.reportedLength);
        }
    }

    Connections {
        target: root.activePlayer
        ignoreUnknownSignals: true

        function onPostTrackChanged() {
            let newKey = root._computeTrackKey(root.activePlayer);
            if (newKey !== root._trackKey) {
                root._seekLockUntilMs = 0;
                root.syncNow(true);
            } else {
                // Same track metadata update (e.g. Firefox dropping mpris:length on seek)
                root.syncNow(false);
            }
            root.scheduleResync(350);
        }

        function onTrackTitleChanged() {
            root.scheduleResync(300);
        }

        function onLengthChanged() {
            if (!root.activePlayer || !root.activePlayer.lengthSupported)
                return;
            let len = root._sanitizeDuration(root.activePlayer.length);
            if (len > 0) {
                root.reportedLength = len;
                if (root.displayPosition > len)
                    root.displayPosition = len;
            }
        }

        function onPositionChanged() {
            if (root._inSync || !root.activePlayer || !root.activePlayer.positionSupported)
                return;
            let pos = root._sanitizePosition(root.activePlayer.position, root.reportedLength);
            let transientBrowserDrop = !root.activePlayer.lengthSupported && pos === 0 && root.displayPosition > 0;
            if (transientBrowserDrop)
                return;
            root.reportedPosition = pos;
            if (Date.now() >= root._seekLockUntilMs) {
                root.displayPosition = pos;
                root._lastTickMs = Date.now();
            }
        }

        function onPlaybackStateChanged() {
            root._lastTickMs = Date.now();
            root.syncNow(false);
        }
    }
}
