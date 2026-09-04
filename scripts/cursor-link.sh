#!/usr/bin/env bash
# Symlink Cursor's user settings at this repo, and install the recorded extensions.
# Safe to re-run. Existing real files are backed up next to themselves as *.bak.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
USER_DIR="$HOME/Library/Application Support/Cursor/User"

[ -d "$USER_DIR" ] || { echo "error: $USER_DIR not found -- is Cursor installed?" >&2; exit 1; }

for f in settings.json keybindings.json; do
  target="$USER_DIR/$f"
  if [ -L "$target" ]; then
    rm "$target"
  elif [ -e "$target" ]; then
    mv "$target" "$target.bak"
    echo "backed up existing $f -> $f.bak"
  fi
  ln -s "$REPO_DIR/cursor/$f" "$target"
  echo "linked $f"
done

if command -v cursor >/dev/null; then
  while read -r ext; do
    [ -n "$ext" ] && cursor --install-extension "$ext" --force
  done < "$REPO_DIR/cursor/extensions.txt"
else
  echo
  echo "note: 'cursor' CLI not on PATH, skipping extensions."
  echo "Install it from Cursor: cmd-shift-P -> \"Shell Command: Install 'cursor' command\","
  echo "then re-run this script."
fi

echo
echo "Not handled automatically (they hold machine- or account-specific values):"
echo "  ~/.cursor/mcp.json        -- start from cursor/mcp.json.example"
echo "  ~/.cursor/cli-config.json -- start from cursor/cli-config.example.json"
