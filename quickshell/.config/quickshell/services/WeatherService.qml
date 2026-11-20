pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string _stateDir: Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")
    readonly property string _cacheDir: Quickshell.env("XDG_CACHE_HOME") || (Quickshell.env("HOME") + "/.cache")
    readonly property string settingsPath: _stateDir + "/quickshell/weather_settings.json"
    readonly property string cachePath: _cacheDir + "/quickshell/weather_cache.json"

    // Persisted user preferences (no hardcoded default city)
    property string unit: "C" // "C" | "F"
    property var favorites: []
    property int selectedIndex: -1

    // Resolved detected location (kept separate from user favorites)
    property var _resolvedDetectedLocation: null

    // Current weather data (stored internally in Celsius / km/h / mm)
    property bool loading: false
    property bool hasData: false
    property bool isStale: false
    property double lastUpdatedMs: 0
    property string errorText: ""

    property real currentTempC: 0
    property int currentCode: 0
    property real currentWindKmh: 0
    property real currentWindDir: 0
    property real currentRainMm: 0
    property real todayMinC: 0
    property real todayMaxC: 0
    property real todayRainSumMm: 0

    // Time-series arrays
    property var hourlySeries: []
    property var dailySeries: []

    // Location search state
    property bool searching: false
    property var searchResults: []
    property string searchMessage: ""
    property int _searchSeq: 0

    // Cache map: "lat,lon" -> { updatedMs, data }
    property var _cacheMap: ({})

    readonly property bool hasFavorites: favorites && favorites.length > 0

    readonly property bool usingDetectedLocation: !hasFavorites && _resolvedDetectedLocation !== null

    readonly property var currentLocation: {
        if (hasFavorites) {
            let idx = Math.max(0, Math.min(selectedIndex, favorites.length - 1));
            return favorites[idx];
        }
        return _resolvedDetectedLocation;
    }

    // "favorites" | "detected" | "detecting" | "unavailable" | "empty"
    readonly property string locationState: {
        if (hasFavorites)
            return "favorites";
        if (_resolvedDetectedLocation !== null)
            return "detected";
        if (LocationService.status === "detecting" || resolveCityProc.running)
            return "detecting";
        if (LocationService.status === "unavailable")
            return "unavailable";
        return "empty";
    }

    function locKey(loc) {
        if (!loc || !isFinite(Number(loc.lat)) || !isFinite(Number(loc.lon)))
            return "";
        return Number(loc.lat).toFixed(3) + "," + Number(loc.lon).toFixed(3);
    }

    function formatTemp(tempC) {
        let val = unit === "F" ? (tempC * 9.0 / 5.0 + 32.0) : tempC;
        return Math.round(val) + "°" + unit;
    }

    function formatWind(kmh) {
        if (unit === "F")
            return Math.round(kmh * 0.621371) + " mph";
        return Math.round(kmh) + " km/h";
    }

    function compassDir(deg) {
        let dirs = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"];
        let idx = Math.round(((deg % 360) + 360) % 360 / 45) % 8;
        return dirs[idx];
    }

    function formatRain(mm) {
        return Number(mm || 0).toFixed(1) + " mm";
    }

    function wmoInfo(code) {
        switch (Number(code)) {
        case 0:
            return { label: "Clear sky", icon: "󰖙" };
        case 1:
            return { label: "Mainly clear", icon: "󰖕" };
        case 2:
            return { label: "Partly cloudy", icon: "󰖕" };
        case 3:
            return { label: "Overcast", icon: "󰖐" };
        case 45:
        case 48:
            return { label: "Fog", icon: "󰖑" };
        case 51:
        case 53:
        case 55:
            return { label: "Drizzle", icon: "󰖗" };
        case 56:
        case 57:
            return { label: "Freezing drizzle", icon: "󰙿" };
        case 61:
        case 63:
        case 65:
            return { label: "Rain", icon: "󰖖" };
        case 66:
        case 67:
            return { label: "Freezing rain", icon: "󰙿" };
        case 71:
        case 73:
        case 75:
        case 77:
            return { label: "Snow", icon: "󰖘" };
        case 80:
        case 81:
        case 82:
            return { label: "Rain showers", icon: "󰖖" };
        case 85:
        case 86:
            return { label: "Snow showers", icon: "󰖘" };
        case 95:
        case 96:
        case 99:
            return { label: "Thunderstorm", icon: "󰖓" };
        default:
            return { label: "Unknown", icon: "󰖐" };
        }
    }

    function weatherComUrl() {
        let loc = currentLocation;
        if (!loc || !isFinite(Number(loc.lat)) || !isFinite(Number(loc.lon)))
            return "https://weather.com";
        let lat = Number(loc.lat).toFixed(4);
        let lon = Number(loc.lon).toFixed(4);
        return "https://weather.com/weather/today/l/" + lat + "," + lon;
    }

    function setUnit(newUnit) {
        if (newUnit !== "C" && newUnit !== "F")
            return;
        unit = newUnit;
        saveSettings();
    }

    function selectLocation(index) {
        if (!favorites || favorites.length === 0)
            return;
        selectedIndex = Math.max(0, Math.min(index, favorites.length - 1));
        saveSettings();
        _loadCachedForCurrent();
        fetchWeather();
    }

    function nextLocation() {
        if (!favorites || favorites.length <= 1)
            return;
        selectLocation((selectedIndex + 1) % favorites.length);
    }

    function prevLocation() {
        if (!favorites || favorites.length <= 1)
            return;
        selectLocation((selectedIndex - 1 + favorites.length) % favorites.length);
    }

    function addFavorite(locObj) {
        if (!locObj || !isFinite(Number(locObj.lat)) || !isFinite(Number(locObj.lon)))
            return;
        let key = locKey(locObj);
        let list = favorites ? [...favorites] : [];
        let existingIdx = list.findIndex(item => locKey(item) === key);
        if (existingIdx >= 0) {
            selectLocation(existingIdx);
            return;
        }
        list.push({
            name: String(locObj.name || "Unknown"),
            admin1: String(locObj.admin1 || ""),
            country: String(locObj.country || ""),
            lat: Number(locObj.lat),
            lon: Number(locObj.lon)
        });
        favorites = list;
        selectedIndex = list.length - 1;
        saveSettings();
        _loadCachedForCurrent();
        fetchWeather();
    }

    function saveDetectedAsFavorite() {
        if (usingDetectedLocation && _resolvedDetectedLocation) {
            addFavorite(_resolvedDetectedLocation);
        }
    }

    function removeFavorite(index) {
        if (!favorites || index < 0 || index >= favorites.length)
            return;
        let list = [...favorites];
        list.splice(index, 1);
        favorites = list;

        if (list.length === 0) {
            selectedIndex = -1;
            saveSettings();
            hasData = false;
            hourlySeries = [];
            dailySeries = [];
            // Fall back to automatic detection (does not re-insert into favorites)
            LocationService.ensureLocation();
            return;
        }

        if (selectedIndex >= list.length)
            selectedIndex = list.length - 1;
        saveSettings();
        _loadCachedForCurrent();
        fetchWeather();
    }

    function clearSearch() {
        _searchSeq += 1;
        searching = false;
        searchResults = [];
        searchMessage = "";
        if (geocodeProc.running)
            geocodeProc.running = false;
    }

    function searchLocations(query) {
        let q = String(query || "").trim();
        if (q.length === 0) {
            clearSearch();
            return;
        }
        if (q.length < 2) {
            _searchSeq += 1;
            searching = false;
            searchResults = [];
            searchMessage = "Enter at least 2 characters.";
            return;
        }

        let seq = ++_searchSeq;
        searchMessage = "";
        searching = true;

        if (geocodeProc.running)
            geocodeProc.running = false;

        let encoded = encodeURIComponent(q);
        geocodeProc.requestSeq = seq;
        geocodeProc.command = [
            "curl", "-sfS", "--max-time", "8",
            "https://geocoding-api.open-meteo.com/v1/search?name=" + encoded + "&count=6&language=en&format=json"
        ];
        geocodeProc.running = true;
    }

    function fetchWeather() {
        let loc = currentLocation;
        if (!loc || !isFinite(Number(loc.lat)) || !isFinite(Number(loc.lon)))
            return;
        if (weatherProc.running)
            return;

        loading = true;
        errorText = "";

        let lat = Number(loc.lat).toFixed(4);
        let lon = Number(loc.lon).toFixed(4);
        let url = "https://api.open-meteo.com/v1/forecast"
            + "?latitude=" + lat
            + "&longitude=" + lon
            + "&current=temperature_2m,weather_code,wind_speed_10m,wind_direction_10m,precipitation"
            + "&hourly=temperature_2m,weather_code,wind_speed_10m,wind_direction_10m,precipitation"
            + "&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,wind_speed_10m_max,wind_direction_10m_dominant"
            + "&forecast_days=7&timezone=auto";

        weatherProc.targetKey = locKey(loc);
        weatherProc.command = ["curl", "-sfS", "--max-time", "10", url];
        weatherProc.running = true;
    }

    function _handleDetectedLocation(loc) {
        if (!loc || hasFavorites)
            return;
        if (loc.hasCoords && isFinite(Number(loc.lat)) && isFinite(Number(loc.lon))) {
            _resolvedDetectedLocation = {
                name: loc.name,
                admin1: loc.admin1 || "",
                country: loc.country || "",
                lat: Number(loc.lat),
                lon: Number(loc.lon)
            };
            _loadCachedForCurrent();
            fetchWeather();
        } else if (loc.name && loc.name.length > 0 && !resolveCityProc.running) {
            // Fallback: geocode detected city + country when provider omitted coordinates
            let q = loc.country ? (loc.name + ", " + loc.country) : loc.name;
            resolveCityProc.detectedFallback = loc;
            resolveCityProc.command = [
                "curl", "-sfS", "--max-time", "8",
                "https://geocoding-api.open-meteo.com/v1/search?name=" + encodeURIComponent(q) + "&count=1&language=en&format=json"
            ];
            resolveCityProc.running = true;
        }
    }

    function _applyForecastJson(data, updatedMs, staleFlag) {
        if (!data || !data.current || !data.daily)
            return false;

        currentTempC = Number(data.current.temperature_2m || 0);
        currentCode = Number(data.current.weather_code || 0);
        currentWindKmh = Number(data.current.wind_speed_10m || 0);
        currentWindDir = Number(data.current.wind_direction_10m || 0);
        currentRainMm = Number(data.current.precipitation || 0);

        let dTimes = data.daily.time || [];
        let dMin = data.daily.temperature_2m_min || [];
        let dMax = data.daily.temperature_2m_max || [];
        let dCode = data.daily.weather_code || [];
        let dRain = data.daily.precipitation_sum || [];
        let dWind = data.daily.wind_speed_10m_max || [];
        let dWindDir = data.daily.wind_direction_10m_dominant || [];

        if (dMin.length > 0)
            todayMinC = Number(dMin[0]);
        if (dMax.length > 0)
            todayMaxC = Number(dMax[0]);
        if (dRain.length > 0)
            todayRainSumMm = Number(dRain[0]);

        let dayMinMap = ({});
        let dayMaxMap = ({});
        let days = [];
        for (let i = 0; i < dTimes.length; i++) {
            let ds = String(dTimes[i]);
            dayMinMap[ds] = Number(dMin[i] || 0);
            dayMaxMap[ds] = Number(dMax[i] || 0);
            let dtObj = new Date(ds + "T12:00:00");
            days.push({
                date: ds,
                label: i === 0 ? "Today" : (i === 1 ? "Tomorrow" : Qt.formatDate(dtObj, "ddd, MMM d")),
                minC: Number(dMin[i] || 0),
                maxC: Number(dMax[i] || 0),
                code: Number(dCode[i] || 0),
                windKmh: Number(dWind[i] || 0),
                windDir: Number(dWindDir[i] || 0),
                rainMm: Number(dRain[i] || 0)
            });
        }
        dailySeries = days;

        let hTimes = (data.hourly && data.hourly.time) ? data.hourly.time : [];
        let hTemp = (data.hourly && data.hourly.temperature_2m) ? data.hourly.temperature_2m : [];
        let hCode = (data.hourly && data.hourly.weather_code) ? data.hourly.weather_code : [];
        let hWind = (data.hourly && data.hourly.wind_speed_10m) ? data.hourly.wind_speed_10m : [];
        let hWindDir = (data.hourly && data.hourly.wind_direction_10m) ? data.hourly.wind_direction_10m : [];
        let hRain = (data.hourly && data.hourly.precipitation) ? data.hourly.precipitation : [];

        let nowIsoPrefix = Qt.formatDateTime(new Date(), "yyyy-MM-ddTHH");
        let startIdx = 0;
        for (let i = 0; i < hTimes.length; i++) {
            if (String(hTimes[i]).slice(0, 13) >= nowIsoPrefix) {
                startIdx = i;
                break;
            }
        }

        let hrs = [];
        let endIdx = Math.min(hTimes.length, startIdx + 48);
        for (let i = startIdx; i < endIdx; i++) {
            let ts = String(hTimes[i]);
            let dayKey = ts.slice(0, 10);
            let hhmm = ts.slice(11, 16);
            let dtObj = new Date(ts);
            hrs.push({
                time: ts,
                label: (i === startIdx ? "Now" : Qt.formatDate(dtObj, "ddd ") + hhmm),
                tempC: Number(hTemp[i] || 0),
                minC: dayMinMap[dayKey] !== undefined ? dayMinMap[dayKey] : todayMinC,
                maxC: dayMaxMap[dayKey] !== undefined ? dayMaxMap[dayKey] : todayMaxC,
                code: Number(hCode[i] || 0),
                windKmh: Number(hWind[i] || 0),
                windDir: Number(hWindDir[i] || 0),
                rainMm: Number(hRain[i] || 0)
            });
        }
        hourlySeries = hrs;

        lastUpdatedMs = updatedMs;
        isStale = staleFlag || (Date.now() - updatedMs > 45 * 60 * 1000);
        hasData = true;
        return true;
    }

    function _loadCachedForCurrent() {
        let key = locKey(currentLocation);
        if (key.length === 0) {
            hasData = false;
            isStale = false;
            return;
        }
        let entry = _cacheMap[key];
        if (entry && entry.data) {
            _applyForecastJson(entry.data, entry.updatedMs || 0, true);
        } else {
            hasData = false;
            isStale = false;
        }
    }

    function saveSettings() {
        let payload = JSON.stringify({
            unit: unit,
            favorites: favorites,
            selectedIndex: selectedIndex
        });
        saveSettingsProc.command = [
            "python3", "-c",
            "import os,sys; p=sys.argv[1]; os.makedirs(os.path.dirname(p), exist_ok=True); t=p+'.tmp'; open(t,'w').write(sys.argv[2]); os.replace(t,p)",
            settingsPath,
            payload
        ];
        saveSettingsProc.running = true;
    }

    function saveCache() {
        let payload = JSON.stringify(_cacheMap);
        saveCacheProc.command = [
            "python3", "-c",
            "import os,sys; p=sys.argv[1]; os.makedirs(os.path.dirname(p), exist_ok=True); t=p+'.tmp'; open(t,'w').write(sys.argv[2]); os.replace(t,p)",
            cachePath,
            payload
        ];
        saveCacheProc.running = true;
    }

    Connections {
        target: LocationService

        function onLocationReady(loc) {
            root._handleDetectedLocation(loc);
        }
    }

    // Load persisted settings on startup (preserves existing user favorites; never overwrites)
    Process {
        id: loadSettingsProc
        command: ["python3", "-c", "import os,sys; p=sys.argv[1]; print(open(p).read()) if os.path.exists(p) else print('')", root.settingsPath]
        property string _out: ""
        stdout: StdioCollector {
            onStreamFinished: loadSettingsProc._out = this.text
        }
        onExited: function () {
            let raw = loadSettingsProc._out.trim();
            if (raw.length > 0) {
                try {
                    let parsed = JSON.parse(raw);
                    if (parsed.unit === "C" || parsed.unit === "F")
                        root.unit = parsed.unit;
                    if (Array.isArray(parsed.favorites)) {
                        root.favorites = parsed.favorites;
                        if (parsed.favorites.length > 0) {
                            let idx = typeof parsed.selectedIndex === "number" ? parsed.selectedIndex : 0;
                            root.selectedIndex = Math.max(0, Math.min(idx, parsed.favorites.length - 1));
                        } else {
                            root.selectedIndex = -1;
                        }
                    }
                } catch (e) {}
            }
            loadSettingsProc._out = "";
            loadCacheProc.running = true;
        }
    }

    // Load cached forecasts, then fetch for favorites OR trigger automatic location detection
    Process {
        id: loadCacheProc
        command: ["python3", "-c", "import os,sys; p=sys.argv[1]; print(open(p).read()) if os.path.exists(p) else print('')", root.cachePath]
        property string _out: ""
        stdout: StdioCollector {
            onStreamFinished: loadCacheProc._out = this.text
        }
        onExited: function () {
            let raw = loadCacheProc._out.trim();
            if (raw.length > 0) {
                try {
                    let parsed = JSON.parse(raw);
                    if (parsed && typeof parsed === "object")
                        root._cacheMap = parsed;
                } catch (e) {}
            }
            loadCacheProc._out = "";

            if (root.hasFavorites) {
                root._loadCachedForCurrent();
                root.fetchWeather();
            } else {
                // No user favorites configured -> detect approximate location asynchronously
                LocationService.ensureLocation();
            }
        }
    }

    Process { id: saveSettingsProc }
    Process { id: saveCacheProc }

    // City-only fallback geocoding when IP provider omits coordinates
    Process {
        id: resolveCityProc
        property var detectedFallback: null
        property string _out: ""
        stdout: StdioCollector {
            onStreamFinished: resolveCityProc._out = this.text
        }
        onExited: function (exitCode) {
            let raw = resolveCityProc._out.trim();
            resolveCityProc._out = "";
            if (exitCode === 0 && raw.length > 0 && !root.hasFavorites) {
                try {
                    let parsed = JSON.parse(raw);
                    let res = parsed && parsed.results && parsed.results.length > 0 ? parsed.results[0] : null;
                    if (res && isFinite(Number(res.latitude)) && isFinite(Number(res.longitude))) {
                        root._resolvedDetectedLocation = {
                            name: res.name || (resolveCityProc.detectedFallback ? resolveCityProc.detectedFallback.name : "Detected Location"),
                            admin1: res.admin1 || "",
                            country: res.country || "",
                            lat: Number(res.latitude),
                            lon: Number(res.longitude)
                        };
                        root._loadCachedForCurrent();
                        root.fetchWeather();
                    }
                } catch (e) {}
            }
        }
    }

    // Fetch forecast from Open-Meteo
    Process {
        id: weatherProc
        property string targetKey: ""
        property string _out: ""
        stdout: StdioCollector {
            onStreamFinished: weatherProc._out = this.text
        }
        onExited: function (exitCode) {
            root.loading = false;
            if (exitCode === 0 && weatherProc._out.trim().length > 0) {
                try {
                    let parsed = JSON.parse(weatherProc._out.trim());
                    let nowMs = Date.now();
                    if (root._applyForecastJson(parsed, nowMs, false)) {
                        let copy = root._cacheMap;
                        copy[weatherProc.targetKey] = { updatedMs: nowMs, data: parsed };
                        root._cacheMap = copy;
                        root.saveCache();
                        root.errorText = "";
                    } else {
                        root.errorText = "Unexpected weather data format.";
                        root.isStale = root.hasData;
                    }
                } catch (e) {
                    root.errorText = "Failed to parse weather data.";
                    root.isStale = root.hasData;
                }
            } else {
                root.errorText = "Unable to reach weather service (offline).";
                if (root.hasData)
                    root.isStale = true;
            }
            weatherProc._out = "";
        }
    }

    // Geocoding search (guards against out-of-order responses via requestSeq)
    Process {
        id: geocodeProc
        property int requestSeq: 0
        property string _out: ""
        stdout: StdioCollector {
            onStreamFinished: geocodeProc._out = this.text
        }
        onExited: function (exitCode) {
            if (geocodeProc.requestSeq !== root._searchSeq) {
                geocodeProc._out = "";
                return;
            }
            root.searching = false;
            if (exitCode === 0 && geocodeProc._out.trim().length > 0) {
                try {
                    let parsed = JSON.parse(geocodeProc._out.trim());
                    let results = parsed.results || [];
                    if (results.length === 0) {
                        root.searchResults = [];
                        root.searchMessage = "No matching locations found.";
                    } else {
                        root.searchResults = results.map(r => ({
                            name: r.name || "",
                            admin1: r.admin1 || "",
                            country: r.country || "",
                            lat: r.latitude,
                            lon: r.longitude
                        }));
                        root.searchMessage = "";
                    }
                } catch (e) {
                    root.searchMessage = "Failed to parse search results.";
                }
            } else {
                root.searchMessage = "Location search failed (check internet connection).";
            }
            geocodeProc._out = "";
        }
    }

    // Auto-refresh every 30 minutes
    Timer {
        interval: 30 * 60 * 1000
        repeat: true
        running: true
        onTriggered: {
            if (root.currentLocation !== null)
                root.fetchWeather();
            else if (!root.hasFavorites)
                LocationService.ensureLocation();
        }
    }

    Component.onCompleted: {
        loadSettingsProc.running = true;
    }
}
