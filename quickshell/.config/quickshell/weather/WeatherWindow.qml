pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell

import "../services"
import "../theme"
import "../ui"

PanelWindow {
    id: root

    readonly property bool isOpen: ShellState.weatherWindowOpen
    readonly property var loc: WeatherService.currentLocation
    readonly property var cond: WeatherService.wmoInfo(WeatherService.currentCode)

    // "hourly24" | "hourly48" | "daily7"
    property string seriesMode: "hourly24"

    readonly property var displayedRows: {
        if (seriesMode === "daily7")
            return WeatherService.dailySeries;
        if (seriesMode === "hourly48")
            return WeatherService.hourlySeries;
        return WeatherService.hourlySeries.slice(0, 24);
    }

    onIsOpenChanged: {
        if (isOpen) {
            if (WeatherService.currentLocation !== null) {
                WeatherService.fetchWeather();
                closeBtn.forceActiveFocus();
            } else {
                locSearchInput.focusInput();
            }
        }
    }

    screen: ShellState.resolveScreen(ShellState.activeScreen)
    visible: isOpen
    focusable: true
    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    // Dimmed backdrop
    Rectangle {
        anchors.fill: parent
        color: Theme.scrimBg

        MouseArea {
            anchors.fill: parent
            onClicked: ShellState.closeWeatherWindow()
        }
    }

    // Separate large detailed weather window
    Surface {
        id: winCard
        elevation: "popover"
        radius: Theme.radiusXl
        border.color: Theme.borderDefault

        anchors.centerIn: parent
        width: Math.min(880, root.width - Theme.spaceXl * 2)
        height: Math.min(640, root.height - Theme.spaceXl * 2)

        opacity: root.isOpen ? 1.0 : 0.0
        scale: root.isOpen ? 1.0 : 0.97

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            anchors.fill: parent
        }

        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Escape) {
                event.accepted = true;
                ShellState.closeWeatherWindow();
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.spaceLg
            spacing: Theme.spaceMd

            // =================================================================
            // Header Bar
            // =================================================================
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spaceSm

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spaceSm

                        Text {
                            text: root.loc
                                ? (root.loc.name + (root.loc.country ? (", " + root.loc.country) : ""))
                                : (WeatherService.locationState === "detecting" ? "Detecting location…" : "No Location Configured")
                            font.family: Theme.fontSans
                            font.pixelSize: Theme.fontXl
                            font.weight: Font.DemiBold
                            color: Theme.textPrimary
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        ActionButton {
                            visible: WeatherService.usingDetectedLocation
                            text: "Save Favorite"
                            icon: "+"
                            compact: true
                            variant: "secondary"
                            onClicked: WeatherService.saveDetectedAsFavorite()
                        }
                    }

                    Text {
                        text: {
                            if (!root.loc) {
                                return WeatherService.locationState === "unavailable"
                                    ? "Automatic detection unavailable — search and add a city on the right"
                                    : "Search and add a city on the right to view weather";
                            }
                            let prefix = WeatherService.usingDetectedLocation ? "Auto-detected · " : "";
                            if (WeatherService.lastUpdatedMs > 0) {
                                return prefix + "Updated " + Qt.formatDateTime(new Date(WeatherService.lastUpdatedMs), "HH:mm")
                                    + (WeatherService.isStale ? " · Outdated (cached)" : "");
                            }
                            return prefix + (WeatherService.loading ? "Updating…" : "Not yet updated");
                        }
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontXs
                        color: WeatherService.isStale ? Theme.warning : Theme.textMuted
                    }
                }

                // Unit switcher (°C / °F)
                Rectangle {
                    implicitWidth: 82
                    implicitHeight: 30
                    radius: Theme.radiusMd
                    color: Theme.surfaceInput
                    border.width: 1
                    border.color: Theme.borderSubtle

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 2
                        spacing: 2

                        ActionButton {
                            Layout.fillWidth: true
                            implicitHeight: 26
                            text: "°C"
                            compact: true
                            variant: WeatherService.unit === "C" ? "primary" : "ghost"
                            onClicked: WeatherService.setUnit("C")
                        }

                        ActionButton {
                            Layout.fillWidth: true
                            implicitHeight: 26
                            text: "°F"
                            compact: true
                            variant: WeatherService.unit === "F" ? "primary" : "ghost"
                            onClicked: WeatherService.setUnit("F")
                        }
                    }
                }

                ActionButton {
                    text: "weather.com"
                    icon: "󰖟"
                    compact: true
                    variant: "secondary"
                    onClicked: Qt.openUrlExternally(WeatherService.weatherComUrl())
                }

                IconButton {
                    icon: "󰑐"
                    iconSize: 15
                    buttonSize: 30
                    disabled: WeatherService.loading
                    onClicked: WeatherService.fetchWeather()
                }

                IconButton {
                    id: closeBtn
                    icon: "󰅖"
                    iconSize: 15
                    buttonSize: 30
                    onClicked: ShellState.closeWeatherWindow()
                }
            }

            // Error banner if offline/error
            Rectangle {
                visible: WeatherService.errorText.length > 0
                Layout.fillWidth: true
                implicitHeight: wErr.implicitHeight + Theme.spaceSm * 2
                radius: Theme.radiusSm
                color: Theme.warningSubtle
                border.width: 1
                border.color: Theme.warningBorder

                Text {
                    id: wErr
                    anchors.fill: parent
                    anchors.margins: Theme.spaceSm
                    text: WeatherService.errorText + (WeatherService.hasData ? " Showing cached data." : "")
                    font.family: Theme.fontSans
                    font.pixelSize: Theme.fontXs
                    color: Theme.warning
                    wrapMode: Text.Wrap
                }
            }

            // =================================================================
            // Main Split: Left (Overview + Time-Series) | Right (Favorites & Search)
            // =================================================================
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Theme.spaceLg

                // Left: Current Overview + Time-Series Table
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Theme.spaceMd

                    // Current Overview Card
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: overviewRow.implicitHeight + Theme.spaceMd * 2
                        radius: Theme.radiusLg
                        color: Theme.surfaceRaised
                        border.width: 1
                        border.color: Theme.borderSubtle

                        RowLayout {
                            id: overviewRow
                            anchors.fill: parent
                            anchors.margins: Theme.spaceMd
                            spacing: Theme.spaceLg

                            RowLayout {
                                spacing: Theme.spaceMd

                                Text {
                                    text: root.cond.icon
                                    font.family: Theme.fontIcon
                                    font.pixelSize: 44
                                    color: Theme.accentHover
                                }

                                ColumnLayout {
                                    spacing: 2

                                    Text {
                                        text: WeatherService.hasData ? WeatherService.formatTemp(WeatherService.currentTempC) : "--"
                                        font.family: Theme.fontSans
                                        font.pixelSize: 34
                                        font.weight: Font.DemiBold
                                        color: Theme.textPrimary
                                    }

                                    Text {
                                        text: WeatherService.hasData ? root.cond.label : "No data"
                                        font.family: Theme.fontSans
                                        font.pixelSize: Theme.fontSm
                                        color: Theme.textSecondary
                                    }
                                }
                            }

                            Separator {
                                vertical: true
                                Layout.fillHeight: true
                            }

                            // Detailed Current Stats Grid
                            GridLayout {
                                Layout.fillWidth: true
                                columns: 2
                                rowSpacing: Theme.spaceXs
                                columnSpacing: Theme.spaceMd

                                StatPill {
                                    label: "Min / Max"
                                    val: WeatherService.hasData
                                        ? (WeatherService.formatTemp(WeatherService.todayMinC) + " / " + WeatherService.formatTemp(WeatherService.todayMaxC))
                                        : "--"
                                }

                                StatPill {
                                    label: "Wind"
                                    val: WeatherService.hasData
                                        ? (WeatherService.formatWind(WeatherService.currentWindKmh) + " " + WeatherService.compassDir(WeatherService.currentWindDir))
                                        : "--"
                                }

                                StatPill {
                                    label: "Rainfall (Now)"
                                    val: WeatherService.hasData ? WeatherService.formatRain(WeatherService.currentRainMm) : "--"
                                }

                                StatPill {
                                    label: "Rainfall (Today)"
                                    val: WeatherService.hasData ? WeatherService.formatRain(WeatherService.todayRainSumMm) : "--"
                                }
                            }
                        }
                    }

                    // Forecast Period Selector
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spaceXs

                        Text {
                            text: "FORECAST"
                            font.family: Theme.fontSans
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            font.letterSpacing: 0.7
                            color: Theme.textMuted
                            Layout.fillWidth: true
                        }

                        ActionButton {
                            text: "24 Hours"
                            compact: true
                            variant: root.seriesMode === "hourly24" ? "primary" : "secondary"
                            onClicked: root.seriesMode = "hourly24"
                        }

                        ActionButton {
                            text: "48 Hours"
                            compact: true
                            variant: root.seriesMode === "hourly48" ? "primary" : "secondary"
                            onClicked: root.seriesMode = "hourly48"
                        }

                        ActionButton {
                            text: "7 Days"
                            compact: true
                            variant: root.seriesMode === "daily7" ? "primary" : "secondary"
                            onClicked: root.seriesMode = "daily7"
                        }
                    }

                    // Time-Series Table
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: Theme.radiusMd
                        color: Theme.surfaceRaised
                        border.width: 1
                        border.color: Theme.borderSubtle
                        clip: true

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 0

                            // Table Header
                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 30
                                color: Theme.surfaceElevated

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: Theme.spaceMd
                                    anchors.rightMargin: Theme.spaceMd
                                    spacing: Theme.spaceSm

                                    Text { text: "Time"; Layout.preferredWidth: 94; font.family: Theme.fontSans; font.pixelSize: Theme.fontXs; font.weight: Font.DemiBold; color: Theme.textMuted }
                                    Text { text: "Condition"; Layout.fillWidth: true; font.family: Theme.fontSans; font.pixelSize: Theme.fontXs; font.weight: Font.DemiBold; color: Theme.textMuted }
                                    Text { text: root.seriesMode === "daily7" ? "Min / Max" : "Temp"; Layout.preferredWidth: 74; horizontalAlignment: Text.AlignRight; font.family: Theme.fontSans; font.pixelSize: Theme.fontXs; font.weight: Font.DemiBold; color: Theme.textMuted }
                                    Text { text: "Wind"; Layout.preferredWidth: 84; horizontalAlignment: Text.AlignRight; font.family: Theme.fontSans; font.pixelSize: Theme.fontXs; font.weight: Font.DemiBold; color: Theme.textMuted }
                                    Text { text: "Rain"; Layout.preferredWidth: 56; horizontalAlignment: Text.AlignRight; font.family: Theme.fontSans; font.pixelSize: Theme.fontXs; font.weight: Font.DemiBold; color: Theme.textMuted }
                                }
                            }

                            Separator { Layout.fillWidth: true }

                            // Scrollable rows
                            ListView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true
                                boundsBehavior: Flickable.StopAtBounds
                                model: root.displayedRows

                                delegate: Rectangle {
                                    required property int index
                                    required property var modelData
                                    readonly property var rowCond: WeatherService.wmoInfo(modelData.code)

                                    width: ListView.view.width
                                    height: 36
                                    color: index % 2 === 0 ? "transparent" : Theme.subtleBg

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: Theme.spaceMd
                                        anchors.rightMargin: Theme.spaceMd
                                        spacing: Theme.spaceSm

                                        Text {
                                            Layout.preferredWidth: 94
                                            text: modelData.label
                                            font.family: Theme.fontSans
                                            font.pixelSize: Theme.fontXs
                                            font.weight: Font.Medium
                                            color: Theme.textPrimary
                                            elide: Text.ElideRight
                                        }

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 6

                                            Text {
                                                text: rowCond.icon
                                                font.family: Theme.fontIcon
                                                font.pixelSize: 14
                                                color: Theme.accentHover
                                            }

                                            Text {
                                                text: rowCond.label
                                                font.family: Theme.fontSans
                                                font.pixelSize: Theme.fontXs
                                                color: Theme.textSecondary
                                                elide: Text.ElideRight
                                                Layout.fillWidth: true
                                            }
                                        }

                                        Text {
                                            Layout.preferredWidth: 74
                                            horizontalAlignment: Text.AlignRight
                                            text: root.seriesMode === "daily7"
                                                ? (WeatherService.formatTemp(modelData.minC) + " / " + WeatherService.formatTemp(modelData.maxC))
                                                : WeatherService.formatTemp(modelData.tempC)
                                            font.family: Theme.fontMono
                                            font.pixelSize: Theme.fontXs
                                            font.weight: Font.DemiBold
                                            color: Theme.textPrimary
                                        }

                                        Text {
                                            Layout.preferredWidth: 84
                                            horizontalAlignment: Text.AlignRight
                                            text: WeatherService.formatWind(modelData.windKmh) + " " + WeatherService.compassDir(modelData.windDir)
                                            font.family: Theme.fontSans
                                            font.pixelSize: Theme.fontXs
                                            color: Theme.textSecondary
                                        }

                                        Text {
                                            Layout.preferredWidth: 56
                                            horizontalAlignment: Text.AlignRight
                                            text: WeatherService.formatRain(modelData.rainMm)
                                            font.family: Theme.fontMono
                                            font.pixelSize: Theme.fontXs
                                            color: modelData.rainMm > 0 ? Theme.accentHover : Theme.textMuted
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Separator {
                    vertical: true
                    Layout.fillHeight: true
                }

                // =============================================================
                // Right Sidebar: Favorites & Location Search
                // =============================================================
                ColumnLayout {
                    Layout.preferredWidth: 230
                    Layout.fillHeight: true
                    spacing: Theme.spaceSm

                    Text {
                        text: "LOCATIONS"
                        font.family: Theme.fontSans
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        font.letterSpacing: 0.7
                        color: Theme.textMuted
                    }

                    // Search bar (auto-searches after 500ms debounce, Enter triggers immediately)
                    Timer {
                        id: searchDebounce
                        interval: 500
                        repeat: false
                        onTriggered: WeatherService.searchLocations(locSearchInput.text)
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spaceXs

                        TextFieldBox {
                            id: locSearchInput
                            Layout.fillWidth: true
                            implicitHeight: 34
                            leadingIcon: "󰍉"
                            placeholderText: "Add city…"
                            onTextChanged: {
                                let trimmed = text.trim();
                                if (trimmed.length === 0) {
                                    searchDebounce.stop();
                                    WeatherService.clearSearch();
                                } else {
                                    searchDebounce.restart();
                                }
                            }
                            onAccepted: {
                                searchDebounce.stop();
                                WeatherService.searchLocations(locSearchInput.text);
                            }
                        }

                        IconButton {
                            icon: "󰁔"
                            iconSize: 14
                            buttonSize: 34
                            disabled: WeatherService.searching || locSearchInput.text.trim().length < 2
                            onClicked: {
                                searchDebounce.stop();
                                WeatherService.searchLocations(locSearchInput.text);
                            }
                        }
                    }

                    // Search status / results
                    Text {
                        visible: WeatherService.searching || WeatherService.searchMessage.length > 0
                        Layout.fillWidth: true
                        text: WeatherService.searching ? "Searching…" : WeatherService.searchMessage
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fontXs
                        color: Theme.textMuted
                        wrapMode: Text.Wrap
                    }

                    ColumnLayout {
                        visible: WeatherService.searchResults.length > 0
                        Layout.fillWidth: true
                        spacing: 3

                        Repeater {
                            model: WeatherService.searchResults

                            delegate: Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                implicitHeight: 34
                                radius: Theme.radiusSm
                                color: Theme.surfaceElevated
                                border.width: 1
                                border.color: Theme.borderSubtle

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: Theme.spaceSm
                                    anchors.rightMargin: Theme.spaceXs
                                    spacing: 4

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.name + (modelData.admin1 ? (", " + modelData.admin1) : "") + (modelData.country ? (" · " + modelData.country) : "")
                                        font.family: Theme.fontSans
                                        font.pixelSize: Theme.fontXs
                                        color: Theme.textPrimary
                                        elide: Text.ElideRight
                                    }

                                    IconButton {
                                        icon: "+"
                                        iconSize: 14
                                        buttonSize: 24
                                        onClicked: {
                                            WeatherService.addFavorite(modelData);
                                            locSearchInput.text = "";
                                            WeatherService.searchResults = [];
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Separator { Layout.fillWidth: true }

                    Text {
                        text: "FAVORITES"
                        font.family: Theme.fontSans
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        font.letterSpacing: 0.7
                        color: Theme.textMuted
                    }

                    // Favorite locations list
                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 4
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        model: WeatherService.favorites

                        delegate: Rectangle {
                            id: favRow
                            required property int index
                            required property var modelData
                            readonly property bool selected: WeatherService.selectedIndex === index

                            activeFocusOnTab: true
                            width: ListView.view.width
                            height: 40
                            radius: Theme.radiusMd
                            color: selected ? Theme.accentSubtle : (favMouse.containsMouse || activeFocus ? Theme.hoverBg : "transparent")
                            border.width: activeFocus ? 2 : (selected ? 1 : 0)
                            border.color: activeFocus ? Theme.accentHover : Theme.accentBorder

                            Keys.onPressed: function (event) {
                                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                                    event.accepted = true;
                                    WeatherService.selectLocation(favRow.index);
                                }
                            }

                            MouseArea {
                                id: favMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: WeatherService.selectLocation(favRow.index)
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.spaceSm
                                anchors.rightMargin: Theme.spaceXs
                                spacing: Theme.spaceXs

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0

                                    Text {
                                        text: modelData.name
                                        font.family: Theme.fontSans
                                        font.pixelSize: Theme.fontSm
                                        font.weight: favRow.selected ? Font.DemiBold : Font.Normal
                                        color: Theme.textPrimary
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        visible: (modelData.country || "").length > 0
                                        text: modelData.country
                                        font.family: Theme.fontSans
                                        font.pixelSize: 10
                                        color: Theme.textMuted
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }

                                IconButton {
                                    visible: WeatherService.favorites.length > 0
                                    icon: "󰅖"
                                    iconSize: 11
                                    buttonSize: 22
                                    dangerHover: true
                                    onClicked: WeatherService.removeFavorite(favRow.index)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    component StatPill: ColumnLayout {
        required property string label
        required property string val
        spacing: 1

        Text {
            text: label
            font.family: Theme.fontSans
            font.pixelSize: 10
            color: Theme.textMuted
        }

        Text {
            text: val
            font.family: Theme.fontSans
            font.pixelSize: Theme.fontSm
            font.weight: Font.Medium
            color: Theme.textPrimary
        }
    }
}
