import QtQuick
import Quickshell

import "../theme"

Item {
    id: root
    anchors.fill: parent

    // Fallback dark gradient background
    Rectangle {
        anchors.fill: parent
        color: Theme.surfaceBase
    }

    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        smooth: true
        asynchronous: true
        source: {
            let home = Quickshell.env("HOME");
            return home + "/.local/share/custom_desktop/wallpaper/lock.jpg";
        }
    }

    // Subtle dark scrim for legibility
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0.05, 0.05, 0.07, 0.52) }
            GradientStop { position: 0.5; color: Qt.rgba(0.05, 0.05, 0.07, 0.62) }
            GradientStop { position: 1.0; color: Qt.rgba(0.05, 0.05, 0.07, 0.78) }
        }
    }
}
