pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

import "../theme"
import "../ui"

PanelWindow {
    id: root
    signal done

    property var desktopNames: []
    property string activeDesktop: ""
    property bool loadingList: true
    property string errorMessage: ""
    property bool _didInitialFocusActive: false

    function switchDesktop(name) {
        if (!name || name.length === 0)
            return;

        Quickshell.execDetached({
            command: ["chdesk", "change", name]
        });

        root.done();
    }

    function syncInitialSelection() {
        if (root._didInitialFocusActive)
            return;
        if (root.loadingList || root.activeDesktop.length === 0 || search.text.trim().length > 0)
            return;
        if (desktopList.selectByName(root.activeDesktop))
            root._didInitialFocusActive = true;
    }

    focusable: true
    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    anchors {
        top: true
        right: true
        bottom: true
        left: true
    }

    // Load available desktops
    Process {
        id: listProc
        command: ["chdesk", "ls-names"]
        property string _out: ""
        property string _err: ""

        stdout: StdioCollector {
            onStreamFinished: listProc._out = this.text
        }

        stderr: StdioCollector {
            onStreamFinished: listProc._err = this.text
        }

        onExited: function (exitCode) {
            root.loadingList = false;
            if (exitCode === 0) {
                let lines = listProc._out
                    .split(/\r?\n/)
                    .map(s => s.trim())
                    .filter(s => s.length > 0);
                // Deduplicate while preserving order
                let seen = {};
                let unique = [];
                for (let i = 0; i < lines.length; i++) {
                    if (!seen[lines[i]]) {
                        seen[lines[i]] = true;
                        unique.push(lines[i]);
                    }
                }
                root.desktopNames = unique;
                root.errorMessage = "";
                root.syncInitialSelection();
            } else {
                root.desktopNames = [];
                root.errorMessage = listProc._err.trim() || ("Failed to list desktops (exit code " + exitCode + ")");
            }
            listProc._out = "";
            listProc._err = "";
        }
    }

    // Load currently active desktop
    Process {
        id: activeProc
        command: ["chdesk", "show", "name"]
        property string _out: ""

        stdout: StdioCollector {
            onStreamFinished: activeProc._out = this.text
        }

        onExited: function (exitCode) {
            if (exitCode === 0) {
                let current = activeProc._out.trim();
                root.activeDesktop = (current.length > 0 && current !== "None") ? current : "";
                root.syncInitialSelection();
            }
            activeProc._out = "";
        }
    }

    // Dimmed backdrop
    Rectangle {
        anchors.fill: parent
        color: Theme.scrimBg

        MouseArea {
            anchors.fill: parent
            onClicked: root.done()
        }
    }

    // Main GNOME-inspired switcher surface
    Surface {
        id: container
        elevation: "popover"
        radius: Theme.radiusXl
        border.color: Theme.borderDefault

        anchors.centerIn: parent
        width: Math.min(440, root.width - Theme.spaceXl * 2)
        height: Math.min(460, root.height - Theme.spaceXl * 2)

        property real enterProgress: 0
        opacity: enterProgress
        scale: 0.96 + 0.04 * enterProgress

        Component.onCompleted: {
            enterAnim.start();
            search.focusInput();
            listProc.running = true;
            activeProc.running = true;
        }

        NumberAnimation {
            id: enterAnim
            target: container
            property: "enterProgress"
            from: 0
            to: 1
            duration: Theme.animNormal
            easing.type: Easing.OutCubic
        }

        // Prevent clicks inside modal from closing it
        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.spaceLg
            spacing: Theme.spaceMd

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spaceSm

                Text {
                    text: "󰍹"
                    font.family: Theme.fontIcon
                    font.pixelSize: 18
                    color: Theme.accentHover
                }

                Text {
                    text: "Switch Desktop"
                    font.family: Theme.fontSans
                    font.pixelSize: Theme.fontLg
                    font.weight: Font.DemiBold
                    color: Theme.textPrimary
                    Layout.fillWidth: true
                }

                Rectangle {
                    visible: root.activeDesktop.length > 0
                    implicitWidth: activeBadgeRow.implicitWidth + Theme.spaceSm * 2
                    implicitHeight: 24
                    radius: Theme.radiusPill
                    color: Theme.accentSubtle
                    border.width: 1
                    border.color: Theme.accentBorder

                    RowLayout {
                        id: activeBadgeRow
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            text: "󰄬"
                            font.family: Theme.fontIcon
                            font.pixelSize: 11
                            color: Theme.accentHover
                        }

                        Text {
                            text: root.activeDesktop
                            font.family: Theme.fontSans
                            font.pixelSize: Theme.fontXs
                            font.weight: Font.Medium
                            color: Theme.textPrimary
                        }
                    }
                }
            }

            // Search input
            TextFieldBox {
                id: search
                Layout.fillWidth: true
                leadingIcon: "󰍉"
                placeholderText: "Search desktops…"
                implicitHeight: 42

                onUpPressed: desktopList.previousItem()
                onDownPressed: desktopList.nextItem()
                onAccepted: root.switchDesktop(desktopList.currentDesktop)
                onEscapePressed: root.done()
            }

            // Desktop list or empty/loading/error state
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                DesktopList {
                    id: desktopList
                    anchors.fill: parent
                    desktopNames: root.desktopNames
                    activeDesktop: root.activeDesktop
                    filterText: search.text

                    onDesktopSelected: function (name) {
                        root.switchDesktop(name);
                    }
                }

                ColumnLayout {
                    visible: desktopList.count === 0
                    anchors.centerIn: parent
                    spacing: Theme.spaceSm

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: root.errorMessage.length > 0 ? "󰀪" : (root.loadingList ? "󰑐" : "󰍉")
                        font.family: Theme.fontIcon
                        font.pixelSize: 32
                        color: root.errorMessage.length > 0 ? Theme.dangerHover : Theme.textMuted
                        opacity: 0.7
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: {
                            if (root.errorMessage.length > 0)
                                return root.errorMessage;
                            if (root.loadingList)
                                return "Loading desktops…";
                            if (root.desktopNames.length === 0)
                                return "No desktops found";
                            return "No matching desktops";
                        }
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontMd
                        font.weight: Font.Medium
                        color: root.errorMessage.length > 0 ? Theme.dangerHover : Theme.textSecondary
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                        Layout.maximumWidth: container.width - Theme.spaceXl * 2
                    }
                }
            }

            Separator {
                Layout.fillWidth: true
            }

            // Subtle keyboard hints
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spaceMd

                Text {
                    text: "↑↓ Navigate"
                    font.family: Theme.fontSans
                    font.pixelSize: Theme.fontXs
                    color: Theme.textMuted
                }

                Text {
                    text: "↵ Switch"
                    font.family: Theme.fontSans
                    font.pixelSize: Theme.fontXs
                    color: Theme.textMuted
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: "Esc Close"
                    font.family: Theme.fontSans
                    font.pixelSize: Theme.fontXs
                    color: Theme.textMuted
                }
            }
        }
    }
}
