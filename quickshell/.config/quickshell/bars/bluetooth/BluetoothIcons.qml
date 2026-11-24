import QtQuick
import Quickshell.Bluetooth

QtObject {
    id: root

    function deviceIcon(iconName, connected) {
        let name = (iconName || "").toLowerCase();
        if (name.includes("headset") || name.includes("headphone"))
            return "󰋋";
        if (name.includes("speaker") || name.includes("audio-card") || name.includes("hifi"))
            return "󰓃";
        if (name.includes("mouse"))
            return "󰍽";
        if (name.includes("keyboard"))
            return "󰌌";
        if (name.includes("gaming") || name.includes("joystick"))
            return "󰊗";
        if (name.includes("tablet"))
            return "󰓶";
        if (name.includes("phone"))
            return "󰏲";
        if (name.includes("computer") || name.includes("laptop"))
            return "󰌢";
        if (name.includes("camera"))
            return "󰄀";
        if (name.includes("printer"))
            return "󰐪";
        if (name.includes("multimedia") || name.includes("player"))
            return "󰎆";
        if (name.includes("network") || name.includes("modem"))
            return "󰀂";
        return connected ? "󰂱" : "󰂯";
    }

    function batteryIcon(pct) {
        if (pct >= 90)
            return "󰁹";
        if (pct >= 75)
            return "󰂁";
        if (pct >= 55)
            return "󰁿";
        if (pct >= 35)
            return "󰁽";
        if (pct >= 15)
            return "󰁻";
        return "󰁺";
    }

    function statusText(dev) {
        if (!dev)
            return "";
        if (dev.pairing)
            return "Pairing…";
        if (dev.state === BluetoothDeviceState.Connecting)
            return "Connecting…";
        if (dev.state === BluetoothDeviceState.Disconnecting)
            return "Disconnecting…";
        if (dev.connected)
            return "Connected";
        if (dev.blocked)
            return "Blocked";
        if (dev.paired)
            return "Paired";
        return "Available";
    }

    function primaryActionLabel(dev) {
        if (!dev)
            return "";
        if (dev.pairing)
            return "Cancel";
        if (dev.connected || dev.state === BluetoothDeviceState.Connecting)
            return "Disconnect";
        if (dev.paired)
            return "Connect";
        return "Pair";
    }

    function primaryActionVariant(dev) {
        if (!dev)
            return "secondary";
        if (dev.pairing)
            return "warning";
        if (dev.connected || dev.state === BluetoothDeviceState.Connecting)
            return "secondary";
        return "primary";
    }

    function triggerPrimaryAction(dev) {
        if (!dev)
            return;
        if (dev.pairing) {
            dev.cancelPair();
        } else if (dev.connected || dev.state === BluetoothDeviceState.Connecting) {
            dev.disconnect();
        } else if (dev.paired) {
            if (!dev.blocked)
                dev.connect();
        } else {
            if (!dev.blocked)
                dev.pair();
        }
    }
}
