pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import "../theme"

ListView {
    id: root

    required property string appFilter

    signal appLaunched(DesktopEntry entry)

    readonly property DesktopEntry currentApp: {
        let vals = filteredModel.values;
        if (!vals || vals.length === 0)
            return null;
        let idx = Math.max(0, Math.min(root.currentIndex, vals.length - 1));
        return vals[idx] || null;
    }

    function setCurrentApp(index) {
        if (index >= 0 && index < count)
            root.currentIndex = index;
    }

    function nextApp() {
        if (count === 0)
            return;
        root.currentIndex = (root.currentIndex + 1) % count;
        root.positionViewAtIndex(root.currentIndex, ListView.Contain);
    }

    function previousApp() {
        if (count === 0)
            return;
        root.currentIndex = (root.currentIndex - 1 + count) % count;
        root.positionViewAtIndex(root.currentIndex, ListView.Contain);
    }

    onAppFilterChanged: {
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
            let filter = root.appFilter.trim().toLowerCase();
            let allApps = [...DesktopEntries.applications.values];

            if (filter.length === 0) {
                return allApps.sort((a, b) => a.name.localeCompare(b.name));
            }

            let matched = allApps.filter(app => {
                let name = (app.name || "").toLowerCase();
                let generic = (app.genericName || "").toLowerCase();
                let comment = (app.comment || "").toLowerCase();
                let keywords = app.keywords ? app.keywords.join(" ").toLowerCase() : "";
                return name.includes(filter) || generic.includes(filter) || comment.includes(filter) || keywords.includes(filter);
            });

            return matched.sort((a, b) => {
                let aName = (a.name || "").toLowerCase();
                let bName = (b.name || "").toLowerCase();
                let aStarts = aName.startsWith(filter) ? 0 : (aName.includes(filter) ? 1 : 2);
                let bStarts = bName.startsWith(filter) ? 0 : (bName.includes(filter) ? 1 : 2);
                if (aStarts !== bStarts)
                    return aStarts - bStarts;
                return aName.localeCompare(bName);
            });
        }
    }

    delegate: AppItem {
        required property int index
        required property var modelData

        entry: modelData
        visible: modelData != null
        active: root.currentIndex === index

        width: root.width
        implicitHeight: 54

        onClicked: function (entry) {
            root.appLaunched(entry);
        }

        onHovered: root.setCurrentApp(index)
    }
}
