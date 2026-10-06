## Parent

#1 — full Bend-native bevy-ts core parity.

## What to build

Independent public systems observe removal and despawn records after explicit structural barriers, including slow readers and retries after entity data is no longer queryable.

## Acceptance criteria

- [ ] Observe pinned TS remove/despawn checkpoints and match complete JS/Native results for actual public insert/remove/despawn commands and barriers.
- [ ] Verify independent readers, retained slow-reader records, registration/disposal, skipped runs and failed retry. Removal skip preserves backlog and does not inherit event skip semantics.
- [ ] Record identity/family and observable order while cleanup releases all removed component owners; stale and foreign lookups remain safe. Include multiple affine component families.
- [ ] Run intended access/schema/owner negatives and detect compiling lost-record or wrongly advanced-cursor mutants. Sharing event-reader infrastructure is optional and does not create a dependency.

## Blocked by

None (can start immediately; any explicit design/policy prerequisite in acceptance must be resolved before implementation).

## Delivery and performance

- Preserve Bend types, affine ownership and runtime semantics; arbitrary component families and Data/Type components remain supported. New dependencies, numerical thresholds and exact laws retain SPEC approval gates. Ticket publication does not renew a measured-loop budget.
- For executable public-core changes, run the unchanged #28 frozen Workshop paired regression gate, retain complete receipts, and reject statistically confirmed slowdown. No minor percentage allowance is approved and no automatic baseline update is allowed.
- Freeze equivalent feature-specific work before measuring pinned TS, JS and Native; validate every full observation. New functionality has no historical Bend baseline. Record timing/scaling limits; process timing does not qualify hot-path performance.
- JS<=TS and Native<=0.5TS product qualification, full connected gates and the five-workload/three-size matrix remain with #21/#23/#24. Do not duplicate or close those parents with this slice.
- Commit verified changes on master, obtain independent Spec/Standards review, push and report against this issue before closing. A capability proposal or incomplete experiment does not pass executable acceptance.
