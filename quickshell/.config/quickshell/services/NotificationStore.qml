pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    readonly property bool daemonEnabled: Quickshell.env("DISABLE_QUICKSHELL_NOTIFICATION_DAEMON") !== "1"
    property bool doNotDisturb: false
    property int unreadCount: 0
    readonly property int maxHistory: 50
    readonly property int maxVisibleToasts: 4

    // Reactive urgency counts (derived from the single historyListModel & toastListModel)
    property int criticalCount: 0
    property int normalCount: 0
    property int lowCount: 0

    property int toastCriticalCount: 0
    property int toastNormalCount: 0
    property int toastLowCount: 0

    // Shared synchronized collapse state for urgency groups (Center + Toast Area)
    property bool criticalCollapsed: false
    property bool normalCollapsed: false
    property bool lowCollapsed: false

    function isGroupCollapsed(urgency) {
        if (urgency === NotificationUrgency.Critical)
            return criticalCollapsed;
        if (urgency === NotificationUrgency.Low)
            return lowCollapsed;
        return normalCollapsed;
    }

    function toggleGroupCollapsed(urgency) {
        if (urgency === NotificationUrgency.Critical)
            criticalCollapsed = !criticalCollapsed;
        else if (urgency === NotificationUrgency.Low)
            lowCollapsed = !lowCollapsed;
        else
            normalCollapsed = !normalCollapsed;
    }

    // Internal map: entryId (int) -> Notification object
    property var _notifMap: ({})
    property var _dismissingIds: ({})
    property var _pendingRefreshIds: ({})
    property var _unreadIds: ({})
    property int _nextEntryId: 1

    property alias historyModel: historyListModel
    property alias toastModel: toastListModel

    ListModel {
        id: historyListModel
    }

    ListModel {
        id: toastListModel
    }

    function getNotification(entryId) {
        return _notifMap[entryId] || null;
    }

    function getEntryData(entryId) {
        let idx = _findIndexByEntryId(historyListModel, entryId);
        if (idx < 0)
            return null;
        return historyListModel.get(idx);
    }

    function _syncUnreadCount() {
        if (historyListModel.count === 0) {
            _unreadIds = ({});
            unreadCount = 0;
            return;
        }
        let count = 0;
        for (let i = 0; i < historyListModel.count; i++) {
            if (_unreadIds[historyListModel.get(i).entryId])
                count++;
        }
        unreadCount = count;
    }

    function markAllRead() {
        _unreadIds = ({});
        unreadCount = 0;
    }

    function _recountUrgencies() {
        let crit = 0;
        let norm = 0;
        let low = 0;
        for (let i = 0; i < historyListModel.count; i++) {
            let u = historyListModel.get(i).urgency;
            if (u === NotificationUrgency.Critical)
                crit++;
            else if (u === NotificationUrgency.Low)
                low++;
            else
                norm++;
        }
        criticalCount = crit;
        normalCount = norm;
        lowCount = low;

        let tCrit = 0;
        let tNorm = 0;
        let tLow = 0;
        for (let i = 0; i < toastListModel.count; i++) {
            let u = toastListModel.get(i).urgency;
            if (u === NotificationUrgency.Critical)
                tCrit++;
            else if (u === NotificationUrgency.Low)
                tLow++;
            else
                tNorm++;
        }
        toastCriticalCount = tCrit;
        toastNormalCount = tNorm;
        toastLowCount = tLow;
    }

    function categoryMeta(category) {
        if (!category || category.length === 0)
            return { label: "", icon: "" };
        let c = String(category).toLowerCase();
        if (c.startsWith("im"))
            return { label: "Message", icon: "󰍡" };
        if (c.startsWith("email"))
            return { label: "Email", icon: "󰇮" };
        if (c.startsWith("call"))
            return { label: "Call", icon: "󰏲" };
        if (c.startsWith("device"))
            return { label: "Device", icon: "󰌢" };
        if (c.startsWith("network"))
            return { label: "Network", icon: "󰤨" };
        if (c.startsWith("transfer"))
            return { label: "Transfer", icon: "󰇚" };
        if (c.startsWith("presence"))
            return { label: "Presence", icon: "󰀄" };
        if (c.indexOf("music") >= 0 || c.indexOf("media") >= 0)
            return { label: "Media", icon: "󰝚" };
        if (c.indexOf("battery") >= 0 || c.indexOf("power") >= 0)
            return { label: "Power", icon: "󰁹" };
        if (c.indexOf("error") >= 0)
            return { label: "Error", icon: "󰅚" };
        // Graceful fallback: capitalize prefix
        let clean = c.split(".")[0];
        let label = clean.length > 0 ? (clean.charAt(0).toUpperCase() + clean.slice(1)) : "General";
        return { label: label, icon: "󰋼" };
    }

    function formatRelativeTime(timestampMs, nowDate) {
        if (!timestampMs || timestampMs <= 0)
            return "";
        let nowMs = nowDate ? nowDate.getTime() : Date.now();
        let diffSec = Math.max(0, Math.floor((nowMs - timestampMs) / 1000));
        if (diffSec < 45)
            return "Just now";
        let diffMin = Math.floor(diffSec / 60);
        if (diffMin < 60)
            return diffMin + "m ago";
        let diffHr = Math.floor(diffMin / 60);
        if (diffHr < 24)
            return diffHr + "h ago";
        return Qt.formatDateTime(new Date(timestampMs), "MMM d, HH:mm");
    }

    function _findIndexByEntryId(model, entryId) {
        for (let i = 0; i < model.count; i++) {
            if (model.get(i).entryId === entryId)
                return i;
        }
        return -1;
    }

    function _findIndexByNotifId(model, notifId) {
        if (!notifId || notifId <= 0)
            return -1;
        for (let i = 0; i < model.count; i++) {
            if (model.get(i).notifId === notifId)
                return i;
        }
        return -1;
    }

    function _extractCategory(notification) {
        try {
            if (notification.hints && notification.hints["category"] !== undefined && notification.hints["category"] !== null)
                return String(notification.hints["category"]);
        } catch (e) {}
        return "";
    }

    function _buildEntry(entryId, notification, version) {
        let nowMs = Date.now();
        let isCritical = notification.urgency === NotificationUrgency.Critical;
        let timeoutMs = 6000;
        if (isCritical) {
            timeoutMs = 0;
        } else if (notification.expireTimeout > 0) {
            timeoutMs = Math.max(2500, Math.min(30000, Math.round(notification.expireTimeout * 1000)));
        }

        return {
            entryId: entryId,
            notifId: notification.id || 0,
            version: version,
            appName: notification.appName || "Notification",
            desktopEntry: notification.desktopEntry || "",
            summary: notification.summary || "",
            body: notification.body || "",
            appIcon: notification.appIcon || "",
            image: notification.image ? String(notification.image) : "",
            category: _extractCategory(notification),
            urgency: notification.urgency,
            receivedAtMs: nowMs,
            expireAtMs: timeoutMs > 0 ? (nowMs + timeoutMs) : 0,
            timeoutMs: timeoutMs,
            paused: false,
            hasInlineReply: !!notification.hasInlineReply,
            inlineReplyPlaceholder: notification.inlineReplyPlaceholder || "Write a reply…",
            hasActionIcons: !!notification.hasActionIcons
        };
    }

    function _scheduleEntryRefresh(entryId) {
        if (_pendingRefreshIds[entryId])
            return;
        let pCopy = _pendingRefreshIds;
        pCopy[entryId] = true;
        _pendingRefreshIds = pCopy;

        Qt.callLater(function () {
            let pClear = root._pendingRefreshIds;
            delete pClear[entryId];
            root._pendingRefreshIds = pClear;
            root._refreshExistingEntry(entryId);
        });
    }

    function _refreshExistingEntry(entryId) {
        let notification = _notifMap[entryId];
        if (!notification)
            return;

        let hIdx = _findIndexByEntryId(historyListModel, entryId);
        if (hIdx < 0)
            return;

        let existing = historyListModel.get(hIdx);
        let nextVersion = (existing.version || 1) + 1;
        let entry = _buildEntry(entryId, notification, nextVersion);

        historyListModel.set(hIdx, entry);

        let isCritical = notification.urgency === NotificationUrgency.Critical;
        let showToast = !doNotDisturb || isCritical;
        let tIdx = _findIndexByEntryId(toastListModel, entryId);
        if (showToast) {
            if (tIdx >= 0) {
                toastListModel.set(tIdx, entry);
            } else {
                toastListModel.insert(0, entry);
            }
        } else if (tIdx >= 0) {
            toastListModel.set(tIdx, entry);
        }

        _recountUrgencies();
    }

    function _bindNotificationSignals(entryId, notification) {
        let capturedId = entryId;
        let capturedNotif = notification;

        let onMutated = function () {
            if (root._notifMap[capturedId] === capturedNotif) {
                root._scheduleEntryRefresh(capturedId);
            }
        };

        let signalNames = [
            "summaryChanged",
            "bodyChanged",
            "appNameChanged",
            "appIconChanged",
            "imageChanged",
            "urgencyChanged",
            "hintsChanged",
            "actionsChanged",
            "expireTimeoutChanged",
            "hasInlineReplyChanged",
            "inlineReplyPlaceholderChanged",
            "hasActionIconsChanged"
        ];

        for (let i = 0; i < signalNames.length; i++) {
            let sig = notification[signalNames[i]];
            if (sig && typeof sig.connect === "function") {
                sig.connect(onMutated);
            }
        }

        notification.closed.connect(function () {
            if (root._notifMap[capturedId] === capturedNotif) {
                root._removeCompletely(capturedId);
            }
        });
    }

    function _addNotification(notification) {
        if (!notification)
            return;

        notification.tracked = true;

        // Check replacement by notification ID (handles new-object replacements)
        let existingHistIdx = _findIndexByNotifId(historyListModel, notification.id);
        let isReplacement = existingHistIdx >= 0;
        let entryId = 0;
        let nextVersion = 1;
        let prevNotif = null;

        if (isReplacement) {
            let existing = historyListModel.get(existingHistIdx);
            entryId = existing.entryId;
            nextVersion = (existing.version || 1) + 1;
            prevNotif = _notifMap[entryId] || null;
        } else {
            entryId = _nextEntryId++;
            if (ShellState.activePopover !== "notificationCenter") {
                let uCopy = _unreadIds;
                uCopy[entryId] = true;
                _unreadIds = uCopy;
            }
        }

        let mapCopy = _notifMap;
        mapCopy[entryId] = notification;
        _notifMap = mapCopy;

        let entry = _buildEntry(entryId, notification, nextVersion);

        // Bind closed + in-place property-change signals (avoids double-binding if same object)
        if (prevNotif !== notification) {
            _bindNotificationSignals(entryId, notification);
        }

        // Update in place on replacement, or insert at top for new notification
        if (isReplacement) {
            historyListModel.set(existingHistIdx, entry);
        } else {
            historyListModel.insert(0, entry);
            while (historyListModel.count > maxHistory) {
                let oldestId = historyListModel.get(historyListModel.count - 1).entryId;
                let oldestNotif = _notifMap[oldestId];
                historyListModel.remove(historyListModel.count - 1);
                if (_unreadIds[oldestId]) {
                    let uEvict = _unreadIds;
                    delete uEvict[oldestId];
                    _unreadIds = uEvict;
                }
                if (oldestNotif) {
                    delete _notifMap[oldestId];
                    oldestNotif.tracked = false;
                }
            }
        }
        _syncUnreadCount();
        _recountUrgencies();

        // Update or insert into toast stack (respects Do Not Disturb for non-critical,
        // delivers consistently even when Notification Center is open)
        let isCritical = notification.urgency === NotificationUrgency.Critical;
        let showToast = !doNotDisturb || isCritical;
        let existingToastIdx = _findIndexByEntryId(toastListModel, entryId);
        if (showToast) {
            if (existingToastIdx >= 0) {
                toastListModel.set(existingToastIdx, entry);
            } else {
                toastListModel.insert(0, entry);
            }
        } else if (existingToastIdx >= 0) {
            toastListModel.set(existingToastIdx, entry);
        }
        _recountUrgencies();
    }

    function _removeCompletely(entryId) {
        if (ShellState.notificationDetailsEntryId === entryId) {
            ShellState.closeNotificationDetails();
        }

        let tIdx = _findIndexByEntryId(toastListModel, entryId);
        if (tIdx >= 0)
            toastListModel.remove(tIdx);

        let hIdx = _findIndexByEntryId(historyListModel, entryId);
        if (hIdx >= 0)
            historyListModel.remove(hIdx);

        if (_unreadIds[entryId]) {
            let uCopy = _unreadIds;
            delete uCopy[entryId];
            _unreadIds = uCopy;
        }
        _syncUnreadCount();
        _recountUrgencies();

        if (_notifMap[entryId] !== undefined) {
            let mapCopy = _notifMap;
            delete mapCopy[entryId];
            _notifMap = mapCopy;
        }
        if (_dismissingIds[entryId]) {
            let dCopy = _dismissingIds;
            delete dCopy[entryId];
            _dismissingIds = dCopy;
        }
    }

    function dismissToast(entryId) {
        let idx = _findIndexByEntryId(toastListModel, entryId);
        if (idx >= 0) {
            toastListModel.remove(idx);
            _recountUrgencies();
        }
    }

    function dismissGroup(targetUrgency) {
        // Snapshot all matching entryIds across history & toast models
        let ids = [];
        let seen = ({});
        for (let i = 0; i < historyListModel.count; i++) {
            let item = historyListModel.get(i);
            if (item.urgency === targetUrgency && !seen[item.entryId] && !_dismissingIds[item.entryId]) {
                seen[item.entryId] = true;
                ids.push(item.entryId);
            }
        }
        for (let i = 0; i < toastListModel.count; i++) {
            let item = toastListModel.get(i);
            if (item.urgency === targetUrgency && !seen[item.entryId] && !_dismissingIds[item.entryId]) {
                seen[item.entryId] = true;
                ids.push(item.entryId);
            }
        }

        if (ids.length === 0)
            return;

        // Mark in-flight to prevent duplicate dismissal requests
        let dCopy = _dismissingIds;
        for (let i = 0; i < ids.length; i++)
            dCopy[ids[i]] = true;
        _dismissingIds = dCopy;

        // Dismiss each via actual notification service & synchronize UI immediately
        for (let i = 0; i < ids.length; i++) {
            let id = ids[i];
            let notif = _notifMap[id];
            _removeCompletely(id);
            if (notif) {
                try {
                    notif.dismiss();
                } catch (e) {}
            }
        }
    }

    function pauseToast(entryId, paused) {
        let idx = _findIndexByEntryId(toastListModel, entryId);
        if (idx < 0)
            return;
        toastListModel.setProperty(idx, "paused", paused);
        if (!paused) {
            let item = toastListModel.get(idx);
            if (item.timeoutMs > 0) {
                toastListModel.setProperty(idx, "expireAtMs", Date.now() + Math.min(item.timeoutMs, 3500));
            }
        }
    }

    function dismissNotification(entryId) {
        let notif = _notifMap[entryId];
        _removeCompletely(entryId);
        if (notif) {
            try {
                notif.dismiss();
            } catch (e) {}
        }
    }

    function clearAll() {
        ShellState.closeNotificationDetails();
        let ids = [];
        for (let i = 0; i < historyListModel.count; i++) {
            ids.push(historyListModel.get(i).entryId);
        }
        toastListModel.clear();
        historyListModel.clear();
        _unreadIds = ({});
        unreadCount = 0;
        _recountUrgencies();

        let oldMap = _notifMap;
        _notifMap = ({});
        for (let i = 0; i < ids.length; i++) {
            let notif = oldMap[ids[i]];
            if (notif) {
                try {
                    notif.dismiss();
                } catch (e) {}
            }
        }
    }

    Timer {
        interval: 500
        repeat: true
        running: toastListModel.count > 0

        onTriggered: {
            let now = Date.now();
            let changed = false;
            for (let i = toastListModel.count - 1; i >= 0; i--) {
                let item = toastListModel.get(i);
                if (!item.paused && item.expireAtMs > 0 && item.expireAtMs <= now) {
                    toastListModel.remove(i);
                    changed = true;
                }
            }
            if (changed)
                root._recountUrgencies();
        }
    }

    Loader {
        active: root.daemonEnabled
        sourceComponent: Component {
            NotificationServer {
                keepOnReload: true
                actionIconsSupported: true
                actionsSupported: true
                bodyHyperlinksSupported: true
                bodyImagesSupported: true
                bodyMarkupSupported: true
                bodySupported: true
                imageSupported: true
                inlineReplySupported: true

                onNotification: function (notification) {
                    root._addNotification(notification);
                }
            }
        }
    }
}
