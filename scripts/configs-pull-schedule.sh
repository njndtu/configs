#!/usr/bin/env bash
# Run configs-pull.applescript every day via launchd.
#
# launchd rather than cron: cron skips a run that falls while the Mac is
# asleep, launchd runs it once on wake. The scheduled run is silent unless
# GitHub has new commits, in which case it shows the pull dialog.
#
# Usage: ./scripts/configs-pull-schedule.sh [HH:MM]   (default 09:00)
#        ./scripts/configs-pull-schedule.sh --remove
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LABEL="com.njndtu.configs-pull"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
DOMAIN="gui/$(id -u)"

launchctl bootout "$DOMAIN/$LABEL" 2>/dev/null || true

if [ "${1:-}" = "--remove" ]; then
  rm -f "$PLIST"
  echo "removed $LABEL"
  exit 0
fi

time="${1:-09:00}"
[[ "$time" =~ ^([01]?[0-9]|2[0-3]):([0-5][0-9])$ ]] || { echo "error: time must be HH:MM" >&2; exit 1; }
hour=$((10#${BASH_REMATCH[1]})); minute=$((10#${BASH_REMATCH[2]}))

mkdir -p "$(dirname "$PLIST")"
cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/bin/osascript</string>
    <string>$REPO_DIR/scripts/configs-pull.applescript</string>
    <string>--scheduled</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key><integer>$hour</integer>
    <key>Minute</key><integer>$minute</integer>
  </dict>
  <key>StandardErrorPath</key><string>/tmp/$LABEL.log</string>
</dict>
</plist>
EOF

launchctl bootstrap "$DOMAIN" "$PLIST"
printf 'scheduled %s daily at %02d:%02d\n' "$LABEL" "$hour" "$minute"
echo "run it now:  launchctl kickstart $DOMAIN/$LABEL"
echo "remove:      $0 --remove"
