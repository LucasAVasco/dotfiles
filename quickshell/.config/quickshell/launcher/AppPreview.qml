import QtQuick
import QtQuick.Layouts
import Quickshell

import "../theme"

RowLayout {
    id: root

    required property DesktopEntry entry

    implicitHeight: 24
    spacing: Theme.spaceSm

    Text {
        Layout.fillWidth: true
        text: {
            if (!root.entry)
                return "Type to search installed applications";
            if (root.entry.comment && root.entry.comment.length > 0)
                return root.entry.comment;
            if (root.entry.categories && root.entry.categories.length > 0)
                return root.entry.categories.slice(0, 3).join(" · ");
            return root.entry.name || "";
        }
        font.family: Theme.fontSans
        font.pixelSize: Theme.fontXs
        color: Theme.textMuted
        elide: Text.ElideRight
    }

    Text {
        text: "↑↓ Navigate  ·  ↵ Launch  ·  Esc Close"
        font.family: Theme.fontSans
        font.pixelSize: Theme.fontXs
        color: Theme.textMuted
    }
}
