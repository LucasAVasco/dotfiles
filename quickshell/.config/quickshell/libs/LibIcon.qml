pragma Singleton

import Quickshell

Singleton {
    function getIconPath(name): string {
        let emptyIcon = getEmptyIconPath();

        if (name === undefined) {
            return Quickshell.iconPath(emptyIcon);
        }

        return Quickshell.iconPath(name, emptyIcon);
    }

    function getEmptyIconPath(): string {
        return Quickshell.env("HOME") + "/.config/quickshell/assets/empty.svg";
    }
}
