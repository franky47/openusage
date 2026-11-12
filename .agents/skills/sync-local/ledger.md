# Upstream Sync Ledger

Base: `v0.7.16` (`abf472d5`). Upstream #1444 (`7129ab29`) comes right after it.

Reviewed up to: `35e88e93` (upstream main, 2026-11-11)

| Upstream | Subject | Decision | Local commit / reason |
|---|---|---|---|
| `7129ab29` | Bring the new OpenUsage into main (#1444) | skip | the account-first rewrite |
| `d72b83ba` | ChatGPT's Extra Usage row shows the credits' dollar value again (#1452) | skip | restores 0.7.16 behavior that `local` has |
| `81e13c3a` | Show Copilot Org Credits and Org Spend as an Organization Billing account (#1456) | feature | `local` shows org billing on the Copilot card |
| `e8729655` | Open a Copilot organization's billing page from its account menu | skip | account UI |
| `28ffb97a` | fix(oauth): send a random state, never the PKCE verifier (#1460) | skip | sign-in flow; `local` does not sign in |
| `f9bb8bbc` | fix(oauth): treat only a refused token renewal as an expired sign-in (#1461) | skip | `local` already sorts renewal errors |
| `520caec7` | fix(http): stop caching provider responses (#1486) | port | 45471c20 |
| `dd94b651` | fix(claude): show Max and Ultra plan names (#1499) | port | 48e3f76c |
| `e504a1c9` | fix(auth): keep renewed tokens when the Keychain write fails (#1515) | skip | account runtime only |
| `b91d4171` | fix(providers): reject provider numbers too large for an Int (#1518) | port | 2bce26be, afd59a2c (Codex, Claude reset grants, Pi scanner, countdown) |
| `f619b4a6` | fix(accounts): a replaced key clears the old key's 429 hold (#1511) | skip | account runtime only |
| `10ac77a1` | fix(claude): a late success keeps a newer 429 window (#1527) | skip | account runtime only |
| `502867af` | fix(auth): wait out Retry-After before renewing a sign-in early again (#1526) | skip | account runtime only |
| `638affca` | fix(refresh): a waiting manual refresh respects a fresh 429 (#1521) | skip | account runtime only |
| `1adeac38` | fix(claude): fail a sign-in whose profile read failed (#1525) | skip | sign-in flow |
| `8a0c6962` | fix(claude): re-read reset grants once a grant is spent (#1531) | skip | read scheduling in the rewrite; the request is unchanged |
| `53d04144` | feat(codex): show daily credits, tokens, turns and the credit limit (#1524) | feature | |
| `2114be56` | fix(providers): read 403 rate limits and dual 429s as rate limits (#1529) | port | 902b5160 (Copilot part only) |
| `daa3ff0d` | fix(refresh): keep one Keychain read in flight per account (#1517) | skip | account runtime only |
| `f39ac7aa` | fix(claude): make a new sign-in prove itself with its own request (#1536) | skip | sign-in flow |
| `8a883219` | fix(claude): show Extra Usage in the account's billing currency | port | 23f26343 |
| `e44d9d76` | fix(claude): title an Enterprise plan's Extra Usage row Spend (#1592) | skip | Enterprise only; needs row-title support |
| `4beb01a8` | refactor(providers): reuse the login HTTP helpers and Foundation APIs (#1590) | skip | refactor of the rewrite |
| `61789646` | feat(copilot): sign in on GitHub Enterprise domains on GHE.com (#1607) | feature | sign-in flow |
| `ea46fc61` | fix(claude): ask for user:inference so Use can spend a reset (#1652) | skip | sign-in scopes |
| `cbb3bf74` | fix(claude): retry a reset-grants read that fails before the first answer (#1664) | skip | read scheduling in the rewrite; the request is unchanged |
| `647ff126` | fix(claude): read reset grants with usage and keep their kinds in the cache (#1666) | skip | read scheduling in the rewrite; the request is unchanged |
