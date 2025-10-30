import QtQuick

import "../config"

Text {
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

    // Appearance
    color: Colors.foreground

    text: {
        switch (root.state) {
        case WorkSpaceIndicator.State.Normal:
            return "";
        case WorkSpaceIndicator.State.Occupied:
            return "";
        case WorkSpaceIndicator.State.Active:
            return "";
        case WorkSpaceIndicator.State.Urgent:
            return "";
        }

        return "X";
    }

    // Switches to the work-space on click
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: () => {
            root.clicked(root.name);
        }
    }
}
