# Patches

## `LOCAL-PATCH.md`

Describes a **machine-local** change to Magpie’s
`@magpie-community/opencode-cursor-auth` so that when Desktop/CLI token
rotation updates Keychain / `auth.json`, Magpie’s routed `who` (email/plan)
is refreshed.

The patched `index.mjs` is **not** vendored here (large third-party file;
reinstalls overwrite it). Keep a private backup of your patched `index.mjs`
outside git if needed, and re-apply after:

```text
~/.config/magpie/plugins/node_modules/@magpie-community/opencode-cursor-auth/index.mjs
```

Markers that the live file includes the patch: `refreshCliWho`, `tokenFp`, `cliWho`.
