pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    // Active top-bar popover: "" | "systemMenu" | "notificationCenter" | "audio" | "display" | "network" | "bluetooth" | "power" | "media" | "sysmon"
    property string activePopover: ""
    property var activeScreen: null

    // Active power dialog mode: "" | "poweroff" | "reboot" | "logout" | "cancelSchedule"
    property string powerDialogMode: ""

    // Notification details window
    property int notificationDetailsEntryId: -1

    // Separate detailed weather window
    property bool weatherWindowOpen: false

    // Only show keyboard focus rings when navigating via keyboard (or in confirmation dialogs)
    property bool keyboardFocusVisible: false

    function markKeyboardNav() {
        keyboardFocusVisible = true;
    }

    function markPointerNav() {
        keyboardFocusVisible = false;
    }

    function resolveScreen(screen) {
        if (screen !== null && screen !== undefined)
            return screen;
        if (activeScreen !== null && activeScreen !== undefined)
            return activeScreen;
        if (Quickshell.screens.length > 0)
            return Quickshell.screens[0];
        return null;
    }

    function openPopover(name, screen) {
        keyboardFocusVisible = false;
        activeScreen = resolveScreen(screen);
        activePopover = name;
    }

    function togglePopover(name, screen) {
        if (activePopover === name) {
            activePopover = "";
        } else {
            openPopover(name, screen);
        }
    }

    function closePopovers() {
        activePopover = "";
        keyboardFocusVisible = false;
    }

    function openPowerDialog(mode, screen) {
        activePopover = "";
        keyboardFocusVisible = true;
        activeScreen = resolveScreen(screen);
        powerDialogMode = mode;
    }

    function closePowerDialog() {
        powerDialogMode = "";
        keyboardFocusVisible = false;
    }

    function openNotificationDetails(entryId, screen) {
        keyboardFocusVisible = false;
        activeScreen = resolveScreen(screen);
        notificationDetailsEntryId = entryId;
    }

    function closeNotificationDetails() {
        notificationDetailsEntryId = -1;
    }

    function openWeatherWindow(screen) {
        activePopover = "";
        keyboardFocusVisible = false;
        activeScreen = resolveScreen(screen);
        weatherWindowOpen = true;
    }

    function closeWeatherWindow() {
        weatherWindowOpen = false;
    }
}
