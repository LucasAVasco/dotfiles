pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

import ".."
import "../../../components"

RowLayout {
    id: root

    function getWorkspaceState(id: int): int {
        let workspace = Hyprland.workspaces.values.find(w => w.id == id);

        if (workspace == null) {
            return WorkSpaceIndicator.State.Normal;
        }

        if (workspace.urgent) {
            return WorkSpaceIndicator.State.Urgent;
        } else if (workspace.active) {
            return WorkSpaceIndicator.State.Active;
        } else if (workspace.toplevels.values.length > 0) {
            return WorkSpaceIndicator.State.Occupied;
        } else {
            return WorkSpaceIndicator.State.Normal;
        }
    }

    function changeToWorkSpace(id: int) {
        Hyprland.dispatch(["hl.dsp.focus {workspace = 'r~" + id + "'}"]);
    }

    Repeater {
        model: [1, 2, 3, 4, 5]

        WorkSpaceIndicator {
            required property var modelData

            name: modelData
            state: {
                return root.getWorkspaceState(modelData);
            }

            onClicked: function (workspaceName) {
                root.changeToWorkSpace(workspaceName);
            }
        }
    }

    Space {
        size: 20
    }

    Repeater {
        model: [6, 7, 8, 9, 10]

        WorkSpaceIndicator {
            required property var modelData

            name: modelData
            state: {
                return root.getWorkspaceState(modelData);
            }

            onClicked: function (workspaceName) {
                root.changeToWorkSpace(workspaceName);
            }
        }
    }
}
