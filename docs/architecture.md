# Architecture

## Data flow

```text
Cursor Desktop login (state.vscdb)
        │
        │  cursor-agent-sync-auth
        │  (+ optional launchd WatchPaths)
        ▼
CLI credential store
  • ~/.cursor/auth.json
  • macOS Keychain: cursor-access-token / cursor-user
        │
        │  Magpie plugin: @magpie-community/opencode-cursor-auth
        │  (refresh: cursor-agent — read-only of CLI store)
        ▼
Magpie local gateway  http://127.0.0.1:3425
        │
        ▼
Codex (model cursor/auto → model_providers.magpie)
```

## What each piece owns

| Component | Owns | Does not own |
|-----------|------|--------------|
| Desktop / any Desktop-side account tool | Current Desktop `cursorAuth/*` | Magpie routing, Codex UI |
| `cursor-agent-sync-auth` | Copy Desktop → CLI file + Keychain | Account pools, quota decisions |
| `agent-desktop-auth-wrapper` | Sync-before-`agent` | Magpie process lifecycle |
| launchd watcher | Debounced sync on DB change | Switching accounts |
| Magpie + cursor-auth plugin | OpenAI-compatible proxy using CLI token | Writing Desktop DB |
| Codex | Chat UI / tools; points base URL at Magpie | Cursor login storage |

## Design invariants

1. **Follow, don't invent accounts.** Scripts only mirror the Desktop login that already exists.
2. **Never print tokens.** Sync logs email / destination only.
3. **Secrets stay off git.** Templates use placeholders; real keys live in Magpie UI / local config.
4. **Magpie prefers Keychain on macOS.** Sync writes both `auth.json` and Keychain so Magpie and `AGENT_CLI_CREDENTIAL_STORE=file` stay aligned.

## Related optional tools

Desktop-side helpers that change `state.vscdb` are out of scope for this repo.
If Desktop's current account changes by any means, this bridge propagates that change to CLI → Magpie → Codex.
