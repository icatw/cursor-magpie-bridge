# Day-to-day operations

## Manual sync

```bash
cursor-agent-sync-auth
cursor-agent-sync-auth --quiet
```

## Skip sync for one agent run

```bash
CURSOR_AGENT_SKIP_DESKTOP_SYNC=1 agent status
```

## Re-enter chat after Desktop account change

```bash
# wait until Desktop token fingerprint changes, then continue last chat
agent-desktop-reenter --wait-sec 60 -- --yolo

# or resume a specific chat id
agent-desktop-reenter --resume '<chat-id>' -- --yolo
```

## launchd watcher

```bash
launchctl print "gui/$(id -u)/com.icatw.cursor-agent-desktop-sync"
tail -f ~/.cache/cursor-agent-desktop-sync/watch.log
```

Unload:

```bash
launchctl bootout "gui/$(id -u)/com.icatw.cursor-agent-desktop-sync"
```

## Magpie plugin reinstall warning

`magpie plugin` / npm refresh of `@magpie-community/opencode-cursor-auth` overwrites `index.mjs`.
If you use the local who-refresh patch, re-apply [`patches/LOCAL-PATCH.md`](../patches/LOCAL-PATCH.md).

## Security hygiene

- Never commit `~/.cursor/auth.json`, Magpie `logins.json` / `plugin-auth.json`, or Codex bearer secrets.
- Prefer Keychain prompts staying user-approved for Magpie reads.
- Rotate any token that was pasted into chat or shared backups.
