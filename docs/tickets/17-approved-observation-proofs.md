# P-OBS — approved bounded public-observation proofs

**Published: [GitHub #18](https://github.com/dearlordylord/bendvy/issues/18). Stages 0/1/2 ready; later stages retain their dependency gates.**
[Astra review](../reviews/approved-next-tranche.md). Parent: [#1](https://github.com/dearlordylord/bendvy/issues/1).
Governing [SPEC](../SPEC.md), [semantic audit](../reviews/laws-semantic-audit.md),
[exact subjects](../../experiments/t11-replacement/LAWS.bend) and
[finite evidence](../../experiments/t11-replacement/README.md).
The user approved only the seven IDs below at SHA256
`e0c607d723ad250a189c096d9fa3fd6a36913f4c72efd3a3be6dacd7fadb2cbc`.
Astra subsequently approved the exact live affine owned binder revision and two arithmetic support subjects under explicit user delegation; see [decision](../reviews/delegated-owned-law-approval.md). Twenty internal and two other infrastructure candidates remain unapproved.

## Exact scope and staged delivery

| Stage | Approved subjects | Required reasoning / limits |
|---|---|---|
| 0: feasibility and dependency inventory | Seven IDs, with the separately approved owned binder revision | Pin compiler/Base/source hashes; inspect existing Base/mathlib facts without adding dependencies. Inventory missing sorting/enumeration, command replay, invariant, observation and word-conversion links. Check both an elementary canary and a faithful empty-schedule specialization with an actual proof inhabitant of the erased-owner/conditional proposition shape, including checker and kernel, each <=5 seconds. The old erasure canary only constructs a proposition Type; it does not establish this proof capability. |
| 1: model lookup | `lookup_full_exact` | Prove total scoped lookup with selection, including malformed physical row lists and success/mismatch/missing/foreign cases. This exact equation does not establish unforgeable root authority. |
| 2: model queries (parallel with stage 1) | `query_any_complete_ordered`, `query_present_complete_ordered`, `query_absent_complete_ordered` | Prove complete/unique/ascending results under the exact independent admissibility premise. Connect sorting physical rows to independent `[0,next)` enumeration; do not prove only soundness or reversal invariance. |
| 3: model flush | `explicit_flush_independent` | Prove per-entity FIFO replay against whole-row mutation, including noncommuting actions, survivors, unknown targets and cleared pending commands. Establish the command-prefix invariants needed by the comparison. |
| 4: model schedule | `schedule_execution_exact` | Primitive-step/list induction: immediate Bump, Reserve/Publish and explicit Barrier, with no final implicit flush. Use the public observational relation, not false raw-world equality after independently materialized rows. Establish every needed preservation/adequacy link; a real system/transaction scheduler is outside this theorem. |
| 5: owned runtime (contingent on early feasibility) | `owned_runtime_schedule_correspondence` | Relate actual returned owner observation to independent schedule at every prefix under exact `S.run_safe`. Establish actual inline U32 comparison/increment connections using structural Word reasoning, primitive operation correspondence and observation adequacy. Element-zero payload observation is the theorem's scope; physical identity/full-array preservation is not implied. |

Stages 1–4 are six Nat model theorems; stage 5 is a separate owned-runtime theorem.
The owned-owner feasibility lane runs alongside the Nat lane; it is never a blanket
blocker for lookup/queries. Flush and model schedule depend only on their actual
replay/invariant links; the owned theorem additionally needs its own encoding and
Word links. Stages may deliver separately with explicit unresolved dependencies. No stage is
complete from literal checks, a proposition-construction canary or a finite trace.
If inhabitation/checker time or a needed dependency blocks a stage, record the
minimal reproducible failure and a bounded follow-up without claiming general
impossibility; never alter the approved statement/domain or increase the timeout to obtain a pass.

## Supporting obligations and approvals

Existing proved library facts may be reused with pinned provenance. Genuinely
narrower, contextual proof-local arithmetic/structural lemmas needed by an approved
endpoint may be derived; this does not require approval of every intermediate fact.
List each new proof-local helper and its precise purpose/domain before execution;
contextual derivations must not change the endpoint's policy/domain. Proof decomposition does not authorize turning any of the
other 22 unapproved catalogue statements into filled, assumed or renamed-equivalent contracts.
If a required supporting obligation is equivalent to an unapproved catalogue law,
or adds a standalone semantic/encoding/arithmetic contract beyond the approved
endpoint, present its exact statement,
rationale and falsification for separate approval before proving it. In particular
model preservation, owned-step/projection links, conditional encoder equations and
Nat/U32 bridges are **dependencies to resolve**, not approvals inherited here.
Do not assume global root provenance, full-payload restoration, production numeric
allocation/exhaustion policy or representation-neutral owner preservation.

## Execution and acceptance gates

- [ ] Verify the seven unchanged statement hashes/IDs and record dependency status before proofs. Preserve the historical and 31-law proposal artifacts.
- [ ] Run `bend version` and `bend guide`; use the existing `experiments/t01/bend-check` five-second wrapper for every checker/kernel invocation. Timeouts, unsafe/foreign dependencies, missing verdicts and TODOs in a claimed proof are failures. Do not install a new tool/library without concrete need and approval.
- [ ] Add proofs in a separate package importing the exact approved subjects/functions. Record theorem-specific `ALL PROOFS CHECK`/exit0 evidence; unrelated unapproved TODOs must stay outside each completion entry, not be silently filled or dropped.
- [ ] For each completed theorem retain an original true-premise instance, compiling decision-path mutant and checking control; require the unchanged proof to fail in its intended theorem section on that mutant. An unrelated shared-lemma/type error, false premise or noncompiling mutant does not pass this gate. Preserve the existing fresh falsification controls, including pending-despawn survivors and no implicit flush.
- [ ] Report completed vs blocked IDs, exact proof/source/dependency hashes, commands, diagnostics and limits. Review Standards and Spec before coordinator delivery; no claim about backend/host IO, full ECS runtime, production authority or performance follows from these proofs.

Follow-ups remain explicit: root confinement; arbitrary Type/full-payload relations;
representation-neutral owned reads; selected-reader transaction/retention/lag;
allocator/error policy and integrated scheduler proofs. Integration research may
advance independently where its actual prerequisites exist; these proofs are not
a blanket benchmark or full-core completion gate.

## Delivered progress

| Approved endpoint | Current evidence |
|---|---|
| `lookup_full_exact` | Complete general proof, kernel, seven total/malformed controls and own-endpoint compiling mutant. |
| `query_any_complete_ordered` | Complete general proof, kernel and own-endpoint compiling selection-dispatch mutant. |
| `query_present_complete_ordered` | Complete general proof, kernel and own-endpoint compiling selection-dispatch mutant. |
| `query_absent_complete_ordered` | Complete general proof, kernel and own-endpoint compiling selection-dispatch mutant. |
| `explicit_flush_independent` | Complete general proof, kernel, eight fresh controls and own-endpoint compiling queue-discard mutant. |
| `schedule_execution_exact` | Complete general proof and kernel; two compiling tick mutants fail the dedicated universal endpoint induction with independently active complete-law witnesses. |
| `owned_runtime_schedule_correspondence` | Complete endpoint still open. The exact live affine binder amendment and two support facts are approved under user delegation; their proofs remain outstanding. Original erased-owner signature is historical. |

Reports: [lookup](../../experiments/p-observe-lookup/README.md),
[queries](../../experiments/p-observe-queries/README.md),
[flush](../../experiments/p-observe-flush/README.md),
[schedule](../../experiments/p-observe-schedule/README.md). The completed six
endpoints were independently replayed by Astra and the coordinator and passed
[Spec](../reviews/observation-proof-spec.md) and
[Standards](../reviews/observation-proof-standards.md) review. No original law or
implementation was changed. Lookup's helper inventory chronology deviation and schedule's Bump/enumeration inventory-order deviation are
retained in their reports. Historical partial reports do not override these results.

[Owned construction routes](../../experiments/p-owned-route/README.md) retain
exact diagnostics and the one-binder proposal, SHA256
`8e400d78b08530ff17295fa32190d0cf93b1f4641816d2710506b64a8ae2940b`.
[Supporting arithmetic request](../reviews/owned-arithmetic-approval.md) selects
two unchanged original infrastructure facts at SHA256
`7d4ea7b7c94592c473271cffb8bcd3ec1cb1ff7390f6e1aa5cde9918ad9ce937`.
[Additional original-signature route diagnostics](../../experiments/p-owned-route-alternative/README.md)
test closed templates, delayed closures, live-witness synthesis and uniform-result conversion.
Their expected diagnostic matrix passes; none provides the original general theorem.
Both exact requests were approved by Astra under the user's explicit delegation; the [decision](../reviews/delegated-owned-law-approval.md) pins their hashes and limits. No complete owned theorem or universal impossibility
claim follows from the diagnostic family or structural Word helpers. The remaining 22
catalogue candidates are still unapproved.

Current continuation: prove the two approved arithmetic subjects and the exact revised owned theorem, including its actual prefix/owner links.
The pure schedule uses the checked query and flush links without changing their subjects.
The active execution goal remains **#18, then #19**; six completed laws do not
close #18 or authorize a completion claim for #19.

## Aggregate completion gate

[Seven-endpoint package](../../experiments/p-observe/README.md) mechanically selects all seven exact approved statements and freezes their full canonical import closure. Run `python3 experiments/p-observe/verify.py`: it must eventually pass ordinary checker and kernel, in addition to all per-endpoint mutation/review gates. Current nonzero exit with one TODO preserves the full task boundary; partial runner passes cannot close #18.
