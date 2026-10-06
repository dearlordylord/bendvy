## Parent

#1 — full Bend-native bevy-ts core parity.

## What to build

Two independently registered public systems consume ordered events at different rates with bounded retention, explicit lag and correct successful, skipped and failed-run behavior.

## Acceptance criteria

- [ ] Freeze and execute pinned TS checkpoints for publication, independent readers, capacity/retention, lag, skip, failure and retry; match complete JS/Native outputs.
- [ ] Public registration, successful transactions and actual reads drive the observations; failed publication remains absent and failed reads preserve their positions, while an event-reader skip follows reference backlog-discard semantics.
- [ ] Demonstrate registration/disposal and slow-reader retention using actual stored values and positions, not cached counts; cleanup cannot silently discard another active reader's data.
- [ ] Replay access/owner/schema negatives and detect compiling publication/cursor/retention mutations. Initial executable Data event scope stays explicit; affine fan-out remains unresolved full-core work and no final Data-only restriction is approved.

## Blocked by

None (can start immediately; any explicit design/policy prerequisite in acceptance must be resolved before implementation).

## Delivery and performance

- Preserve Bend types, affine ownership and runtime semantics; arbitrary component families and Data/Type components remain supported. New dependencies, numerical thresholds and exact laws retain SPEC approval gates. Ticket publication does not renew a measured-loop budget.
- For executable public-core changes, run the unchanged #28 frozen Workshop paired regression gate, retain complete receipts, and reject statistically confirmed slowdown. No minor percentage allowance is approved and no automatic baseline update is allowed.
- Freeze equivalent feature-specific work before measuring pinned TS, JS and Native; validate every full observation. New functionality has no historical Bend baseline. Record timing/scaling limits; process timing does not qualify hot-path performance.
- JS<=TS and Native<=0.5TS product qualification, full connected gates and the five-workload/three-size matrix remain with #21/#23/#24. Do not duplicate or close those parents with this slice.
- Commit verified changes on master, obtain independent Spec/Standards review, push and report against this issue before closing. A capability proposal or incomplete experiment does not pass executable acceptance.
