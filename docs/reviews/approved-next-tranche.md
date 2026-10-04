# Approved next tranche — Spec review

Reviewed the P-OBS and S-INTEGRATE drafts against SPEC, the current checkpoint,
[seven-ID approval](laws-replacement-package.md) and
[semantic audit](laws-semantic-audit.md). Final reviewed draft revision:
`823036c`, integrated unchanged into master at `9240378`.

**P-OBS is ready for publication and stages 0/1/2 can start.** It preserves the
seven exact subjects at SHA256
`e0c607d723ad250a189c096d9fa3fd6a36913f4c72efd3a3be6dacd7fadb2cbc`.
The remaining 24 candidates stay unapproved. Lookup and query proofs can proceed
independently; flush/schedule require their actual replay and invariant links.
Owned-schedule proof has a separate early feasibility gate and does not block the
six pure model endpoints.

The feasibility gate requires an actual proof inhabitant, including a faithful
empty-schedule conditional specialization, rather than merely constructing a
proposition Type. A failed attempt records a bounded obstacle, not language-wide
impossibility. Ordinary genuinely narrower contextual proof-local lemmas are
permitted; assuming, filling or renaming an equivalent unapproved catalogue law
is not. The unchanged endpoint, five-second checker/kernel limits and own-theorem
mutation failures remain completion gates. Observational induction is correctly
distinguished from raw physical-row equality and full-payload preservation.

**S-INTEGRATE should remain a draft until its concrete trace is reviewed.** Its
two-schema/provider/Type/readers/transaction composition is a suitable bounded
next research subject, with no production layout or performance acceptance.
The initial policy blocker is corrected in `823036c`: unconditional allocator rewind
after failed reservation. Pinned TS `internal/world.ts:316–320` consumes the next
ID immediately; `415–424` restores journaled component values without rewinding
that allocator. The revised draft requires an actual failed-reservation/subsequent-reservation
checkpoint, distinguishes discarded publications/liveness from ID consumption,
and gates any intended divergence explicitly. ID normalization must not conceal
reuse or aliasing of escaped failed-reservation handles. Lifecycle rollback must
constrain public change/removal visibility rather than demand equality of private
transaction-generation bookkeeping. No remaining drafting blocker was identified;
the concrete integration-trace gate remains open before execution/publication.

No proof, benchmark or new reference execution was performed for this review.
The allocator finding is source-derived until the requested checkpoint executes.
Full root authority, arbitrary destructive restoration, general Local policy,
selected-reader refinement, numerical thresholds and untouched original `jev`
remain explicit boundaries. This review grants no additional law approval.
