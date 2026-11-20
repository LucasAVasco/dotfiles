pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Privacy Notice:
// Automatic IP geolocation sends an HTTPS GET request to an external provider
// (default: https://ipwho.is/, configurable via QUICKSHELL_GEOLOCATION_URL),
// which exposes the user's public IP address to that provider.
// The public IP address is NEVER stored, cached, or logged by this service,
// and no personal or system information is sent in the request.
Singleton {
    id: root

    readonly property string providerUrl: Quickshell.env("QUICKSHELL_GEOLOCATION_URL") || "https://ipwho.is/"
    readonly property string _cacheDir: Quickshell.env("XDG_CACHE_HOME") || (Quickshell.env("HOME") + "/.cache")
    readonly property string cachePath: _cacheDir + "/quickshell/location_cache.json"

    // 24-hour cache TTL and 5-minute failure cooldown (prevents tight retry loops)
    readonly property double cacheTtlMs: 24 * 60 * 60 * 1000
    readonly property double retryCooldownMs: 5 * 60 * 1000

    // "idle" | "detecting" | "detected" | "unavailable"
    property string status: "idle"
    // Normalized location object: { name, admin1, country, lat, lon, hasCoords } or null
    property var detectedLocation: null
    property double detectedAtMs: 0
    property string errorText: ""

    property bool _cacheLoaded: false
    property bool _pendingEnsure: false
    property double _retryAfterMs: 0

    signal locationReady(var location)
    signal detectionFailed(string reason)

    function ensureLocation() {
        if (!_cacheLoaded) {
            _pendingEnsure = true;
            if (!loadCacheProc.running)
                loadCacheProc.running = true;
            return;
        }

        let now = Date.now();
        if (detectedLocation !== null && detectedAtMs > 0) {
            let age = now - detectedAtMs;
            if (age < cacheTtlMs) {
                status = "detected";
                locationReady(detectedLocation);
                return;
            }
            // Cache expired: keep showing cached location without interrupting UI,
            // and refresh asynchronously in the background.
            status = "detected";
            locationReady(detectedLocation);
            _fetchFromProvider(true);
            return;
        }

        _fetchFromProvider(false);
    }

    function _fetchFromProvider(backgroundRefresh) {
        if (fetchProc.running)
            return;

        let now = Date.now();
        if (now < _retryAfterMs) {
            if (!backgroundRefresh && detectedLocation === null) {
                status = "unavailable";
                if (errorText.length === 0)
                    errorText = "Location detection temporarily unavailable.";
                detectionFailed(errorText);
            }
            return;
        }

        // Enforce HTTPS endpoint
        if (!providerUrl.startsWith("https://")) {
            errorText = "Geolocation provider must use HTTPS.";
            if (!backgroundRefresh) {
                status = "unavailable";
                detectionFailed(errorText);
            }
            return;
        }

        if (!backgroundRefresh) {
            status = "detecting";
            errorText = "";
        }

        fetchProc.background = backgroundRefresh;
        fetchProc.command = ["curl", "-sfS", "--max-time", "8", providerUrl];
        fetchProc.running = true;
    }

    function _parseProviderResponse(rawText) {
        let parsed = JSON.parse(rawText);
        if (!parsed || typeof parsed !== "object")
            return null;

        // ipwho.is returns { success: false, message: "..." } on error/rate-limit
        if (parsed.success === false || parsed.error === true)
            return null;

        let city = String(parsed.city || "").trim();
        let region = String(parsed.region || parsed.regionName || "").trim();
        let country = String(parsed.country || parsed.country_name || "").trim();

        let lat = Number(parsed.latitude !== undefined ? parsed.latitude : parsed.lat);
        let lon = Number(parsed.longitude !== undefined ? parsed.longitude : parsed.lon);
        let hasCoords = isFinite(lat) && isFinite(lon) && Math.abs(lat) <= 90 && Math.abs(lon) <= 180
            && !(lat === 0 && lon === 0);

        // Must have either valid coordinates or a city name
        if (!hasCoords && city.length === 0)
            return null;

        return {
            name: city.length > 0 ? city : (region.length > 0 ? region : (country.length > 0 ? country : "Detected Location")),
            admin1: region,
            country: country,
            lat: hasCoords ? lat : NaN,
            lon: hasCoords ? lon : NaN,
            hasCoords: hasCoords
        };
    }

    function _saveCache(locObj, timestampMs) {
        if (!locObj)
            return;
        // Explicitly store ONLY location metadata (never IP address)
        let payload = JSON.stringify({
            name: locObj.name,
            admin1: locObj.admin1 || "",
            country: locObj.country || "",
            lat: locObj.hasCoords ? locObj.lat : null,
            lon: locObj.hasCoords ? locObj.lon : null,
            hasCoords: !!locObj.hasCoords,
            detectedAtMs: timestampMs
        });
        saveCacheProc.command = [
            "python3", "-c",
            "import os,sys; p=sys.argv[1]; os.makedirs(os.path.dirname(p), exist_ok=True); t=p+'.tmp'; open(t,'w').write(sys.argv[2]); os.replace(t,p)",
            cachePath,
            payload
        ];
        saveCacheProc.running = true;
    }

    Process {
        id: loadCacheProc
        command: ["python3", "-c", "import os,sys; p=sys.argv[1]; print(open(p).read()) if os.path.exists(p) else print('')", root.cachePath]
        property string _out: ""

        stdout: StdioCollector {
            onStreamFinished: loadCacheProc._out = this.text
        }

        onExited: function () {
            let raw = loadCacheProc._out.trim();
            loadCacheProc._out = "";
            if (raw.length > 0) {
                try {
                    let parsed = JSON.parse(raw);
                    if (parsed && typeof parsed === "object" && typeof parsed.detectedAtMs === "number") {
                        let lat = Number(parsed.lat);
                        let lon = Number(parsed.lon);
                        let hasCoords = !!parsed.hasCoords && isFinite(lat) && isFinite(lon);
                        let name = String(parsed.name || "").trim();
                        if (hasCoords || name.length > 0) {
                            root.detectedLocation = {
                                name: name || "Detected Location",
                                admin1: String(parsed.admin1 || ""),
                                country: String(parsed.country || ""),
                                lat: hasCoords ? lat : NaN,
                                lon: hasCoords ? lon : NaN,
                                hasCoords: hasCoords
                            };
                            root.detectedAtMs = parsed.detectedAtMs;
                        }
                    }
                } catch (e) {
                    // Ignore corrupted cache cleanly
                }
            }
            root._cacheLoaded = true;
            if (root._pendingEnsure) {
                root._pendingEnsure = false;
                root.ensureLocation();
            }
        }
    }

    Process {
        id: fetchProc
        property bool background: false
        property string _out: ""

        stdout: StdioCollector {
            onStreamFinished: fetchProc._out = this.text
        }

        onExited: function (exitCode) {
            let raw = fetchProc._out.trim();
            fetchProc._out = "";

            if (exitCode === 0 && raw.length > 0) {
                try {
                    let loc = root._parseProviderResponse(raw);
                    if (loc !== null) {
                        let now = Date.now();
                        root.detectedLocation = loc;
                        root.detectedAtMs = now;
                        root.status = "detected";
                        root.errorText = "";
                        root._retryAfterMs = 0;
                        root._saveCache(loc, now);
                        root.locationReady(loc);
                        return;
                    }
                } catch (e) {}
            }

            // Failed or invalid response — apply cooldown so we never retry in a tight loop
            root._retryAfterMs = Date.now() + root.retryCooldownMs;
            root.errorText = "Location detection unavailable.";
            if (!fetchProc.background || root.detectedLocation === null) {
                root.status = "unavailable";
                root.detectionFailed(root.errorText);
            }
        }
    }

    Process {
        id: saveCacheProc
    }
}
