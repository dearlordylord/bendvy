# T10: Comparable native/JavaScript benchmarks

**Status:** published, `ready-for-agent`. [GitHub #11](https://github.com/dearlordylord/bendvy/issues/11).

## Parent

https://github.com/dearlordylord/bendvy/issues/1

## What to build

Reproducibly compare bevy-ts with the native and JavaScript experimental ECS on equivalent operations, exposing traversal, update, churn, reader and rollback costs.

## Acceptance criteria

- [ ] Validate matching observations for every measured workload before timing; do not weaken semantics to improve benchmark results.
- [ ] Pin inputs/environments; separate compilation/checking/setup from execution; publish worker count, JavaScript warmup, repetitions and variability.
- [ ] Include sparse/dense traversal, updates, structural churn, event reads and rollback at multiple sizes; document memory measurement methods and limitations.
- [ ] Propose justified numerical thresholds for significant native speedup and JavaScript comparability for approval; preserve the performance requirement.
- [ ] The report does not require an already completed full-core engine. Expose a slow prototype honestly, identifying concrete problems, alternatives and blockers.
- [ ] Microbenchmarks do not establish final performance acceptance; full workload gates remain explicit follow-ups.

## Blocked by

- T04: Affine payload without losing ownership
- T05: Reservation, lookup and explicit structural barrier
- T06: Successful commit and failed-system rollback
- T07: Two event readers, retry and retention
- T08: Independent change/removal observations

## Outcome gates

Research may conclude with a reproducible negative result: the report is complete, but the capability gate has not passed. If mandatory behavior cannot be expressed, immediately prepare a bounded redesign/specification decision; dependent implementation/proof work remains blocked. A follow-up does not mean the behavior has been accepted or removed from the goal.
