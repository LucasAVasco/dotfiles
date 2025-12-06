//@ pragma UseQApplication
// The line above is required by the system tray to display a platform menu

import QtQuick
import Quickshell

import "./bars"
import "./launcher"
import "./lock"
import "./notification"
import "./sessions"

ShellRoot {
    id: root

    // Top bar
    Loader {
        source: "./bars/Main.qml"
    }

    // Notification daemon
    Loader {
        enabled: Quickshell.env("DISABLE_QUICKSHELL_NOTIFICATION_DAEMON") != "1"
        source: "./notification/Main.qml"
    }

    // Screen locker
    Loader {
        source: "./lock/Main.qml"
    }

    // Launcher
    Loader {
        source: "./launcher/Main.qml"
    }

    // Session manager
    Loader {
        source: "./sessions/Main.qml"
    }
}
