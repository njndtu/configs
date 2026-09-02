#!/usr/bin/env bash
# Point iTerm2 at this repo's iterm2/ folder and save changes automatically.
#
# IMPORTANT: iTerm2 must be QUIT before running this. A running iTerm2 holds its
# preferences in memory and rewrites them on quit, clobbering anything written here.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PREFS_DIR="$REPO_DIR/iterm2"

if pgrep -f 'iTerm.app/Contents/MacOS/iTerm2' >/dev/null; then
  echo "error: iTerm2 is running. Quit it (cmd-Q) and run this from Terminal.app instead." >&2
  exit 1
fi

[ -f "$PREFS_DIR/com.googlecode.iterm2.plist" ] || {
  echo "error: no plist at $PREFS_DIR" >&2; exit 1; }

defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$PREFS_DIR"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
# "Save changes: Automatically"
defaults write com.googlecode.iterm2 NoSyncNeverRemindPrefsChangesLostForFile -bool true
defaults write com.googlecode.iterm2 NoSyncNeverRemindPrefsChangesLostForFile_selection -int 2

echo "Done. Launch iTerm2, then confirm under Settings -> General -> Settings that"
echo "'Load settings from a custom folder or URL' points at:"
echo "  $PREFS_DIR"
echo "and 'Save changes' is set to 'Automatically'."
