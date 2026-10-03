# T04: Affine payload without losing ownership

**Status:** published, `ready-for-agent`. [GitHub #5](https://github.com/dearlordylord/bendvy/issues/5).

## Parent

https://github.com/dearlordylord/bendvy/issues/1

## What to build

Establish how the same experimental ECS accepts a component with an owned array and reads/updates it, or produce a minimal reproducible rejection explaining the support boundary.

## Acceptance criteria

- [ ] Test Data payloads and Type payloads containing an owned array; distinguish storage kind from component-value kind.
- [ ] Observe expected contents after several updates; document repeated invocation, read semantics and ownership on native/JavaScript.
- [ ] Investigate swap/take/traversal alternatives without unsafe aliasing or casts; one array example does not establish support for closure/IO-handle payloads.
- [ ] Report an inexpressible required API as evidence and a decision for the user, rather than silently adopting a Data-only scope.
- [ ] Record potential cloning costs for benchmarks; give F05 a concrete result and return condition.

## Blocked by

- T03: Repeatable type-safe queries on two worlds

## Outcome gates

Research may conclude with a reproducible negative result: the report is complete, but the capability gate has not passed. If mandatory behavior cannot be expressed, immediately prepare a bounded redesign/specification decision; dependent implementation/proof work remains blocked. A follow-up does not mean the behavior has been accepted or removed from the goal.
