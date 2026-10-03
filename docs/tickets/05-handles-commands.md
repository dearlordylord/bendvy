# T05: Reservation, lookup and explicit structural barrier

**Status:** published, `ready-for-agent`. [GitHub #6](https://github.com/dearlordylord/bendvy/issues/6).

## Parent

https://github.com/dearlordylord/bendvy/issues/1

## What to build

Reserve an entity through the experimental API, make it live only at an explicit marker, then remove it; lookup/query observations must be correct before and after each action.

## Acceptance criteria

- [ ] Cover pending spawn, live, stale and foreign handles; check storage bounds before array access.
- [ ] Schedule completion does not flush pending commands; a subsequent schedule can apply them through an explicit marker.
- [ ] Insert/remove/despawn and query order preserve expected observations; justify any chosen reuse/exhaustion policy explicitly.
- [ ] Native/JavaScript traces match the normalized TypeScript reference; reservation is not evidence of liveness.
- [ ] Present candidate identity, membership and command laws with plain-language explanations; do not write proofs yet.

## Blocked by

- T03: Repeatable type-safe queries on two worlds

## Outcome gates

Research may conclude with a reproducible negative result: the report is complete, but the capability gate has not passed. If mandatory behavior cannot be expressed, immediately prepare a bounded redesign/specification decision; dependent implementation/proof work remains blocked. A follow-up does not mean the behavior has been accepted or removed from the goal.
