# T08: Independent change/removal observations

**Status:** published, `ready-for-agent`. [GitHub #9](https://github.com/dearlordylord/bendvy/issues/9).

## Parent

https://github.com/dearlordylord/bendvy/issues/1

## What to build

Two systems running at different rates independently observe added/changed and removed/despawned in a small scenario; skipping and failure must not conflate lifecycle observations with buffered events.

## Acceptance criteria

- [ ] Each reader observes component additions/updates at the reference position; absence of a structural marker does not replace commit visibility.
- [ ] Removal/despawn observations survive entity disappearance and are independent across readers; compare retention/lag with the corresponding upstream contract.
- [ ] A failed reader retains its position; test change/lifecycle skip rules directly rather than importing event-stream rules.
- [ ] Native/JavaScript observations match the normalized TypeScript reference; controls distinguish message cursors from change ticks.
- [ ] Record candidate guarantees and boundaries of the provable layer; this is not universal refinement proof.

## Blocked by

- T06: Successful commit and failed-system rollback

## Outcome gates

Research may conclude with a reproducible negative result: the report is complete, but the capability gate has not passed. If mandatory behavior cannot be expressed, immediately prepare a bounded redesign/specification decision; dependent implementation/proof work remains blocked. A follow-up does not mean the behavior has been accepted or removed from the goal.
