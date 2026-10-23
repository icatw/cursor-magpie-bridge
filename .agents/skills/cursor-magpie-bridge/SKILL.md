---
name: cursor-magpie-bridge
description: Maintain the Desktop→CLI→Magpie→Codex auth bridge on this machine. Use when installing the bridge on a new Mac, fixing agent/Magpie login mismatch, launchd sync, or Codex cursor/auto via Magpie 3425.
---

# Cursor ↔ Magpie bridge

## When to use

- New machine setup for Codex using Magpie + Cursor CLI credentials
- `agent status` email ≠ Cursor Desktop account
- Magpie `who` stale after Desktop login change
- `agent update` broke the wrapper symlink
- launchd WatchPaths sync not firing

## Do / don't

**Do**

- Follow Desktop's *current* login into CLI Keychain + `~/.cursor/auth.json`
- Point Codex at Magpie `127.0.0.1:3425`
- Keep secrets out of git; use templates only

**Don't**

- Build or wire account pools / quota-driven auto-rotation into this bridge
- Commit tokens, Magpie `logins.json`, or Codex bearer keys
- Patch Magpie by pasting secrets into the skill

## Canonical docs in this repo

1. [docs/architecture.md](../../../docs/architecture.md) — data flow
2. [docs/setup-new-machine.md](../../../docs/setup-new-machine.md) — install order
3. [docs/operations.md](../../../docs/operations.md) — daily commands
4. [patches/LOCAL-PATCH.md](../../../patches/LOCAL-PATCH.md) — Magpie who-refresh after token rotate

## Quick diagnosis

```bash
# 1 Desktop email (length-only / cachedEmail via sync script output)
cursor-agent-sync-auth

# 2 CLI
agent status

# 3 Magpie up?
lsof -nP -iTCP:3425 -sTCP:LISTEN

# 4 Magpie CLI identity file (email only)
python3 -c 'import json;print(json.load(open("/Users/"+__import__("getpass").getuser()+"/.config/magpie/cli-identity.json")))'
```

If Desktop ≠ CLI: re-run sync; check Desktop is logged in; check Keychain item `cursor-access-token`.

If CLI OK but Magpie who wrong: re-apply LOCAL-PATCH; restart Magpie.

If Magpie OK but Codex fails: check `~/.codex/config.toml` `openai_base_url` / `[model_providers.magpie]`.

## Install / repair wrapper

```bash
cd <repo>
bash install/install-macos.sh
```

## Scripts (installed to `~/.local/bin`)

| Script | Role |
|--------|------|
| `cursor-agent-sync-auth` | Desktop DB → auth.json + Keychain |
| `agent-desktop-auth-wrapper` | Sync then exec real `cursor-agent` |
| `cursor-agent-desktop-sync-watch` | Debounced sync for launchd |
| `agent-desktop-reenter` | Sync (optional wait for token change) then `--continue` / `--resume` |
