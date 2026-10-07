# #48 machines — current execution checkpoint

Incomplete implementation; the actual pinned oracle is frozen before Bend work. This is not feasibility-only delivery or issue completion. Implementation and controls continue under experiments/public-machines, without shared-core edits.

[Observed contract](../../experiments/public-machines/contract.md) and [complete expected observations](../../experiments/public-machines/expected.json) retain 24 checkpoints per independent schema plus raw boundary cases. [Actual source-bound Node receipt](../../experiments/public-machines/evidence/reference-v1/receipt.json) passes. All three reference commits match the tracked manifest, Node 24.20.0 needs no installed dependencies, and installed tool/reference/input/output hashes are guarded.

A concrete valid-public-API counterexample conflicts with the governing blanket marker-retention wording: a handler's new request for a later already-snapshotted machine is deleted before that machine applies its old copied request. Pinned behavior is retained as the comparison target for the staged candidate, with approval explicitly pending between preserving TS loss and stronger retention. #48 remains open; no divergence or exact law is approved while the user is absent.

Remaining work: generic affine machine ownership, schedule/transaction integration, complete JS/Native observations, authority negatives, reached mutants, independent review and equivalent-work feature evidence. No new ECS proofs, policies, dependencies or numerical criteria are introduced. Full product qualification remains #21/#23/#24; full transition-handler failure matrices remain #49.
