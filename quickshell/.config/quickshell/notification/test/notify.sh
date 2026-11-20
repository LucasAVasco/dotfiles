#!/bin/bash
#
# Comprehensive notification test suite for Quickshell.
# Usage:
#   ./notify.sh list
#   ./notify.sh all
#   ./notify.sh <scenario> [scenario...]

set -e

usage() {
    cat <<EOF
Quickshell Notification Test Utility

Usage:
  $0 list                     List all available test scenarios
  $0 all                      Run the complete test suite
  $0 <scenario> [...]         Run one or more specific scenarios

Scenarios:
  urgencies       Low, Normal, and Critical urgency notifications
  long-content    Long title, long body, and multiline content
  categories      Notifications with Freedesktop categories (im, email, device, network, transfer)
  icons-images    Notifications with app icons and image hints
  actions         Notifications with multiple action buttons
  inline-reply    Notification with inline-reply support (via gdbus)
  timeouts        Short expiration timeout vs persistent (no expiration)
  replace         Single notification replacement using replacement ID
  replace-multi   Multiple sequential replacements updating content and urgency
  repeated        Repeated notifications from the same application
  unicode         Special characters, emoji, markup, and Unicode text
  hints           Various Freedesktop hint combinations (category, desktop-entry, transient)
  dismiss         Send a notification then dismiss all via Quickshell IPC
EOF
}

scenario_urgencies() {
    echo "[urgencies] Sending Low, Normal, and Critical notifications..."
    notify-send -u low -a "Background Sync" -i "emblem-synchronizing" \
        "Low Priority Sync" "Workspace metadata synchronized quietly in the background."
    sleep 0.3
    notify-send -u normal -a "Calendar" -i "office-calendar" \
        "Normal Reminder" "Team standup starts in 10 minutes."
    sleep 0.3
    notify-send -u critical -a "System Guard" -i "dialog-warning" \
        "Critical Alert" "Disk usage on / has exceeded 95%. Immediate attention required."
}

scenario_long_content() {
    echo "[long-content] Sending long title, long body, and multiline notifications..."
    notify-send -u normal -a "Build System" -i "utilities-terminal" \
        "Very Long Notification Title That Should Wrap Gracefully Without Breaking Card Geometry Or Clipping Layout" \
        "This is a very long single-paragraph body designed to test line wrapping, truncation in toast view, and full scrollable readability inside the notification details window when clicked."
    sleep 0.3
    notify-send -u low -a "Log Watcher" -i "text-x-generic" \
        "Multiline Output" \
"Line 1: Starting verification job
Line 2: Checking configuration syntax
Line 3: All 14 modules loaded cleanly
Line 4: NetworkManager connected (eno1)
Line 5: PipeWire audio sinks synchronized
Line 6: UPower profiles initialized
Line 7: Completed in 0.42s"
}

scenario_categories() {
    echo "[categories] Sending categorized notifications..."
    notify-send -a "Element" -c "im.received" -i "mail-message-new" \
        "New Direct Message" "Alex: Are we still on for the design review?"
    sleep 0.25
    notify-send -a "Thunderbird" -c "email.arrived" -i "mail-unread" \
        "New Email" "Invoice #4821 has been processed."
    sleep 0.25
    notify-send -a "USB Manager" -c "device.added" -i "drive-removable-media" \
        "Device Connected" "External NVMe drive mounted at /mnt/backup."
    sleep 0.25
    notify-send -a "NetworkManager" -c "network.connected" -i "network-wired" \
        "Network Connected" "Wired connection 1 is now active."
    sleep 0.25
    notify-send -a "Browser" -c "transfer.complete" -i "folder-download" \
        "Download Complete" "archlinux-2026.11.iso (1.1 GB) finished downloading."
    sleep 0.25
    notify-send -a "Custom Tool" -c "custom.unknown.category" \
        "Unknown Category Fallback" "Verifies graceful fallback for unrecognized category hints."
}

scenario_icons_images() {
    echo "[icons-images] Sending notifications with icons and image preview..."
    local sample_img="$HOME/.local/share/custom_desktop/wallpaper/lock.jpg"
    if [[ -f "$sample_img" ]]; then
        notify-send -a "Gallery" -i "image-x-generic" -h "string:image-path:$sample_img" \
            "Image Preview Notification" "Includes a rounded preview thumbnail and full view in details."
    else
        notify-send -a "Gallery" -i "image-x-generic" \
            "Icon Notification" "No sample lock.jpg found; showing app icon cleanly."
    fi
}

scenario_actions() {
    echo "[actions] Sending notification with multiple action buttons..."
    notify-send -a "Update Manager" -i "system-software-update" \
        -A "update=Install Now" \
        -A "changelog=View Changelog" \
        -A "later=Remind Later" \
        "System Updates Available" "12 packages are ready to install, including kernel 6.18." &
}

