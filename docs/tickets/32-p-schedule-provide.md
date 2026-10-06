## Parent

#1 — full Bend-native bevy-ts core parity.

## What to build

An application nests typed schedules and phases with declared component/resource/service requirements; all requirements and duplicate rules are checked before any schedule work executes.

## Acceptance criteria

- [ ] Observe pinned TS nested composition, authored flattening order, duplicate and requirement-union behavior; match full positive and negative JS/Native observations.
- [ ] Missing or incompatible provisioning rejects before component writes, host-service calls, events or queued commands. Actual counters prove no partial work.
- [ ] Execute the same nested-provisioning contract independently for two nominal schemas; reject cross-schema composition and undeclared access. Reusable feature composition remains later work; host services remain outside ECS rollback.
- [ ] Detect a compiling omitted-requirement or partial-execution mutant. Retain existing flat schedule consumers and typed owner return on refusal.

## Blocked by

- #33

## Delivery and performance

- Preserve Bend types, affine ownership and runtime semantics; arbitrary component families and Data/Type components remain supported. New dependencies, numerical thresholds and exact laws retain SPEC approval gates. Ticket publication does not renew a measured-loop budget.
- For executable public-core changes, run the unchanged #28 frozen Workshop paired regression gate, retain complete receipts, and reject statistically confirmed slowdown. No minor percentage allowance is approved and no automatic baseline update is allowed.
- Freeze equivalent feature-specific work before measuring pinned TS, JS and Native; validate every full observation. New functionality has no historical Bend baseline. Record timing/scaling limits; process timing does not qualify hot-path performance.
- JS<=TS and Native<=0.5TS product qualification, full connected gates and the five-workload/three-size matrix remain with #21/#23/#24. Do not duplicate or close those parents with this slice.
- Commit verified changes on master, obtain independent Spec/Standards review, push and report against this issue before closing. A capability proposal or incomplete experiment does not pass executable acceptance.
