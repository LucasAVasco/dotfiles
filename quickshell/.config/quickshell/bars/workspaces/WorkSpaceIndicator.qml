import QtQuick

import "../../theme"

Item {
    id: root

    enum State {
        Normal = 0,
        Occupied = 1,
        Active = 2,
        Urgent = 3
    }

    required property int state
    required property string name
    signal clicked(string name)

    readonly property bool isActive: state === WorkSpaceIndicator.State.Active
    readonly property bool isOccupied: state === WorkSpaceIndicator.State.Occupied
    readonly property bool isUrgent: state === WorkSpaceIndicator.State.Urgent

    implicitWidth: isActive ? 24 : 14
    implicitHeight: 20

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Theme.animNormal
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: root.isActive ? 20 : (root.isOccupied || root.isUrgent ? 7 : 5)
        height: root.isActive ? 7 : (root.isOccupied || root.isUrgent ? 7 : 5)
        radius: Theme.radiusPill
        antialiasing: true

        color: {
            if (root.isUrgent)
                return Theme.dangerHover;
            if (root.isActive)
                return Theme.textPrimary;
            if (root.isOccupied)
                return wsMouse.containsMouse ? Theme.textPrimary : Theme.textSecondary;
            return wsMouse.containsMouse ? Theme.textSecondary : Theme.textMuted;
        }

        opacity: (root.isActive || root.isUrgent) ? 1.0 : (root.isOccupied ? 0.85 : 0.45)

        Behavior on width {
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutCubic
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: Theme.animFast
            }
        }
    }

    MouseArea {
        id: wsMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked(root.name)
    }
}
