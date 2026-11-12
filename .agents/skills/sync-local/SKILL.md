---
name: sync-local
description: Keep the `local` branch (OpenUsage v0.7.16, the UI before the Priority overhaul) up to date. Syncs the fork's main with upstream, finds new upstream commits that fix Claude, Codex or Copilot API compatibility, ports them to `local` test-first, pushes, and reinstalls the app in /Applications. Use when the user asks to sync, update, or pull upstream fixes into `local`.
---

# Sync Local

The user runs the `local` branch as their daily app. It starts at tag `v0.7.16`: the last release with
the old dashboard (large progress bars, local credential discovery, spend tiles).
Upstream later rewrote the app. #1444 brought accounts sign-in, and #1535 rebuilt the panel around
Priority. The user does not want those changes.

`local` takes only upstream fixes that keep **Claude, Codex and Copilot** working against their APIs.

## Remotes

| Remote | URL | Use |
|---|---|---|
| `origin` | `git@github.com:franky47/openusage.git` | The user's fork. Push `main` and `local` here. |
| `upstream` | `https://github.com/robinebers/openusage.git` | Read only. Never push. |

## Steps

### 1. Sync the fork's main

```sh
git fetch upstream --prune
git fetch origin
git fetch upstream main:main   # fast-forward only; fails if main has diverged, so stop and ask
git push origin main
```

Run these from `local`, not from `main`: `git fetch upstream main:main` cannot update the branch you
have checked out.

### 2. List the new candidate commits

Read `ledger.md` (next to this file) for the last reviewed upstream commit, then:

```sh
LAST=<reviewed-up-to sha from ledger.md>
git log --reverse --format='%h %ad %s' --date=short "$LAST"..upstream/main -- \
  Sources/OpenUsage/Providers/Claude Sources/OpenUsage/Providers/Codex \
  Sources/OpenUsage/Providers/Copilot Sources/OpenUsage/Services Sources/OpenUsage/Providers/ProviderError.swift
git log --reverse --format='%h %s' "$LAST"..upstream/main \
  | grep -iE 'claude|codex|chatgpt|copilot|oauth|auth\)|providers\)|http|429|rate.limit|token'
```

Combine the two lists and remove duplicates. Also check whether a request detail changed (endpoints,
`User-Agent`, `anthropic-beta`, GitHub API version):

```sh
pat='https://[a-zA-Z0-9./_-]+|anthropic-beta"?[^)]*|User-Agent"?[^)]*|X-GitHub-Api-Version"?[^)]*|claudeCodeVersion = "[^"]*"'
for ref in local upstream/main; do echo "--- $ref"
  git grep -ohE "$pat" "$ref" -- Sources/OpenUsage/Providers/Claude Sources/OpenUsage/Providers/Codex \
    Sources/OpenUsage/Providers/Copilot Sources/OpenUsage/Services | sort -u
done
```

### 3. Classify each commit

Read the diff (`git show <sha> -- Sources`) and decide:

**Port** when the commit changes how OpenUsage reads a Claude, Codex or Copilot API that `local` also
calls. For example, a new field or a renamed field, a plan rename, a changed header or endpoint, a
status code the client misreads (a 403 that is really a rate limit), or a crash on unusual numbers.

**Skip** these, and record the reason in the ledger:
- UI, layout, Priority, menu bar, settings, alerts, themes, copy.
- The account-first model: `ProviderLogin`, `AccountProviderRuntime`, `CredentialVault`, `AccountStore`,
  OAuth sign-in or device-code flows, Keychain vaults. `local` reads the credentials already on the
  Mac and does not have these types.
- Fixes for bugs that only exist in the rewrite. Many fixes from late October 2026 restore 0.7.16
  behavior that #1444 dropped, so `local` already has it.
- CLIProxy hub, other providers, telemetry, CI, release, docs-only changes.
- New features (Codex daily credits, Copilot org billing, Copilot GHE sign-in, reset grants "Use"),
  unless the user asks for them. Mark these `feature` in the ledger so the user can pick later.

When unsure, ask the user. Do not guess.

### 4. Port test-first

`local` predates the #1444 rewrite, so upstream commits seldom cherry-pick cleanly. Try
`git cherry-pick -x <sha>` only when every file it touches is the same on both sides
(`git diff local upstream/<sha>^ -- <files>` is empty). Otherwise port by hand:

1. Find the equivalent code in `local`. Usual mappings:
   - upstream `AccountProviderRuntime+ClaudeUsage.swift` → local `ClaudeProvider.swift`
   - upstream `ProviderError.swift` → each provider's own error and status handling (for example
     `CopilotProvider.swift`, `CodexUsageClient.swift`)
   - the `*UsageMapper.swift` files stay close on both sides
2. Adapt upstream's test to local types. Run it, and check that it fails for the right reason:
   `swift test --filter <Suite>` (`local` has no `script/test_quiet.sh`).
3. Make the fix. Update old assertions that pinned the old behavior, but leave input fixtures as
   they are.
4. Run the provider's whole suite: `swift test --filter 'Claude|Codex|Copilot'`.
5. Update `docs/providers/<provider>.md` when behavior changes.

### 5. Commit

One commit per ported fix, using the user's git rules: a conventional title with the outcome, a short
body that explains why, and the upstream source on the last line, for example `Ported from upstream dd94b651 (#1499).`
No co-author lines. Never amend.

Then update `ledger.md`: move "Reviewed up to" to the newest upstream commit you classified, and
add one row for each commit with its decision. If you fix a bug that upstream still has, list it under
"Local-only fixes", and check at each sync whether upstream fixed it too. Commit the ledger as
`chore: record upstream sync to <sha>`.

### 6. Push

```sh
git push origin local
```

Never force-push `local`. Never rebase it onto `main`.

### 7. Reinstall the app

The user runs `local` from `/Applications`, built with the production bundle ID so that it keeps
their settings. The dev build has no Sparkle feed, so it never updates itself to 0.8.

```sh
B=~/OpenUsage-backup-$(date +%Y%m%d) && mkdir -p "$B"
ditto /Applications/OpenUsage.app "$B/OpenUsage.app"
defaults export com.robinebers.openusage "$B/com.robinebers.openusage.plist"
BUNDLE_ID=com.robinebers.openusage ./script/build_and_run.sh build
osascript -e 'tell application id "com.robinebers.openusage" to quit'
# wait until no /Applications/OpenUsage.app process remains, then:
rm -rf /Applications/OpenUsage.app && ditto dist/OpenUsage.app /Applications/OpenUsage.app
open /Applications/OpenUsage.app
```

Wait about 10 seconds, then check `~/Library/Logs/OpenUsage/OpenUsage.log`. Each of claude, codex
and copilot must log `ok` in the refresh batch.

### 8. Report

Tell the user which commits you ported (with the local commit SHA), which you skipped and why, and
which features they may want to pick.

## Guardrails

- Never change the version, tag, or release from `local`.
- Never push to `upstream`, and never push anything but a fast-forward to `origin/main`.
- The `AGENTS.md` on `local` is the old one. Where it conflicts with the user's global instructions,
  follow the user's.
