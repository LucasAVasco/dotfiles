import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    required property int updateInterval
    property string deviceFile: ""
    property bool active: false

    FileView {
        id: device
        path: Qt.resolvedUrl(root.deviceFile)

        onLoaded: {
            root.active = device.text().trim() == "1";
        }
    }

    // The caps lock file is not a normal file system file (its a device file), so a `FileView` object can not track changes to it. Need to
    // poll
    Timer {
        interval: root.updateInterval
        repeat: true
        running: true

        onTriggered: {
            if (root.deviceFile == "") {
                return;
            }
            device.reload();
        }
    }
}
