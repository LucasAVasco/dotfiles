pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell.Services.Pam

Rectangle {
    id: root
    anchors.fill: parent

    color: "black"

    // Unlock operation {{{

    signal unlocked

    function unlock() {
        passwordPrompt.focus = false;
        root.opacity = 0;
        unlockTimer.running = true;
    }

    Timer {
        id: unlockTimer
        interval: 200
        running: false

        onTriggered: {
            root.unlocked();
        }
    }

    // }}}

    // Opacity {{{

    Behavior on opacity {
        PropertyAnimation {
            duration: 200
        }
    }

    // Animation executed when opening the locker
    PropertyAnimation on opacity {
        from: 0
        to: 1
        duration: 200
    }

    // }}}

    Wallpaper {
        id: wallpaper
    }

    PasswordPrompt {
        id: passwordPrompt

        onPasswordGiven: function (password) {
            auth_manager.tryUnlock(password);
        }
    }

    AuthManager {
        id: auth_manager

        onAuthProcess: function (status) {
            switch (status) {
            case PamResult.Success:
                root.unlock();
                break;
            case PamResult.Error:
                passwordPrompt.showErrorMessage("Error authenticating");
                break;
            case PamResult.MaxTries:
                passwordPrompt.showErrorMessage("Maximum tries reached");
                break;
            case PamResult.Failed:
                passwordPrompt.showErrorMessage("Incorrect password");
                break;
            default:
                passwordPrompt.showErrorMessage("Unknown error: " + status.toString());
                break;
            }
        }
    }

    // // Uncomment this in development mode to bypass the screen locker.
    // // WARNING(LucasAVasco): This button is a security risk. Do not use in production
    // Button {
    //     text: "Bypass lock"
    //     anchors.top: parent.top
    //     anchors.right: parent.right

    //     width: parent.width * 0.2
    //     height: width

    //     background: Rectangle {
    //         color: "red"
    //     }

    //     onClicked: function () {
    //         root.unlock();
    //     }
    // }
}
