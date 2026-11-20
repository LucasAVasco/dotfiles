pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

import "../services"
import "../system_menu"

Item {
    id: root

    // GNOME-inspired top-left System Menu popover
    SystemMenuPopover {}

    // Power confirmation & scheduled shutdown/reboot modal dialog
    PowerActionDialog {}

    // Preserves existing IPC endpoint ("sessions.showMenu") + adds toggle
    IpcHandler {
        target: "sessions"

        function showMenu() {
            ShellState.openPopover("systemMenu", null);
        }

        function toggleMenu() {
            ShellState.togglePopover("systemMenu", null);
        }
    }
}
