import QtQuick
import Quickshell

Item {
    id: root

    required property int radius
    required property ShellScreen screen

    Corner {
        screen: root.screen
        radius: root.radius
        left: true
        top: true
    }

    Corner {
        screen: root.screen
        radius: root.radius
        top: true
        right: true
    }

    Corner {
        screen: root.screen
        radius: root.radius
        right: true
        bottom: true
    }

    Corner {
        screen: root.screen
        radius: root.radius
        left: true
        bottom: true
    }
}
