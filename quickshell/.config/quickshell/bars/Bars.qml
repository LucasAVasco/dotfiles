import QtQuick
import Quickshell

import "./audio"
import "./bluetooth"
import "./display"
import "./media"
import "./network"
import "./power"
import "./sysmon"

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

    // Top bar per monitor
    Variants {
        model: Quickshell.screens

        TopBar {
            property var modelData
            screen: modelData
        }
    }

    // System status popovers
    AudioPopover {}
    DisplayPopover {}
    NetworkPopover {}
    BluetoothPopover {}
    PowerPopover {}
    MediaPopover {}
    SysMonPopover {}
}
