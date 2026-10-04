# P-OBS — approved bounded public-observation proofs

**Published: [GitHub #18](https://github.com/dearlordylord/bendvy/issues/18). Stages 0/1/2 ready; later stages retain their dependency gates.**
[Astra review](../reviews/approved-next-tranche.md). Parent: [#1](https://github.com/dearlordylord/bendvy/issues/1).
Governing [SPEC](../SPEC.md), [semantic audit](../reviews/laws-semantic-audit.md),
[exact subjects](../../experiments/t11-replacement/LAWS.bend) and
[finite evidence](../../experiments/t11-replacement/README.md).
The user approved only the seven IDs below at SHA256
`e0c607d723ad250a189c096d9fa3fd6a36913f4c72efd3a3be6dacd7fadb2cbc`.
The other twenty internal and four infrastructure candidates remain unapproved.

## Exact scope and staged delivery

| Stage | Approved subjects | Required reasoning / limits |
|---|---|---|
| 0: feasibility and dependency inventory | All seven, unchanged | Pin compiler/Base/source hashes; inspect existing Base/mathlib facts without adding dependencies. Inventory missing sorting/enumeration, command replay, invariant, observation and word-conversion links. Check both an elementary canary and a faithful empty-schedule specialization with an actual proof inhabitant of the erased-owner/conditional proposition shape, including checker and kernel, each <=5 seconds. The old erasure canary only constructs a proposition Type; it does not establish this proof capability. |
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
other 24 catalogue statements into filled, assumed or renamed-equivalent contracts.
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

`lookup_full_exact` is proved in [the exact selection package](../../experiments/p-observe-lookup/README.md). General checker/kernel verdicts, seven fresh total/malformed controls, a compiling always-Missing mutant failing the unchanged endpoint, and kernel negative control were independently rerun by Astra and the coordinator. [Spec review](../reviews/observation-proof-spec.md) and [Standards review](../reviews/observation-proof-standards.md) pass. Helper-purpose inventory was documented after development; the package records this process deviation. The other six endpoints remain open; #18 must not close.

[Erased-owner feasibility](../../experiments/p-observe-feasibility/README.md) records eight expected outcomes and no correspondence theorem: faithful empty/barrier reflexivity attempts fail at unresolved conditional obligations, without an impossibility claim.

The [query lane](../../experiments/p-observe-queries/README.md) has independently rerun contextual checker/kernel proofs and two contextual mutation controls. **Zero complete query endpoints are proved.** The exact nonempty sorting/enumeration residual and reviewed continuation inventory are preserved; this is progress, not endpoint acceptance.
