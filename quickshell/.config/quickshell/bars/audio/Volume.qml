import QtQuick
import Quickshell.Services.Pipewire

import "../config"

Text {
    color: Colors.foreground

    text: {
        if (!Pipewire.ready) {
            return "Waiting";
        }

        // Must be bind with `PwObjectTracker`
        let sink = Pipewire.defaultAudioSink;
        if (sink == null) {
            return "󰕾";
        }

        let audio = sink.audio;
        if (audio == null) {
            return "󰕾";
        }

        if (audio.muted) {
            return "󰖁";
        }

        return "󰕾 " + Math.round(audio.volume * 100);
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink] // Required to access the 'audio' property of the audio sink
    }
}
