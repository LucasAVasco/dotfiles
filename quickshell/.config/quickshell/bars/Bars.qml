import QtQuick
import Quickshell

Item {
    id: root

    // Screen corners
    Variants {
        model: Quickshell.screens

        ScreenCorners {
            property var modelData
            screen: modelData
            radius: 10
        }
    }

    // Top bar
    Variants {
        model: Quickshell.screens

        TopBar {
            property var modelData
            screen: modelData
        }
    }
}
