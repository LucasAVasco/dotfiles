import QtQuick

import "../theme"

Rectangle {
    id: root

    // "base" | "raised" | "elevated" | "popover" | "card"
    property string elevation: "raised"
    property bool bordered: true

    radius: Theme.radiusLg
    color: {
        switch (elevation) {
        case "base":
            return Theme.surfaceBase;
        case "elevated":
            return Theme.surfaceElevated;
        case "popover":
            return Theme.popoverBg;
        case "card":
            return Theme.cardBg;
        default:
            return Theme.surfaceRaised;
        }
    }

    border.width: bordered ? 1 : 0
    border.color: Theme.borderDefault
    antialiasing: true
}
