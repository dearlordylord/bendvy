# Current ordinary application carriers

This successor preserves the complete generational AppA and AppB operation sequences,
state observations and affine owners against core commit `81316652e`. Historical
consumers and evidence remain unchanged.

AppA runs through `host.bend` and prints its complete report. AppB uses its existing
`main.bend` report entry. Both use current canonical core modules through relative
imports; no core or runner implementation changes are included.

The observer preserves every opaque `Deferred.Command` owner and records the ordered
`Raw`/`Observed` variants as `pendingKinds`, alongside the existing pending count.
AppB's transaction enqueue adapter now passes these commands to
`World.enqueue_command`. The extracted allocator-only observer preserves the exact
previous allocator format without importing an unrelated historical transaction
observer. Actual observed columns remain ordinary `Column` throughout these finite
programs; the inherited prepared-column fallback is unreachable.

Both pure consumers and AppA's IO host pass the pinned default five-second source
check on CPU8. Repair diagnostics are retained under `checks`; one raw diagnostic
is stored as lossless gzip to preserve compiler whitespace.

All four stock Bend 2.0.35 JS/Native runs pass complete independent reports:

- AppA: 48,145 bytes, SHA256 `86d2ac72f359b0033fa108c84e60fd5d34a2b46cba85c2f5d5d6691c8665d702`.
- AppB: 14,577 bytes, SHA256 `5d88aee4c1deeadce19e97f180daead67e84f206c175bed96cb4a55d3527b9e8`.

The independent source-derived models are sealed in `current-carrier-oracle-v1`
(commit `bee795870bdf77328f6320caed3b30f061042c62`). All ten emit/build/consumer
commands exit zero within the original 30/120/5-second caps; runtime stderr is empty.
No normalization, feature cuts, new contracts or performance claims apply.

Each app's `runtime-v1/actual-attempt01/RETENTION.json` binds the actual execution
paths, plans, receipts, guards, sources, outputs and lossless objects. Installed tool
ELFs are identified by hash rather than redistributed. These are executions in the
recorded author worktree, not claims of rerunning after integration. Root integration,
normal hooks and CI remain delivery gates; full #61 feature acceptance stays separate.
