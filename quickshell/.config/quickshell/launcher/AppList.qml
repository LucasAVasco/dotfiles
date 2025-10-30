pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

ListView {
    id: root

    required property string appFilter

    signal appLaunched(DesktopEntry entry)

    readonly property DesktopEntry currentApp: {
        return root.model.values[root.currentIndex] || null;
    }

    // Navigation functions
    function setCurrentApp(index) {
        root.canScroll = true;
        root.currentIndex = index;
    }

    function nextApp() {
        root.canScroll = true;
        root.incrementCurrentIndex();
    }

    function previousApp() {
        root.canScroll = true;
        root.decrementCurrentIndex();
    }

    // Forces the root to not scroll until the `canScroll` property is set to `true`
    property bool canScroll: false
    onCurrentIndexChanged: function () {
        if (!root.canScroll) {
            root.currentIndex = 0;
        }
    }

    // Only shows the apps after the following delay
    property bool cleared: true
    Timer {
        running: true
        interval: 200 // Delay
        onTriggered: {
            root.cleared = false;
        }
    }

    // Apps
    model: ScriptModel {
        values: {
            if (root.cleared) {
                return [];
            }
            let filter = root.appFilter.toLowerCase();
            let apps = [...DesktopEntries.applications.values].filter(app => app.name.toLowerCase().includes(filter));
            return apps.sort((a, b) => a.name.localeCompare(b.name));
        }
    }

    delegate: AppItem {
        required property var modelData

        entry: modelData
        visible: modelData != null
        active: root.currentApp === modelData

        // Layout
        implicitWidth: parent ? parent.width : 0 // `ScriptModel` may set the `parent` null
        implicitHeight: root.height / 6

        onClicked: function (entry) {
            root.appLaunched(entry);
        }
    }

    // Transitions
    add: Transition {
        id: addTransition

        NumberAnimation {
            properties: "opacity"
            from: 0
            to: 1
            duration: 200
        }
    }

    remove: Transition {
        id: removeTransition

        NumberAnimation {
            properties: "opacity"
            from: 1
            to: 0
            duration: 200
        }
    }

    displaced: Transition {
        NumberAnimation {
            properties: "y"
            duration: 200
        }
    }
}
