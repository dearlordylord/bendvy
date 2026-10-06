## Parent

#1 — full Bend-native bevy-ts core parity.

## What to build

An application declares a static typed sequence of registered systems, phases, conditions and explicit barriers, and executes it repeatedly in authored order.

## Acceptance criteria

- [ ] Match observed TS order for phases, true/false conditions and barriers; demonstrate repeated actual public runner execution without moving affine owners out of the schedule.
- [ ] A failed system restores its own writes/publications while earlier commits persist. Pending commands survive runs without an implicit flush; explicit barriers apply them at the declared point.
- [ ] Validate schedule/system identities and supported duplicate rules; two independent instances remain distinct. Source-current schema/access/ownership negatives pass.
- [ ] Detect reached order, conditional-execution and implicit-flush mutants. Use current closed registered runners; runtime heterogeneous captures are an explicit later extension.

## Blocked by

None (can start immediately; any explicit design/policy prerequisite in acceptance must be resolved before implementation).

## Delivery and performance

- Preserve Bend types, affine ownership and runtime semantics; arbitrary component families and Data/Type components remain supported. New dependencies, numerical thresholds and exact laws retain SPEC approval gates. Ticket publication does not renew a measured-loop budget.
- For executable public-core changes, run the unchanged #28 frozen Workshop paired regression gate, retain complete receipts, and reject statistically confirmed slowdown. No minor percentage allowance is approved and no automatic baseline update is allowed.
- Freeze equivalent feature-specific work before measuring pinned TS, JS and Native; validate every full observation. New functionality has no historical Bend baseline. Record timing/scaling limits; process timing does not qualify hot-path performance.
- JS<=TS and Native<=0.5TS product qualification, full connected gates and the five-workload/three-size matrix remain with #21/#23/#24. Do not duplicate or close those parents with this slice.
- Commit verified changes on master, obtain independent Spec/Standards review, push and report against this issue before closing. A capability proposal or incomplete experiment does not pass executable acceptance.
