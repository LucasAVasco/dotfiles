pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

import "../services"
import "../weather"

Item {
    id: root

    // Floating notification popups (toasts)
    NotificationToastStack {}

    // GNOME-inspired Notification Center + Calendar + Weather Summary
    NotificationCenter {}

    // Notification Details modal window
    NotificationDetailsWindow {}

    // Separate Detailed Weather window
    WeatherWindow {}

    // IPC endpoints
    IpcHandler {
        target: "notification"

        function dismissAll() {
            NotificationStore.clearAll();
        }

        function toggleCenter() {
            ShellState.togglePopover("notificationCenter", null);
        }

        function openCenter() {
            ShellState.openPopover("notificationCenter", null);
        }

        function closeCenter() {
            if (ShellState.activePopover === "notificationCenter")
                ShellState.closePopovers();
        }
    }
}
