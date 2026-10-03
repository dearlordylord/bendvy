# T09: Nested schedule with provisioning and failure

**Status:** published, `ready-for-agent`. [GitHub #10](https://github.com/dearlordylord/bendvy/issues/10).

## Parent

https://github.com/dearlordylord/bendvy/issues/1

## What to build

A repeatedly executable nested schedule receives declared resource/service requirements and returns the expected typed system failure without granting extra access.

## Acceptance criteria

- [ ] Provide one correctly provisioned schedule and missing/incompatible-provision controls; establish the static/dynamic boundary from evidence.
- [ ] Nesting preserves order and requirements; failures retain system identity and do not require unconditional whole-world access.
- [ ] Host service interactions do not promise ECS rollback of external effects.
- [ ] Execute the public example on native/JavaScript; test affine callback and repeated-execution limits.
- [ ] This is a minimal composition, not complete coverage of fragments/features/phases/conditions.

## Blocked by

- T03: Repeatable type-safe queries on two worlds

## Outcome gates

Research may conclude with a reproducible negative result: the report is complete, but the capability gate has not passed. If mandatory behavior cannot be expressed, immediately prepare a bounded redesign/specification decision; dependent implementation/proof work remains blocked. A follow-up does not mean the behavior has been accepted or removed from the goal.
