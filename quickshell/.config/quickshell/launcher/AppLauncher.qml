import QtQuick
import QtQuick.Layouts
import Quickshell

import "../theme"
import "../ui"

PanelWindow {
    id: root
    signal done

    function launchApp(entry) {
        if (!entry)
            return;
        let cmd = [...entry.command];
        if (entry.runInTerminal) {
            cmd.unshift("default_term");
        }

        Quickshell.execDetached({
            command: cmd,
            workingDirectory: entry.workingDirectory || Quickshell.env("HOME")
        });

        root.done();
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

    // Dimmed backdrop
    Rectangle {
        anchors.fill: parent
        color: Theme.scrimBg

        MouseArea {
            anchors.fill: parent
            onClicked: root.done()
        }
    }

    // Main GNOME-inspired launcher surface
    Surface {
        id: container
        elevation: "popover"
        radius: Theme.radiusXl
        border.color: Theme.borderDefault

        anchors.centerIn: parent
        width: Math.min(620, root.width - Theme.spaceXl * 2)
        height: Math.min(540, root.height - Theme.spaceXl * 2)

        property real enterProgress: 0
        opacity: enterProgress
        scale: 0.96 + 0.04 * enterProgress

        Component.onCompleted: {
            enterAnim.start();
            search.focusInput();
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

            SearchInput {
                id: search
                Layout.fillWidth: true

                onNextApp: appList.nextApp()
                onPreviousApp: appList.previousApp()
                onEnter: root.launchApp(appList.currentApp)
                onAbort: root.done()
            }

            // App list or empty state
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                AppList {
                    id: appList
                    anchors.fill: parent
                    appFilter: search.text

                    onAppLaunched: function (entry) {
                        root.launchApp(entry);
                    }
                }

                ColumnLayout {
                    visible: appList.count === 0
                    anchors.centerIn: parent
                    spacing: Theme.spaceSm

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "󰍉"
                        font.family: Theme.fontIcon
                        font.pixelSize: 36
                        color: Theme.textMuted
                        opacity: 0.6
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "No matching applications"
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontMd
                        font.weight: Font.Medium
                        color: Theme.textSecondary
                    }
                }
            }

            Separator {
                Layout.fillWidth: true
            }

            AppPreview {
                Layout.fillWidth: true
                entry: appList.currentApp
            }
        }
    }
}
