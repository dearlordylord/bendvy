# T07: Two event readers, retry and retention

**Status:** published, `ready-for-agent`. [GitHub #8](https://github.com/dearlordylord/bendvy/issues/8).

## Parent

https://github.com/dearlordylord/bendvy/issues/1

## What to build

Run two independent event readers at different rates; a failed reader retries its read, while skipped-reader and overflow behavior follows the reference contracts.

## Acceptance criteria

- [ ] One reader does not consume another reader's data; committed events follow reference visibility/order without requiring a structural flush.
- [ ] A failed reader does not advance its cursor; distinguish message skip rules from change detection.
- [ ] Test retention/capacity/lag on small boundary inputs; compare native/JavaScript observations with TypeScript.
- [ ] Limit candidate laws to buffered event readers; change/lifecycle observations have a separate ticket, and transition/relation streams remain in the core map.

## Blocked by

- T06: Successful commit and failed-system rollback

## Outcome gates

Research may conclude with a reproducible negative result: the report is complete, but the capability gate has not passed. If mandatory behavior cannot be expressed, immediately prepare a bounded redesign/specification decision; dependent implementation/proof work remains blocked. A follow-up does not mean the behavior has been accepted or removed from the goal.
