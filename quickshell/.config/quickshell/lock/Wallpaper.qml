import QtQuick
import Quickshell

Image {
    anchors.fill: parent

    source: {
        let home = Quickshell.env("HOME");
        return home + "/.local/share/custom_desktop/wallpaper/lock.jpg";
    }
}
