# Magpie templates

## Required

1. Install [Magpie](https://github.com/yetone/magpie) (or your packaged `.dmg`).
2. Start Magpie so it listens on `127.0.0.1:3425`.
3. Enable `@magpie-community/opencode-cursor-auth`.
4. Sign in Cursor via **cursor-agent** refresh mode (reads Keychain / `~/.cursor/auth.json`).

## After Desktop / CLI token rotation

Upstream Magpie may keep a stale `who` (email) after Desktop changes the CLI token.
See [`../../patches/LOCAL-PATCH.md`](../../patches/LOCAL-PATCH.md).

## Do not commit

- `~/.config/magpie/logins.json`
- `~/.config/magpie/plugin-auth.json`
- Any API keys in `providers.json`
