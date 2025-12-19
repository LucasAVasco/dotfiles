import QtQuick
import QtQuick.Layouts
import Quickshell

PanelWindow {
    id: root
    signal done

    function launchApp(entry) {
        // Command to launch
        let cmd = [...entry.command];
        if (entry.runInTerminal) {
            cmd.unshift("default_term"); // Adds the default the terminal emulator to the command
        }

        // Launches
        Quickshell.execDetached({
            command: cmd,

            // Uses the user home directory as fallback
            workingDirectory: entry.workingDirectory || Quickshell.env("HOME")
        });

        // Signal
        done();
    }

    focusable: true // Required to grab the user input

    // Layout
    anchors {
        top: true
        right: true
        bottom: true
        left: true
    }

    // Closes the launcher if the user clicks outside of it
    MouseArea {
        anchors.fill: parent

        onClicked: {
            root.done();
        }
    }

    // Appearance
    color: "transparent"

    Rectangle {
        // Layout
        anchors.centerIn: parent
        implicitWidth: root.width * 0.5
        implicitHeight: root.height * 0.8

        // Appearance
        color: "#111111"
        radius: 20
        border.color: "#222222"

        ColumnLayout {
            // Layout
            anchors.fill: parent
            anchors.margins: width / 60
            spacing: anchors.margins

            SearchInput {
                id: search

                // Layout
                implicitHeight: 15
                Layout.fillWidth: true
                Layout.leftMargin: parent.width / 6
                Layout.rightMargin: Layout.leftMargin
                Layout.fillHeight: true

                // Signals
                onNextApp: function () {
                    appList.nextApp();
                }

                onPreviousApp: function () {
                    appList.previousApp();
                }

                onEnter: function () {
                    root.launchApp(appList.currentApp);
                    root.done();
                }

                onAbort: function () {
                    root.done();
                }
            }

            AppPreview {
                entry: appList.currentApp

                // Layout
                implicitHeight: 30
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            AppList {
                id: appList

                appFilter: search.text

                // Layout
                implicitHeight: 55
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: parent.height / 8
                Layout.bottomMargin: Layout.topMargin

                // Signals
                onAppLaunched: function (entry) {
                    root.launchApp(entry);
                    root.done();
                }
            }
        }
    }
}
