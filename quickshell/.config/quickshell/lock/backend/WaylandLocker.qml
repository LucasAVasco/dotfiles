pragma ComponentBehavior: Bound

import Quickshell.Wayland

import ".."

WlSessionLock {
    id: lock
    locked: true

    signal done

    WlSessionLockSurface {
        color: "black"

        Interface {
            onUnlocked: {
                lock.locked = false;
                lock.done();
            }
        }
    }
}
