import QtQuick
import Quickshell.Hyprland

import "../../config"

Text {
    color: Colors.foreground

    text: {
        let topLevel = Hyprland.activeToplevel;
        if (topLevel == null) {
            return "";
        }
        return topLevel.title;
    }
}
