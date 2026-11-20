pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pam

import "../theme"
import "./keyboard"

Rectangle {
    id: root
    anchors.fill: parent
    color: Theme.surfaceBase

    signal unlocked

    function unlock() {
        passwordPrompt.focus = false;
        root.opacity = 0;
        unlockTimer.running = true;
    }

    SystemClock {
        id: lockClock
        precision: SystemClock.Minutes
    }

    Timer {
        id: unlockTimer
        interval: Math.max(10, Theme.animNormal)
        running: false
        onTriggered: root.unlocked()
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.animNormal
            easing.type: Easing.OutCubic
        }
    }

    PropertyAnimation on opacity {
        from: 0
        to: 1
        duration: Theme.animNormal
    }

    Wallpaper {
        id: wallpaper
    }

    // Center GNOME-style lock screen stack: Clock + Date + User + Password Prompt
    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(380, parent.width - Theme.spaceXl * 2)
        spacing: Theme.spaceLg

        // Clock & Date
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Theme.spaceXs

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDateTime(lockClock.date, "HH:mm")
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontDisplay
                font.weight: Font.Light
                color: Theme.textPrimary
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDateTime(lockClock.date, "dddd, MMMM d")
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontXl
                font.weight: Font.Normal
                color: Theme.textSecondary
            }
        }

        // User avatar & name
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Theme.spaceMd
            spacing: Theme.spaceSm

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: 68
                implicitHeight: 68
                radius: Theme.radiusPill
                color: Theme.popoverBg
                border.width: 1
                border.color: Theme.borderDefault

                Text {
                    anchors.centerIn: parent
                    text: "󰀄"
                    font.family: Theme.fontIcon
                    font.pixelSize: 30
                    color: Theme.textPrimary
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Quickshell.env("USER") || "User"
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontLg
                font.weight: Font.DemiBold
                color: Theme.textPrimary
            }
        }

        // Password prompt
        PasswordPrompt {
            id: passwordPrompt
            Layout.fillWidth: true

            onPasswordGiven: function (password) {
                passwordPrompt.authenticating = true;
                auth_manager.tryUnlock(password);
            }
        }

        // Caps Lock warning pill
        CapsLockStatusPreview {
            Layout.alignment: Qt.AlignHCenter
        }
    }

    AuthManager {
        id: auth_manager

        onAuthProcess: function (status) {
            passwordPrompt.authenticating = false;
            switch (status) {
            case PamResult.Success:
                root.unlock();
                break;
            case PamResult.Error:
                passwordPrompt.showErrorMessage("Authentication error");
                break;
            case PamResult.MaxTries:
                passwordPrompt.showErrorMessage("Maximum attempts reached");
                break;
            case PamResult.Failed:
                passwordPrompt.showErrorMessage("Incorrect password");
                break;
            default:
                passwordPrompt.showErrorMessage("Authentication failed (" + status.toString() + ")");
                break;
            }
        }
    }
}
