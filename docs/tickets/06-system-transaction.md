# T06: Successful commit and failed-system rollback

**Status:** published, `ready-for-agent`. [GitHub #7](https://github.com/dearlordylord/bendvy/issues/7).

## Parent

https://github.com/dearlordylord/bendvy/issues/1

## What to build

One system commits changes. The next reads its own writes, updates a component/resource again, produces an event/command and fails. Only the successful system result remains externally visible.

## Acceptance criteria

- [ ] Observe read-your-writes, successful commit and typed failure separately; preserve earlier commits.
- [ ] Roll back failed-system ECS component/resource writes and pending publications; host IO is explicitly outside the transaction.
- [ ] Test rollback for the chosen Data path and assess the Type-payload probe; unsupported affine rollback remains an explicit unresolved limitation.
- [ ] A pure function signature is not evidence that mutated arrays are rolled back; demonstrate the strategy with executable evidence.
- [ ] Compare native/JavaScript traces with TypeScript; draft guarantees cover preservation and absence of failed publications, not whole-schedule rollback.

## Blocked by

- T04: Affine payload without losing ownership
- T05: Reservation, lookup and explicit structural barrier

## Outcome gates

Research may conclude with a reproducible negative result: the report is complete, but the capability gate has not passed. If mandatory behavior cannot be expressed, immediately prepare a bounded redesign/specification decision; dependent implementation/proof work remains blocked. A follow-up does not mean the behavior has been accepted or removed from the goal.
