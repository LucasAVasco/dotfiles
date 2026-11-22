pragma ComponentBehavior: Bound

import Quickshell.Wayland

import ".."

WlSessionLock {
    id: lock
    locked: true

    signal done

    WlSessionLockSurface {
        id: lockSurface
        color: "black"

        onVisibleChanged: {
            if (lockSurface.visible)
                lockInterface.ensurePromptFocus();
        }

        Interface {
            id: lockInterface
            onUnlocked: {
                lock.locked = false;
                lock.done();
            }
        }
    }
}
