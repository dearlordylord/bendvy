## Parent

#1 — full Bend-native bevy-ts core parity.

## What to build

Repeated conditional public schedules combine event, added/changed and removal readers without conflating their skip, successful-run or failed-retry cursor rules.

## Acceptance criteria

- [ ] Freeze a composed reference trace with fast/slow readers, conditions, earlier commits, a failing publisher/reader, explicit barriers and successful retry; match complete JS/Native observations.
- [ ] Event skip discards the reference backlog; removal and change skips preserve visibility. Failure advances neither successful cursor; lifecycle success consumes the authoritative post-run clock including own writes.
- [ ] Reader registration/disposal, lag and retained records remain independent across schedules; pending structural work and earlier successful publications survive a later failure.
- [ ] Detect compiling wrong-reader advancement, failed publication and own-write replay mutants through actual scheduled operations, preserving all component/resource owners.

## Blocked by

- #31
- #32
- #33

## Delivery and performance

- Preserve Bend types, affine ownership and runtime semantics; arbitrary component families and Data/Type components remain supported. New dependencies, numerical thresholds and exact laws retain SPEC approval gates. Ticket publication does not renew a measured-loop budget.
- For executable public-core changes, run the unchanged #28 frozen Workshop paired regression gate, retain complete receipts, and reject statistically confirmed slowdown. No minor percentage allowance is approved and no automatic baseline update is allowed.
- Freeze equivalent feature-specific work before measuring pinned TS, JS and Native; validate every full observation. New functionality has no historical Bend baseline. Record timing/scaling limits; process timing does not qualify hot-path performance.
- JS<=TS and Native<=0.5TS product qualification, full connected gates and the five-workload/three-size matrix remain with #21/#23/#24. Do not duplicate or close those parents with this slice.
- Commit verified changes on master, obtain independent Spec/Standards review, push and report against this issue before closing. A capability proposal or incomplete experiment does not pass executable acceptance.
