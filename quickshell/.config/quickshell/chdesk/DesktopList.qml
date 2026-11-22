pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

ListView {
    id: root

    required property var desktopNames
    required property string activeDesktop
    required property string filterText

    signal desktopSelected(string name)

    readonly property string currentDesktop: {
        let vals = filteredModel.values;
        if (!vals || vals.length === 0)
            return "";
        let idx = Math.max(0, Math.min(root.currentIndex, vals.length - 1));
        return vals[idx] || "";
    }

    function setCurrent(index) {
        if (index >= 0 && index < count)
            root.currentIndex = index;
    }

    function selectByName(name) {
        let vals = filteredModel.values;
        if (!vals || vals.length === 0)
            return false;
        let idx = vals.indexOf(name);
        if (idx >= 0) {
            root.currentIndex = idx;
            root.positionViewAtIndex(idx, ListView.Contain);
            return true;
        }
        return false;
    }

    function nextItem() {
        if (count === 0)
            return;
        root.currentIndex = (root.currentIndex + 1) % count;
        root.positionViewAtIndex(root.currentIndex, ListView.Contain);
    }

    function previousItem() {
        if (count === 0)
            return;
        root.currentIndex = (root.currentIndex - 1 + count) % count;
        root.positionViewAtIndex(root.currentIndex, ListView.Contain);
    }

    onFilterTextChanged: {
        root.currentIndex = 0;
        root.positionViewAtBeginning();
    }

    spacing: 4
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    keyNavigationWraps: true

    model: ScriptModel {
        id: filteredModel
        values: {
            let filter = root.filterText.trim().toLowerCase();
            let all = root.desktopNames ? [...root.desktopNames] : [];

            if (filter.length === 0) {
                return all.sort((a, b) => a.localeCompare(b, undefined, { sensitivity: "base" }));
            }

            let matched = all.filter(name => name.toLowerCase().includes(filter));

            return matched.sort((a, b) => {
                let aLow = a.toLowerCase();
                let bLow = b.toLowerCase();
                let aStarts = aLow.startsWith(filter) ? 0 : 1;
                let bStarts = bLow.startsWith(filter) ? 0 : 1;
                if (aStarts !== bStarts)
                    return aStarts - bStarts;
                return aLow.localeCompare(bLow);
            });
        }
    }

    delegate: DesktopItem {
        required property int index
        required property string modelData

        desktopName: modelData
        selected: root.currentIndex === index
        isCurrentDesktop: modelData === root.activeDesktop

        width: root.width
        implicitHeight: 46

        onClicked: function (name) {
            root.desktopSelected(name);
        }

        onHovered: root.setCurrent(index)
    }
}