scenario_inline_reply() {
    echo "[inline-reply] Sending notification with inline reply via gdbus..."
    gdbus call --session \
        --dest org.freedesktop.Notifications \
        --object-path /org/freedesktop/Notifications \
        --method org.freedesktop.Notifications.Notify \
        "Chat App" 0 "mail-message-new" "New Message from Sam" \
        "Hey! Can you test the inline reply box right inside this notification card?" \
        "['inline-reply', 'Reply']" \
        "{'urgency': <byte 1>, 'category': <'im.received'>}" 15000 >/dev/null
}

scenario_timeouts() {
    echo "[timeouts] Sending short-timeout (3s) and persistent (0ms) notifications..."
    notify-send -t 3000 -a "Timer" -i "alarm-symbolic" \
        "Short Timeout (3s)" "This toast should auto-dismiss quickly while remaining in the center."
    sleep 0.3
    notify-send -t 0 -a "Persistent Notice" -i "dialog-information" \
        "No Expiration" "Sent with timeout=0 (persistent)."
}

scenario_replace() {
    echo "[replace] Sending notification then replacing it by ID..."
    local id
    id=$(notify-send -p -a "Downloader" -c "transfer" -i "folder-download" \
        "Downloading archive.tar.gz" "Progress: 25% (12 MB/s)")
    sleep 1.2
    notify-send -r "$id" -a "Downloader" -c "transfer.complete" -i "folder-download" \
        "Download Complete (Replaced ID $id)" "Progress: 100% — archive.tar.gz verified."
}

scenario_replace_multi() {
    echo "[replace-multi] Replacing a single notification 3 times across urgencies..."
    local id
    id=$(notify-send -p -u low -a "Deploy Pipeline" -i "system-run" \
        "Deployment Step 1/3" "Building container image…")
    sleep 1.0
    notify-send -r "$id" -u normal -a "Deploy Pipeline" -i "system-run" \
        "Deployment Step 2/3" "Running integration tests…"
    sleep 1.0
    notify-send -r "$id" -u critical -a "Deploy Pipeline" -i "dialog-error" \
        "Deployment Failed (Step 3/3)" "Health check failed on production-east-1 (updated ID $id)."
}

scenario_repeated() {
    echo "[repeated] Sending repeated notifications from the same app..."
    for i in 1 2 3; do
        notify-send -a "GitHub" -c "im.received" -i "dialog-information" \
            "PR #10$i Approved" "Reviewer approved your pull request #$((100 + i))."
        sleep 0.2
    done
}

scenario_unicode() {
    echo "[unicode] Sending Unicode, emoji, and rich markup..."
    notify-send -a "Café & 東京" -i "dialog-information" \
        "Unicode & Markup: 日本語 · Português · 🚀" \
        "Supports <b>bold</b>, <i>italic</i>, <u>underline</u>, and links like <a href=\"https://quickshell.org\">quickshell.org</a> — áéíóú çñü €£¥."
}

scenario_hints() {
    echo "[hints] Sending notification with combined Freedesktop hints..."
    notify-send -a "Music Player" -c "x-gnome.music" \
        -h "string:desktop-entry:org.gnome.Music" \
        -h "int:value:75" \
        "Now Playing" "Midnight City — M83 (75%)"
}

scenario_dismiss() {
    echo "[dismiss] Sending notification then dismissing all via IPC..."
    notify-send -a "Dismiss Test" "Temporary Notification" "Will be cleared via quickshell ipc."
    sleep 1.0
    quickshell ipc call notification dismissAll
}

if [[ $# -eq 0 ]]; then
    usage
    exit 0
fi

for arg in "$@"; do
    case "$arg" in
        -h|--help|help|list)
            usage
            exit 0
            ;;
        all)
            scenario_urgencies; sleep 0.5
            scenario_long_content; sleep 0.5
            scenario_categories; sleep 0.5
            scenario_icons_images; sleep 0.5
            scenario_actions; sleep 0.5
            scenario_inline_reply; sleep 0.5
            scenario_timeouts; sleep 0.5
            scenario_replace; sleep 0.5
            scenario_replace_multi; sleep 0.5
            scenario_repeated; sleep 0.5
            scenario_unicode; sleep 0.5
            scenario_hints
            echo "All scenarios executed."
            ;;
        urgencies) scenario_urgencies ;;
        long-content) scenario_long_content ;;
        categories) scenario_categories ;;
        icons-images) scenario_icons_images ;;
        actions) scenario_actions ;;
        inline-reply) scenario_inline_reply ;;
        timeouts) scenario_timeouts ;;
        replace) scenario_replace ;;
        replace-multi) scenario_replace_multi ;;
        repeated) scenario_repeated ;;
        unicode) scenario_unicode ;;
        hints) scenario_hints ;;
        dismiss) scenario_dismiss ;;
        *)
            echo "Unknown scenario: $arg" >&2
            usage >&2
            exit 1
            ;;
    esac
done
