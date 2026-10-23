# Setup on a new Mac

## Prerequisites

- macOS with Cursor Desktop installed and signed in
- [Cursor CLI](https://cursor.com/docs/cli/overview) (`agent`) installed
- [Magpie](https://github.com/yetone/magpie) installed
- Codex / ChatGPT Codex desktop (or CLI) installed
- `python3`, `sqlite3`, `launchctl`

## 1. Clone and install the bridge

```bash
git clone git@github.com:icatw/cursor-magpie-bridge.git ~/Projects/cursor-magpie-bridge
cd ~/Projects/cursor-magpie-bridge
bash install/install-macos.sh
```

Verify:

```bash
agent status
# email should match Cursor Desktop Settings → Account
```

Skip launchd if you only want sync-on-agent-start:

```bash
bash install/install-macos.sh --no-launchd
```

## 2. Magpie

1. Open Magpie; confirm `lsof -nP -iTCP:3425 -sTCP:LISTEN`.
2. Enable `@magpie-community/opencode-cursor-auth` (see `templates/magpie/plugins.json`).
3. Use **cursor-agent** as the Cursor credential source (reads Keychain / `auth.json`).
4. Optional: apply [`patches/LOCAL-PATCH.md`](../patches/LOCAL-PATCH.md) so Magpie `who` updates when the CLI token rotates.

## 3. Codex

Merge [`templates/codex/config.magpie.snippet.toml`](../templates/codex/config.magpie.snippet.toml) into `~/.codex/config.toml`.

- Prefer Magpie's documented bearer (`magpie`) unless Magpie UI shows otherwise.
- Do not copy API keys from another machine's chat logs or backups into git.

Restart Codex after Magpie is up.

## 4. Acceptance checklist

| Step | Expect |
|------|--------|
| Desktop account shows email A | — |
| `cursor-agent-sync-auth` | synced as A |
| `agent status` | Logged in as A |
| Magpie Cursor identity | A |
| Codex request with `cursor/auto` | Magpie usage / affinity shows `cursor@A` |

Change Desktop login to B, wait for launchd sync (or run sync once), re-check Magpie/Codex → B.

## 5. After `agent update`

Official CLI updates may restore `~/.local/bin/agent` to a plain symlink. Re-run:

```bash
bash install/install-macos.sh --no-launchd
# or only:
ln -sfn ~/.local/bin/agent-desktop-auth-wrapper ~/.local/bin/agent
ln -sfn ~/.local/bin/agent-desktop-auth-wrapper ~/.local/bin/cursor-agent
```

## Troubleshooting

| Symptom | Check |
|---------|--------|
| Sync: Desktop not logged in | Open Cursor Desktop, sign in |
| Magpie who stale after Desktop change | Re-apply LOCAL-PATCH; confirm Keychain token matches `auth.json` |
| Codex can't reach model | Magpie running? Port 3425? `openai_base_url` / magpie provider |
| launchd silent | `~/.cache/cursor-agent-desktop-sync/watch.log` and launchd err log |
