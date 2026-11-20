import QtQuick
import QtQuick.Layouts

import "../services"
import "../theme"
import "../ui"

Rectangle {
    id: root

    property var barScreen: null

    readonly property var cond: WeatherService.wmoInfo(WeatherService.currentCode)
    readonly property var loc: WeatherService.currentLocation
    readonly property string locState: WeatherService.locationState

    implicitHeight: sumCol.implicitHeight + Theme.spaceMd * 2
    radius: Theme.radiusMd
    color: Theme.surfaceRaised
    border.width: 1
    border.color: Theme.borderSubtle
    antialiasing: true

    ColumnLayout {
        id: sumCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Theme.spaceMd
        spacing: Theme.spaceXs

        // Top Row: Location Switcher (or Weather header) + Auto pill + Details button
        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            IconButton {
                visible: WeatherService.favorites.length > 1
                icon: "󰅁"
                iconSize: 12
                buttonSize: 22
                onClicked: WeatherService.prevLocation()
            }

            Text {
                Layout.fillWidth: true
                text: root.loc ? root.loc.name : "Weather"
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontSm
                font.weight: Font.DemiBold
                color: Theme.textPrimary
                elide: Text.ElideRight
            }

            Rectangle {
                visible: WeatherService.usingDetectedLocation
                implicitWidth: autoLbl.implicitWidth + 8
                implicitHeight: 16
                radius: Theme.radiusPill
                color: Theme.accentSubtle

                Text {
                    id: autoLbl
                    anchors.centerIn: parent
                    text: "Auto"
                    font.family: Theme.fontSans
                    font.pixelSize: 9
                    font.weight: Font.DemiBold
                    color: Theme.accentHover
                }
            }

            IconButton {
                visible: WeatherService.favorites.length > 1
                icon: "󰅂"
                iconSize: 12
                buttonSize: 22
                onClicked: WeatherService.nextLocation()
            }

            ActionButton {
                text: root.loc ? "Details" : "Choose"
                compact: true
                variant: root.loc ? "ghost" : "secondary"
                implicitHeight: 24
                onClicked: ShellState.openWeatherWindow(root.barScreen)
            }
        }

        // Detecting location state (never displays an arbitrary city)
        RowLayout {
            visible: root.loc === null && root.locState === "detecting"
            Layout.fillWidth: true
            spacing: Theme.spaceSm

            Text {
                text: "󰍎"
                font.family: Theme.fontIcon
                font.pixelSize: 16
                color: Theme.accentHover
            }

            Text {
                Layout.fillWidth: true
                text: "Detecting location…"
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontXs
                color: Theme.textSecondary
            }
        }

        // No location configured / detection unavailable empty state
        ColumnLayout {
            visible: root.loc === null && root.locState !== "detecting"
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.locState === "unavailable"
                    ? "Location detection unavailable"
                    : "No location configured"
                font.family: Theme.fontSans
                font.pixelSize: Theme.fontXs
                font.weight: Font.Medium
                color: Theme.textSecondary
                wrapMode: Text.Wrap
            }

            Text {
                Layout.fillWidth: true
                text: "Click Choose to search and add a city."
                font.family: Theme.fontSans
                font.pixelSize: 11
                color: Theme.textMuted
                wrapMode: Text.Wrap
            }
        }

        // Loading / Error state when location is known but no cached forecast yet
        Text {
            visible: root.loc !== null && !WeatherService.hasData
            Layout.fillWidth: true
            text: WeatherService.loading ? "Loading weather…" : (WeatherService.errorText || "Weather unavailable")
            font.family: Theme.fontSans
            font.pixelSize: Theme.fontXs
            color: Theme.textMuted
            wrapMode: Text.Wrap
        }

        // Main compact weather summary
        RowLayout {
            visible: root.loc !== null && WeatherService.hasData
            Layout.fillWidth: true
            spacing: Theme.spaceSm

            Text {
                text: root.cond.icon
                font.family: Theme.fontIcon
                font.pixelSize: 28
                color: Theme.accentHover
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                RowLayout {
                    spacing: Theme.spaceSm

                    Text {
                        text: WeatherService.formatTemp(WeatherService.currentTempC)
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontXl
                        font.weight: Font.DemiBold
                        color: Theme.textPrimary
                    }

                    Text {
                        text: root.cond.label
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontXs
                        color: Theme.textSecondary
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                Text {
                    text: "↓" + WeatherService.formatTemp(WeatherService.todayMinC)
                        + "  ↑" + WeatherService.formatTemp(WeatherService.todayMaxC)
                        + "  ·  󰖝 " + WeatherService.formatWind(WeatherService.currentWindKmh)
                        + "  ·  󰖗 " + WeatherService.formatRain(WeatherService.currentRainMm)
                    font.family: Theme.fontSans
                    font.pixelSize: 11
                    color: Theme.textMuted
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }

        // Outdated / offline indicator
        Text {
            visible: root.loc !== null && WeatherService.hasData && (WeatherService.isStale || WeatherService.errorText.length > 0)
            Layout.fillWidth: true
            text: "Outdated · " + (WeatherService.errorText.length > 0 ? "Offline (cached)" : "Refresh recommended")
            font.family: Theme.fontSans
            font.pixelSize: 10
            color: Theme.warning
            elide: Text.ElideRight
        }
    }
}
