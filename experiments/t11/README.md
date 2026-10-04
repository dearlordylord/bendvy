# T11 — first concrete law package (draft for discussion and approval)

[Issue #12](https://github.com/dearlordylord/bendvy/issues/12), [SPEC](../../docs/SPEC.md).

**Draft, unapproved, unproved.** This package proposes 14 general laws in
[LAWS.bend](LAWS.bend); no PROOF.bend is written. Eleven concern the separate pure
identity/query/command model; three concern actual Data cursor functions from
T07/T08. Neither model laws nor cursor-function laws prove the owned ECS runtime.

## Exact subjects, rationale and proof sketches

| Law | Subject / guarantee and reason | Finite controls / compiling defect | Proposed proof |
| --- | --- | --- | --- |
| query_any_exact | M.query returns every row in existing order, with identical data; excludes empty-output false success | Empty, single/mixed tags, reversed ID order; Any rejects rows | Structural induction on rows |
| query_present_exact | M.query equals independent tag-present filtering, preserving complete values/order | Both tags and mixed lists; accept everything | Induction plus Bool cases; exact equality gives soundness and completeness |
| query_absent_exact | Exact tag-absent counterpart; no untagged row omitted | Empty/all/mixed/reordered; inverted selection | Same induction with negation cases |
| foreign_lookup_guard | M.lookup_guard(False) always Missing for every slot/selection/list | Empty and colliding live IDs; foreign guard resolves locally | Bool case/reflexivity; wrapper comparison linkage is a separate obligation |
| foreign_command_guard | M.enqueue_guard(False) preserves every World field; foreign work cannot be queued | Varied IDs/counters/rows/queues; foreign command is appended | Bool case; wrapper identity linkage remains separate |
| reserve_projection | Available branch reserves old next, increments once, preserves rows, prepends exactly one pending spawn | Zero/nonzero counters and existing queue/rows; handle uses incremented ID | Constructor unfolding; allocator availability/bounds require separate wrapper law |
| reserve_rejection | Unavailable branch preserves counter, live rows and pending queue | Empty/nonempty worlds; rejected counter increments | Constructor unfolding; no inference that every input is admissible |
| bounded_reservation | Under next<=limit, M.reserve_until preserves next<=limit for success and rejection; bounds are not inferred from counters alone | Zero/exact/exhausted limits, true and false premises; increment twice at the boundary | Nat order successor lemma and availability cases; actual U32 projection remains separate |
| flush_fifo_projection | Model flush applies reversed prepended queue and empties it, preserving world ID/next | Noncommuting Spawn/Tag and Tag/Despawn; missing reverse | Constructor unfolding; apply/helper semantics must separately be pinned |
| tick_preserves_pending | Empty schedule is exact identity on all model World fields | Nonempty pending queue; tick flushes implicitly | Unfold identity |
| despawn_exact | M.apply Despawn equals independent stable slot removal, preserving all survivors | Absent/present IDs and reordered rows; clears tag instead of removing | Induction on rows, Nat equality cases |
| message_failure_position | Actual E.complete(False) leaves cursor and registration unchanged | Zero/max-U32 positions; failure completes cursor | Bool case/reflexivity |
| message_skip_position | Actual E.skip sets last=current and preserves registration | Zero/max-U32 boundary combinations; skip leaves old cursor | Cursor case/unfold complete_success |
| lifecycle_failure_position | Actual C.complete(False) preserves both change and message positions plus registration | Distinct positions and max registration; failure advances both | Bool case/reflexivity |

Model inputs are general Data lists/Nat values for these law statements. The
runtime correspondence below restricts application to reachable states; laws
about a supplied availability/equality Bool do **not** prove that callers compute
that Bool correctly. Flush uses apply_all: its statement alone does not protect
helpers. Despawn and query helpers have exact laws; Spawn/Tag, collision lookup,
allocator bounds and the complete transition relation remain explicit obligations.

## Falsification and limits

```
python3 experiments/t11/falsify.py
# Optional separate CPU while other builds run:
BENDVY_LAWS_CPU=10 python3 experiments/t11/falsify.py
```

The executed package passes 330 literal original controls and detects all 14
separately typechecking mutants. Every rejection names its own law instance.
An additional foreign-guard model control is freshly compiled/executed on native
and JS: original Missing (0), mutant Found (2). This one runtime instance does
not prove owned-world correspondence or backend correctness.

The local dependency-free generator reads the exact general law statements and
substitutes their binders with recorded literal catalogs. It checks the original
instances under five-second deadlines, typechecks each planted defect, then
requires an expected/observed mismatch in that law's own `probe_<law>` definition.
It never uses an unproved law as evidence. [falsification.json](falsification.json)
records every substitution and rejection. Finite literal `{==}` controls are not
general ECS proofs. Empty, presence/absence, noncommuting command order, unknown
IDs, existing state, distinct positions and U32 boundary values are represented.
Large Cartesian products use fixed-seed samples plus binder-wise boundary coverage;
no claim that every combination or every premise was tested.

External lawcheck/bend-falsify compatibility is still unverified and neither tool
has been adopted. This is a local literal falsifier, not an external-tool pass.
No cases were silently skipped or accepted after error. Adopting those tools and
any required runtime/dependency needs a concrete approval and compatibility controls
before using that tool as a proof/mutation gate.

## Runtime/model correspondence obligations

| Boundary | Mapping / admissibility | Unproved correspondence required |
| --- | --- | --- |
| T05 identity | U32 world/slot/next -> same Nat values; one trusted Factory lineage; next <= max U32; distinct live slots < next; handle token keeps schema/world | Creation yields distinct namespaces across the supported lineage; comparison rejects foreign runtime worlds; unrelated roots remain an open production policy |
| Rows/query | Ordered affine T05 A.Rows -> ordered M.Row(slot, position projection, tag presence); decimal keys decode to unique reserved slots; arbitrary user labels are separate | Provider traversal equals mapped query; consumes/returns exactly the same owned world; no authority or affine payload claim follows from copying projections |
| Pending queue | T05 newest-first Spawn/Insert/Remove/Despawn -> model Spawn/Tag(True)/Tag(False)/Despawn | Reservation/queue publication preserve mapping; flush reverses exactly once and applies commands in order; unknown IDs harmless; generation/reuse are not modeled |
| Bounds | At exhaustion next=max rejects unchanged; successful reservation requires next<max; Nat has no wrap | Compare branch is correct, increments do not wrap, boundary before indexed access; executable boundary controls are finite evidence only |
| Transactions | T06 inverse journal owns arrays; T08 restores Data row values/marks; no transaction state in identity model | Separate reversible-field journal laws, prior commit preservation and publication isolation; allocation/Type payload/IO capture require additional model and ownership obligations |
| Reader cursors | E.Cursor and C.Reader laws are on exact executable Data functions | Owned wrappers select the right reader, preserve other slots, register/hold/trim correctly and use the correct tick; type/access and runtime refinement are unproved |
| Schedule/provisioning | T09 is a distinct executable callback/provider module | Trace order, first failure, provided capabilities and captured state require separate laws; identity laws do not cover them |

The intended universal refinement theorem requires initial-state mapping,
one-step commutation for each admissible operation, admissibility preservation,
and equality of observable results. Then induction on traces gives correspondence.
The package does **not** contain that theorem or its proof. Existing finite T05,
T06, T07, T08, T09 comparisons cannot replace it or compiler/backend correctness.

## Proposed proof packages and dependency boundaries

These IDs are local drafts, not published ready-for-agent tickets:

- P-ID: approve model identity/reservation/tick statements; add wrapper equality,
  availability and capacity bounds before proving the full identity contract.
- P-Q: approve exact query laws; prove filtering plus stable order; separately
  approve provider ownership/access and executable projection correspondence.
- P-CMD: approve flush/despawn statements; add Spawn/Tag/unknown-ID helper laws,
  admissibility preservation and transition correspondence before command parity.
- P-TX: specify actual T06 begin/set/undo/finish with reversible owned-field
  admissibility, prior commit preservation and isolated publication. No benchmark
  dependency; general affine restoration waits for its representation evidence.
- P-READ: the three executable cursor statements are reviewable now. Add success,
  reader independence, different skip contracts, exact retention/lag and per-record
  versus per-batch capacity statements on actual T07/T08 wrappers before proving
  their runtime contracts. Keep owned-world/refinement obligations separate.
- P-PROVIDE: use actual T09 definitions to specify nested ordering, first failure
  and closed callback provisioning; captured/IO closure support remains a gate.

Approval should name exact law IDs and revision. No blanket approval is assumed.
The ordinary T12 checkpoint reviews these packages together with measured storage
costs and a concrete simulation/remaining-core specification before publication.
