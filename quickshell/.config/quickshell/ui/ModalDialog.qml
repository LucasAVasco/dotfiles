import QtQuick
import QtQuick.Layouts
import Quickshell

import "../theme"

PanelWindow {
    id: root

    property bool open: false
    property int dialogWidth: 440
    property bool closeOnBackdrop: true

    default property alias content: bodySlot.data

    signal dismissed

    visible: open
    focusable: true
    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    // Dimmed backdrop
    Rectangle {
        anchors.fill: parent
        color: Theme.scrimBg
        opacity: root.open ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (root.closeOnBackdrop)
                    root.dismissed();
            }
        }
    }

    // Centered modal container
    Surface {
        id: card
        elevation: "popover"
        radius: Theme.radiusXl
        border.color: Theme.borderDefault

        anchors.centerIn: parent
        width: Math.min(root.dialogWidth, root.width - Theme.spaceXl * 2)
        implicitHeight: Math.min(bodySlot.implicitHeight + Theme.spaceXl * 2, root.height - Theme.spaceXl * 2)
        height: implicitHeight

        scale: root.open ? 1.0 : 0.96
        opacity: root.open ? 1.0 : 0.0

        Behavior on scale {
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutCubic
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutCubic
            }
        }

        // Prevent clicks inside the modal from dismissing it
        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            id: bodySlot
            anchors.fill: parent
            anchors.margins: Theme.spaceXl
            spacing: Theme.spaceMd
        }
    }

    // Escape key handling
    Item {
        focus: root.open
        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Escape) {
                event.accepted = true;
                root.dismissed();
            }
        }
    }
}
