import QtQuick
import Quickshell.Hyprland

import "../../../components"
import "../../config"

LimitedText {
    color: Colors.foreground

    text: {
        let topLevel = Hyprland.activeToplevel;
        if (topLevel == null) {
            return "";
        }
        return topLevel.title;
    }
}
