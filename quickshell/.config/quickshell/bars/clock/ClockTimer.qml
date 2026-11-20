pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string time: Qt.formatDateTime(clock.date, "ddd MMM d   HH:mm")
    readonly property date currentDate: clock.date

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
