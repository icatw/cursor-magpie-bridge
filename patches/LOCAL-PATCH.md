# Local patch: refresh who when cursor-agent token rotates

Applied on this machine (not upstream).

When Magpie Cursor auth uses `refresh: "cursor-agent"`, Desktop/续杯 may
rotate the keychain / `auth.json` token without Magpie re-signing-in.
Upstream keeps a stale `accountId` (routing `who`).

This patch:

- Fingerprints the live CLI token
- On change, calls `DashboardService/GetMe` + `GetPlanInfo`
- Writes the new email/plan via `client.auth.set` (same as ZCode plugin)

Hooks: `auth.usage`, `auth.loader` fetch, `provider.models`.

**Warning:** `magpie plugin` / npm reinstall of
`@magpie-community/opencode-cursor-auth@latest` will overwrite `index.mjs`.
Re-apply or pin a local copy if that happens.
