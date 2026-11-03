#!/usr/bin/env bash
# Symlink Obsidian vaults' hotkeys and CSS snippets at this repo, so every
# linked vault shares one set of keybinds and edits land straight in the repo.
#
# Usage: ./scripts/obsidian-link.sh [vault-path ...]
#   With no arguments, links every vault Obsidian knows about
#   (from ~/Library/Application Support/obsidian/obsidian.json).
#
# Safe to re-run. Existing real files/folders are backed up next to themselves
# as *.bak (or *.bak.<timestamp> if a .bak already exists).
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO_DIR/obsidian"
VAULT_LIST="$HOME/Library/Application Support/obsidian/obsidian.json"

vaults=()
if [ $# -gt 0 ]; then
  vaults=("$@")
else
  command -v jq >/dev/null || { echo "error: jq is required to read $VAULT_LIST (or pass vault paths)" >&2; exit 1; }
  [ -f "$VAULT_LIST" ] || { echo "error: $VAULT_LIST not found -- pass vault paths explicitly" >&2; exit 1; }
  while IFS= read -r v; do vaults+=("$v"); done < <(jq -r '.vaults[].path' "$VAULT_LIST")
fi

backup() {
  local target="$1" dest="$1.bak"
  [ -e "$dest" ] && dest="$1.bak.$(date +%Y%m%d%H%M%S)"
  mv "$target" "$dest"
  echo "  backed up $(basename "$target") -> $(basename "$dest")"
}

link() {
  local src="$1" target="$2"
  if [ -L "$target" ]; then
    [ "$(readlink "$target")" = "$src" ] && { echo "  ok     $(basename "$target")"; return; }
    rm "$target"
  elif [ -e "$target" ]; then
    backup "$target"
  fi
  ln -s "$src" "$target"
  echo "  linked $(basename "$target")"
}

for v in "${vaults[@]}"; do
  cfg="$v/.obsidian"
  if [ ! -d "$cfg" ]; then
    echo "skip: $v (no .obsidian folder -- open it in Obsidian once first)" >&2
    continue
  fi
  echo "$v"
  link "$SRC/hotkeys.json" "$cfg/hotkeys.json"
  link "$SRC/snippets"     "$cfg/snippets"
done

echo
if pgrep -xq Obsidian; then
  echo "Obsidian is running: reload each vault (cmd-P -> \"Reload app without saving\")"
  echo "so it picks up the linked hotkeys."
fi
echo "Turn snippets on per vault in Settings -> Appearance -> CSS snippets."
