pragma ComponentBehavior: Bound
import Quickshell.Services.SystemTray

import QtQuick

Rectangle {
    id: root

    required property QtObject menuParentWindow

    // Appearance
    color: "transparent"

    ListView {
        id: tray

        // Layout
        anchors.fill: parent
        orientation: Qt.Horizontal

        // Model
        model: SystemTray.items.values

        delegate: Rectangle {
            required property SystemTrayItem modelData

            // Layout
            width: root.width / 10
            height: root.height

            // Appearance
            color: "transparent"

            Image {
                source: parent.modelData.icon

                // Layout
                anchors.fill: parent
            }

            MouseArea {
                focus: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                // Layout
                anchors.fill: parent

                // Events
                onClicked: function (event) {
                    switch (event.button) {
                    case Qt.LeftButton:
                        parent.modelData.activate();
                        break;
                    case Qt.RightButton:
                        let position = parent.mapToGlobal(0, parent.height * 1.5);

                        // Requires '//@ pragma UseQApplication' at the beginning of the root shell file to works
                        parent.modelData.display(root.menuParentWindow, position.x, position.y);
                        break;
                    case Qt.MiddleButton:
                        parent.modelData.secondaryActivate();
                        break;
                    default:
                        break;
                    }
                }

                onWheel: function (event) {
                    let delta = event.angleDelta;
                    let horizontal = false;

                    if (event.modifiers & Qt.ShiftModifier) {
                        // In order to receive the modifier, the window must be focusable
                        horizontal = true; // The shift modifier inverts the direction
                    }

                    if (delta.x != 0) {
                        parent.modelData.scroll(delta.x / 8, !horizontal);
                    }

                    if (delta.y != 0) {
                        parent.modelData.scroll(delta.y / 8, horizontal);
                    }
                }
            }
        }
    }
}
