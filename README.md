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

## Notes

The iTerm2 AI API key is stored in the macOS Keychain, not in the plist, so it
is not in this repo. Keep it that way — this repo is public.
