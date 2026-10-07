# #42 proposed laws — draft, unapproved

These are source-backed candidates for discussion, not `LAWS.bend` declarations, proofs or approved policy. Source: pinned TS `internal/world.ts:495–589`, `Runtime.ts:769–830,1439–1467`, public Relation/Command interfaces; actual finite witnesses are in coverage.md. Ordinary standard relation descriptors only unless stated otherwise. Valid schema registration, namespace/liveness and initial inverse consistency are premises. `E_r(s)` is the optional authoritative target; `I_r(t)` is the ordered unique inverse list. Equality below is of indicated observable projections, never duplication/equality of an arbitrary affine World.

1. **Exact inverse:** `s ∈ I_r(t) ↔ E_r(s)=Some(t)` and each s occurs once. Protects both soundness and completeness; returning empty inverse is a planted defect.
2. **Successful replacement:** for live distinct s,t, set E_r(s)=t; remove s from its previous target when different; append s to I_r(t) iff absent. All other edges/inverse relative orders remain. Witness [3,2]→[2] and new target[3]; stale-old-inverse and prepend-new-source are falsification designs.
3. **Repeat logical membership:** relating s to its current target preserves E/I projections and inverse order. This is NOT full runtime idempotence: TS still bumps relation version and calls hooks on repeated success.
4. **Total unrelate:** remove only s's existing outgoing edge and corresponding inverse occurrence; absent edge/missing source leave E/I and relation-failure projections unchanged. Unrelate never creates a failure record. Do not assert an empty barrier preserves clocks.
5. **Validation priority and frame:** missing source, then missing target, then forbidden self, then hierarchy cycle (hierarchy only). On rejection E/I and surviving component observations stay unchanged; result contains the exact selected error. General cycles remain allowed. Failure stream effects are handled separately below.
6. **Deferred FIFO:** committed E/I before a barrier excludes queued commands; barrier's final E/I equals left-to-right sequential application of committed commands against each current intermediate state. Failure of one command does not cancel earlier/later successful structural commands. A failed enclosing system publishes no queued commands. Relate-before-spawn versus relate-after-spawn is the finite counterexample to batch-start/batch-end validation.
7. **Ordinary deletion:** deleting source s removes every outgoing edge and every inverse occurrence of s. Deleting target t unrelates its incoming sources without deleting those sources; complete observations of surviving unrelated affine components are preserved. Hierarchy linked deletion is an explicitly different dependent contract.
8. **Failure publication (finite retained domain):** each rejected committed relate appends one `relate` record with the descriptor, source, target and exact error to that descriptor's failure stream, in command order; successful relate/unrelate do not append failure records. Premises include reader registration and no capacity/retention loss. This is not global ordering across different keyed streams, unlimited retention, or SystemFailure equivalence.
9. **Affine frame via observation:** given pure owner-preserving projection `observe : C -> C & V`, V:Data and C:Type, a relation-only operation on surviving components retains the same complete V before/after while threading C once. Rejected operations retain every owner. Despawn intentionally consumes owners of deleted entities. A proof would need the real executable function and a suitable observation/refinement statement, not a Data-only substitute or a universal runtime claim.

No new relation law is approved. Before approval/proof, define executable signatures, falsify exact stated laws with literal instances and reached mutants (stale inverse, inverse-order change, skipped failure publication, lost returned owner), and obtain the existing human law approval. This research does not install falsification tooling or count source descriptions as executed proof tests.

## Linked cleanup / reorder candidates — still unapproved

10. **Entered-frame cleanup trace (finite completed domain):** with valid registered
    descriptors in declaration order and inverse lists consistent with authoritative
    edges, destruction snapshots incoming sources for each descriptor at that
    descriptor's entry. Ordinary sources are unlinked; linked sources recurse in
    the snapshot order. The entered entity's outgoing edge is then unlinked. On a
    completed traversal, actual present component owners are consumed/removed
    once; each entered-live invocation emits its despawn notice even if a nested
    invocation already destroyed that entity. This is deliberately not a unique
    despawn-ID law: the observed accepted two-descriptor cycle emits `[2,1,2]`
    from one entry point. Frame equality is through complete Data observations,
    not duplication/equality of arbitrary-Type component stores. Diagnostic budget
    exhaustion, hooks, unsupported constructors and production termination are
    outside this candidate's completed-domain premise.

11. **Hierarchy reorder observation and refusal priority:** for a nominal hierarchy
    descriptor and live parent, requested children are checked left-to-right:
    missing child, duplicate child, child not related to parent. The resulting set
    must equal the parent's current complete incoming set. Success changes only
    that inverse order; authoritative targets, other inverse lists and surviving
    affine component observations remain. A missing parent wins before child
    validation. On refusal graph/owners stay intact and the exact `reorderChildren`
    error is published at application. Public reorder on ordinary descriptors is
    absent from this candidate; the pinned public TS signature accepts hierarchy
    descriptors only. Runtime versions/hooks are not claimed unchanged.

These are discussion drafts only. The cleanup model/literals and source mutants
are finite falsification attempts; no proof or universal runtime refinement is
approved by a checker or successful trace.
