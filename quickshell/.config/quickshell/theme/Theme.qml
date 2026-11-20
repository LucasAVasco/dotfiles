pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    // =========================================================================
    // Color Palette — GNOME Adwaita Dark inspired
    // =========================================================================

    // Surface elevation levels
    readonly property color surfaceBase: "#1c1c21"
    readonly property color surfaceRaised: "#24242b"
    readonly property color surfaceElevated: "#2d2d36"
    readonly property color surfaceOverlay: "#363640"
    readonly property color surfaceInput: "#18181d"

    // Translucent chrome surfaces
    readonly property color panelBg: Qt.rgba(0.08, 0.08, 0.10, 0.88)
    readonly property color popoverBg: Qt.rgba(0.12, 0.12, 0.15, 0.96)
    readonly property color cardBg: Qt.rgba(0.15, 0.15, 0.19, 0.94)
    readonly property color scrimBg: Qt.rgba(0.0, 0.0, 0.0, 0.48)

    // Interactive state tints
    readonly property color hoverBg: Qt.rgba(1.0, 1.0, 1.0, 0.08)
    readonly property color pressedBg: Qt.rgba(1.0, 1.0, 1.0, 0.14)
    readonly property color subtleBg: Qt.rgba(1.0, 1.0, 1.0, 0.05)

    // Borders & dividers
    readonly property color borderSubtle: Qt.rgba(1.0, 1.0, 1.0, 0.08)
    readonly property color borderDefault: Qt.rgba(1.0, 1.0, 1.0, 0.13)
    readonly property color borderStrong: Qt.rgba(1.0, 1.0, 1.0, 0.22)
    readonly property color separator: Qt.rgba(1.0, 1.0, 1.0, 0.09)

    // Accent — Adwaita Blue
    readonly property color accent: "#3584e4"
    readonly property color accentHover: "#4a93ea"
    readonly property color accentActive: "#2b6fc2"
    readonly property color accentSubtle: Qt.rgba(0.208, 0.518, 0.894, 0.18)
    readonly property color accentBorder: Qt.rgba(0.208, 0.518, 0.894, 0.45)

    // Semantic colors
    readonly property color success: "#33d17a"
    readonly property color successSubtle: Qt.rgba(0.20, 0.82, 0.48, 0.16)
    readonly property color warning: "#f5c211"
    readonly property color warningSubtle: Qt.rgba(0.96, 0.76, 0.07, 0.16)
    readonly property color warningBorder: Qt.rgba(0.96, 0.76, 0.07, 0.42)
    readonly property color danger: "#e01b24"
    readonly property color dangerHover: "#ed333b"
    readonly property color dangerActive: "#c01c28"
    readonly property color dangerSubtle: Qt.rgba(0.878, 0.106, 0.141, 0.16)
    readonly property color dangerBorder: Qt.rgba(0.878, 0.106, 0.141, 0.48)

    // Typography colors
    readonly property color textPrimary: "#f2f2f5"
    readonly property color textSecondary: "#b0b0bc"
    readonly property color textMuted: "#7d7d8a"
    readonly property color textOnAccent: "#ffffff"

    // =========================================================================
    // Typography
    // =========================================================================
    readonly property string fontSans: "Adwaita Sans"
    readonly property string fontMono: "Adwaita Mono"
    readonly property string fontIcon: "JetBrainsMono Nerd Font Propo"

    readonly property int fontXs: 11
    readonly property int fontSm: 12
    readonly property int fontMd: 13
    readonly property int fontLg: 15
    readonly property int fontXl: 18
    readonly property int fontXxl: 24
    readonly property int fontDisplay: 68

    // =========================================================================
    // Spacing & Radii
    // =========================================================================
    readonly property int spaceXxs: 2
    readonly property int spaceXs: 4
    readonly property int spaceSm: 8
    readonly property int spaceMd: 12
    readonly property int spaceLg: 16
    readonly property int spaceXl: 24

    readonly property int radiusXs: 4
    readonly property int radiusSm: 6
    readonly property int radiusMd: 10
    readonly property int radiusLg: 14
    readonly property int radiusXl: 18
    readonly property int radiusPill: 999

    // Panel geometry
    readonly property int topBarHeight: 34

    // =========================================================================
    // Motion & Reduced-Motion Support
    // =========================================================================
    readonly property bool reducedMotion: Quickshell.env("QUICKSHELL_REDUCED_MOTION") === "1"
    readonly property int animFast: reducedMotion ? 0 : 120
    readonly property int animNormal: reducedMotion ? 0 : 180
    readonly property int animSlow: reducedMotion ? 0 : 250
}
