import QtQuick
import Quickshell.Hyprland

import "../../../theme"

Text {
    font.family: Theme.fontSans
    font.pixelSize: Theme.fontSm
    font.weight: Font.Medium
    color: Theme.textSecondary
    elide: Text.ElideRight
    maximumLineCount: 1

    text: {
        let topLevel = Hyprland.activeToplevel;
        if (topLevel == null)
            return "";
        return topLevel.title;
    }
}
