## Parent

#1 — full Bend-native bevy-ts core parity.

## What to build

An application can count matches, require exactly one match, and look up a specific entity through a composed typed query, receiving precise errors without losing its World or component owners.

## Acceptance criteria

- [ ] Observe the pinned TS zero/one/multiple-match and entity lookup contracts, then match complete JS/Native observations; distinguish MissingEntity, QueryMismatch, NoEntities and MultipleEntities with the actual count.
- [ ] Exercise required/optional/with/without combinations, structural churn, ascending order and aliasing through the existing heterogeneous public API; foreign-world lookup retains the approved MissingEntity divergence.
- [ ] Failed lookup/cardinality checks return all owners and leave writes, marks, queues and reader positions unchanged. Actual affine Arrays and intended access/schema negatives pass.
- [ ] Detect a compiling wrong-cardinality or wrong-mismatch mutant at a reached public checkpoint; do not infer contract completeness from Compose.each.

## Blocked by

None (can start immediately; any explicit design/policy prerequisite in acceptance must be resolved before implementation).

## Delivery and performance

- Preserve Bend types, affine ownership and runtime semantics; arbitrary component families and Data/Type components remain supported. New dependencies, numerical thresholds and exact laws retain SPEC approval gates. Ticket publication does not renew a measured-loop budget.
- For executable public-core changes, run the unchanged #28 frozen Workshop paired regression gate, retain complete receipts, and reject statistically confirmed slowdown. No minor percentage allowance is approved and no automatic baseline update is allowed.
- Freeze equivalent feature-specific work before measuring pinned TS, JS and Native; validate every full observation. New functionality has no historical Bend baseline. Record timing/scaling limits; process timing does not qualify hot-path performance.
- JS<=TS and Native<=0.5TS product qualification, full connected gates and the five-workload/three-size matrix remain with #21/#23/#24. Do not duplicate or close those parents with this slice.
- Commit verified changes on master, obtain independent Spec/Standards review, push and report against this issue before closing. A capability proposal or incomplete experiment does not pass executable acceptance.
