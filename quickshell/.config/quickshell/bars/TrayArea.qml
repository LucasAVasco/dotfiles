pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets

import "../theme"

RowLayout {
    id: root

    required property QtObject menuParentWindow

    readonly property bool hasItems: SystemTray.items.values.length > 0

    visible: hasItems
    spacing: 2

    Repeater {
        model: SystemTray.items.values

        delegate: Rectangle {
            id: trayItem
            required property SystemTrayItem modelData

            implicitWidth: 26
            implicitHeight: 26
            radius: Theme.radiusPill
            color: trayMouse.pressed ? Theme.pressedBg : (trayMouse.containsMouse ? Theme.hoverBg : "transparent")
            antialiasing: true

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animFast
                }
            }

            IconImage {
                anchors.centerIn: parent
                implicitSize: 16
                source: trayItem.modelData.icon
            }

            MouseArea {
                id: trayMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                onClicked: function (event) {
                    switch (event.button) {
                    case Qt.LeftButton:
                        trayItem.modelData.activate();
                        break;
                    case Qt.RightButton:
                        let position = trayItem.mapToGlobal(0, trayItem.height + 6);
                        trayItem.modelData.display(root.menuParentWindow, position.x, position.y);
                        break;
                    case Qt.MiddleButton:
                        trayItem.modelData.secondaryActivate();
                        break;
                    default:
                        break;
                    }
                }

                onWheel: function (event) {
                    let delta = event.angleDelta;
                    let horizontal = (event.modifiers & Qt.ShiftModifier) !== 0;

                    if (delta.x !== 0)
                        trayItem.modelData.scroll(delta.x / 8, !horizontal);
                    if (delta.y !== 0)
                        trayItem.modelData.scroll(delta.y / 8, horizontal);
                }
            }
        }
    }
}
