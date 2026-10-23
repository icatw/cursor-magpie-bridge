# cursor-magpie-bridge

Private tooling: keep **Cursor CLI** (and thus **Magpie → Codex**) aligned with the **Cursor Desktop** login currently on the machine.

```text
Desktop login → sync scripts → CLI auth.json + Keychain → Magpie :3425 → Codex
```

This repo **follows** the Desktop account. It does not implement account pools or quota-driven rotation.

## Contents

| Path | Purpose |
|------|---------|
| `scripts/` | Sync, agent wrapper, launchd watch helper, re-enter helper |
| `install/install-macos.sh` | Install binaries + optional launchd job |
| `launchd/` | WatchPaths plist template |
| `templates/codex/` | Codex `config.toml` snippet for Magpie |
| `templates/magpie/` | Plugin list + notes |
| `patches/LOCAL-PATCH.md` | Magpie cursor-auth “who” refresh after token rotate |
| `docs/` | Architecture, new-machine setup, operations |
| `.agents/skills/cursor-magpie-bridge/` | Agent skill for maintainers |

## Quick install (macOS)

```bash
git clone <this-repo> ~/Projects/cursor-magpie-bridge
cd ~/Projects/cursor-magpie-bridge
bash install/install-macos.sh
agent status
```

Then Magpie (port 3425) + Codex snippet — see [docs/setup-new-machine.md](docs/setup-new-machine.md).

## Install the skill for agents

```bash
# Cursor / shared agents skills dir
mkdir -p ~/.agents/skills
ln -sfn "$(pwd)/.agents/skills/cursor-magpie-bridge" ~/.agents/skills/cursor-magpie-bridge

# Optional: Codex skills
mkdir -p ~/.codex/skills
ln -sfn "$(pwd)/.agents/skills/cursor-magpie-bridge" ~/.codex/skills/cursor-magpie-bridge
```

## Security

- Never commit `auth.json`, Magpie `logins.json` / `plugin-auth.json`, or live API keys.
- Templates use placeholders only.
- Sync scripts never print token values.

## License

Private; all rights reserved for the repository owner unless otherwise noted.
Third-party Magpie / Cursor CLI remain under their own licenses — this repo only ships wrappers and docs.
