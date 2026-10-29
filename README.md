# configs

Personal machine configuration, kept in version control.

## iterm2/

Full iTerm2 preferences as a single plist — profiles, colors, fonts, key
mappings, window and general settings.

- `com.googlecode.iterm2.plist` — captured from iTerm2 3.6.11 on macOS 26.5.2

iTerm2 supports loading its entire configuration from a folder, so this file is
the live config rather than a stale backup: changes made in the UI are written
straight back here, and committing is the only manual step.

### Set up on a new machine

1. Install iTerm2 and clone this repo.
2. **Quit iTerm2**, then from Terminal.app run:

   ```sh
   ./scripts/iterm2-enable-sync.sh
   ```

3. Launch iTerm2. Settings come from `iterm2/`.

The script refuses to run while iTerm2 is open — a running iTerm2 keeps its
preferences in memory and rewrites them on quit, which would silently undo it.

### Set up by hand

`Settings → General → Settings` → check **Load settings from a custom folder or
URL** → choose this repo's `iterm2/` folder → set **Save changes** to
**Automatically**.

### Update the snapshot manually

Only needed if you have not enabled the custom folder:

```sh
defaults export com.googlecode.iterm2 iterm2/com.googlecode.iterm2.plist
plutil -convert xml1 iterm2/com.googlecode.iterm2.plist
```

### Readable diffs

The plist is stored as XML. If a tool rewrites it as binary, this makes diffs
readable again:

```sh
git config diff.plist.textconv "plutil -convert xml1 -o -"
```

## cursor/

Cursor's user settings, keybindings, and extension list.

- `settings.json`, `keybindings.json` — symlinked into
  `~/Library/Application Support/Cursor/User/`, so edits in either place are the
  same file
- `extensions.txt` — installed extension ids, one per line
- `mcp.json.example`, `cli-config.example.json` — templates; see below

### Set up on a new machine

```sh
./scripts/cursor-link.sh
```

Backs up anything already there as `*.bak`, symlinks the two config files, and
installs everything in `extensions.txt` (needs the `cursor` CLI on PATH —
cmd-shift-P → "Shell Command: Install 'cursor' command").

If Cursor ever replaces a symlink with a regular file after an in-app settings
change, re-run the script; it detects and relinks.

### What is deliberately not committed

`~/.cursor/mcp.json` and `~/.cursor/cli-config.json` are gitignored. The real
files contain internal database endpoints, AWS account ids, Secrets Manager
ARNs, and Cursor account identifiers, and this repo is public. The `.example`
versions have the same shape with placeholders — copy one into place and fill in
the real values:

```sh
cp cursor/mcp.json.example ~/.cursor/mcp.json
```

`~/.cursor/argv.json` is also skipped: it is stock apart from a per-install
crash-reporter id.

## obsidian/

Obsidian hotkeys and CSS snippets. Obsidian keeps settings per vault, in
`<vault>/.obsidian/`.

- `hotkeys.json` — custom key bindings (only the ones changed from Obsidian's
  defaults)
- `snippets/wide-note.css` — full-width notes: add `cssclasses: wide-note` to a
  note's properties
- `snippets/code-block-no-wrap.css` — code blocks scroll sideways instead of
  wrapping, so ASCII trees and wide tables stay readable

### Set up on a new machine

Quit Obsidian (it rewrites its config on exit), then copy the files into the
vault:

```sh
cp obsidian/hotkeys.json "<vault>/.obsidian/hotkeys.json"
mkdir -p "<vault>/.obsidian/snippets"
cp obsidian/snippets/*.css "<vault>/.obsidian/snippets/"
```

Then turn the snippets on in `Settings → Appearance → CSS snippets`.

### Update the snapshot

After changing hotkeys in `Settings → Hotkeys` or editing a snippet:

```sh
cp "<vault>/.obsidian/hotkeys.json" obsidian/hotkeys.json
cp "<vault>/.obsidian/snippets/"*.css obsidian/snippets/
```

## Notes

**This repo is public.** Nothing here should contain a credential, an internal
hostname, or an account identifier. The iTerm2 AI API key lives in the macOS
Keychain rather than the plist, and the Cursor files that do hold that kind of
value are gitignored with `.example` templates in their place. Check before
adding anything new — shell configs and app state directories are the usual way
a token ends up committed by accident.
