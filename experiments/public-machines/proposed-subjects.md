# Machine subjects awaiting approval

These are candidate equivalence subjects for finite falsification, not approved
laws or proofs. The implementation and the retained TS oracle do not establish
universal runtime refinement.

1. **Pending alias writes.** Given a provisioned machine, ordered `set`,
   `setIfChanged` and `reset` calls through repeated capability aliases observe
   one current pending request. The final request includes the final skip flag.
   Candidate mutants: use the first request, or retain an overwritten skip flag.
2. **Failed publishing transaction.** A failing registered body restores the
   complete pre-body machine slots and actual component/resource owners, while
   discarding its deferred commands and transition publications. Existing
   allocator reservation and clock behavior must remain separately observable.
   Candidate mutants: omit a pending-slot inverse, restore only an Array prefix,
   or enqueue a failed command.
3. **Captured marker order.** Structural commands flush first. The marker captures
   initially pending values in machine definition order, clears the changed set,
   and processes each captured value once. Same-state normal set publishes;
   same-state conditional set consumes without publication. Candidate mutants:
   pending insertion order, early current-state mutation, or identity suppression.
4. **Pinned marker exception.** A marker-created write to a later already captured
   machine is deleted at that machine's turn, while a self-requeue can survive.
   The finite TS checkpoint pins this behavior, but the blanket ticket retention
   statement conflicts with it. Neither this subject nor the stronger retention
   alternative is approved. A mutant that preserves the later write is a
   deviation from the pinned reference, not an approved project defect.
5. **Condition combinations.** Provisioning checks precede evaluation. Current
   state and changed membership compose through ordered `not`, arbitrary finite
   `and` and `or`, with empty identities true and false respectively. Candidate
   mutants: inverted empty identities or stale changed membership after a marker.
6. **Independent transition readers.** First actual activation, registered skip,
   successful completion, failure/retry, disposal, frame retention and exact
   65,536-event capacity preserve the primary API's payload order, cursor and lag
   observations. Candidate mutants: advance a failed reader, activate a skipped
   never-run reader, or use capacity 65,535.

Affine ownership, schema identity and readonly/undeclared access controls are
compiler boundary checks. They do not prove universal authority over the trusted
raw provisioning constructors. Full transition-handler failure positions and
whole-marker rollback remain the separate #49 obligation.
