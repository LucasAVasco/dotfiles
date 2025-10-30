import QtQuick
import QtQuick.Shapes
import Quickshell

PanelWindow {
    id: root

    required property ShellScreen screen
    required property int radius
    property bool left: false
    property bool top: false
    property bool right: false
    property bool bottom: false

    // Places it in the background
    exclusionMode: ExclusionMode.Ignore
    aboveWindows: false

    // Layout
    anchors {
        top: root.top
        bottom: root.bottom
        left: root.left
        right: root.right
    }

    implicitWidth: radius
    implicitHeight: radius

    // Appearance
    color: "transparent"

    // Black shape that fills the corner
    // INFO(LucasAVasco): the shape starts at the crossing point of the screen sides and continues in the clockwise direction (independent
    // of the position of the corner)
    Shape {
        anchors.fill: parent

        ShapePath {
            fillColor: "black"
            strokeColor: "black"

            // Starts at the crossing point of the screen sides
            startX: (root.left ? 0 : root.radius)
            startY: (root.top ? 0 : root.radius)

            PathLine {
                x: (root.top ? root.radius : 0)
                y: (root.right ? root.radius : 0)
            }

            PathArc {
                x: (root.bottom ? root.radius : 0)
                y: (root.left ? root.radius : 0)
                radiusX: root.radius
                radiusY: root.radius
                direction: PathArc.Counterclockwise
            }
        }
    }
}
