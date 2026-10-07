# Unapproved component-state candidates

These are exact proposed subjects for discussion, not approved ECS laws and not
proof claims. Finite witnesses and planted-defect receipts are retained in the completion report;
no finite receipt approves these subjects or constitutes a universal proof.

1. For a legal typed move (from,to), reading current=from and committing succeeds
   with current=to; every neighbor owner and unrelated state value is preserved.
2. For current≠from, the same operation returns mismatch(expected=from,actual=current),
   preserves every value and does not create a changed stamp.
3. A failed public runner after successful state writes restores all prior state
   values, lifecycle stamps and complete arbitrary Array neighbor owners.
4. A committed state replacement, including a same-value replacement, follows the
   existing ordinary-write changed-reader semantics; exact same-value TS observation
   was observed in the source-bound TS trace; approval remains pending.
5. No absent state is implicitly manufactured by an entity's neighbor component.

No universal runtime-refinement, enum-decoder exhaustiveness or graph theorem is
claimed. Typed allowed edges, runtime compare-and-set and global machine scheduling
are separate contracts. Invalid raw construction must preserve the existing owner.

6. Proposed checked-write subject: for any provider-returned write refusal Error,
   checked compare/transition returns exactly that Error and the returned affine
   owner, rather than StateMoved. The public provider's actual clock-limit fixture
   must refuse CapacityExceeded after a successful read and retain values/stamps.
   This subject is unapproved and has no proof. A compiling status-omission mutant
   reached false movement after actual CapacityExceeded on both JS and Native in
   receipt1791360621406966751. No law approval or proof follows.


The integrated receipt1791361960587288257 also falsifies a public expected-for-target
write defect: complete advanced state is Phase0/Mode0 instead of Phase1/Mode2 in both
schemas, on both JS and Native. This is finite evidence for subject1, not approval
of that subject, an exhaustive graph theorem or a proof.
