# P-OBS — approved bounded public-observation proofs

**Delivered: all seven exact endpoints, mutation gates and both reviews pass. [GitHub #18](https://github.com/dearlordylord/bendvy/issues/18) closure is coordinator-owned.**
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
| 0: feasibility and dependency inventory | Seven IDs, with the separately approved owned binder revision | Pin compiler/Base/source hashes; inspect existing Base/mathlib facts without adding dependencies. Inventory missing sorting/enumeration, command replay, invariant, observation and word-conversion links. Check both an elementary canary and a faithful empty-schedule specialization with an actual proof inhabitant of the separately approved affine-owner/conditional proposition shape (original erased-owner diagnostics remain historical), including checker and kernel, each <=5 seconds. The old erasure canary only constructs a proposition Type; it does not establish this proof capability. |
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

- [x] Exact seven IDs, original revision and sole separately approved affine binder amendment are mechanically verified by [aggregate verifier](../../experiments/p-observe/verify.py). Original/proposal files remain frozen. Dependency inventories and disclosed chronology deviations are retained in package reports.
- [x] Version/guide and compiler/Base provenance are recorded. Six model endpoints use the existing five-second wrapper; the owned endpoint and aggregate use the [reviewed task-local repair](../reviews/owned-checker-local-use.md), with identical Base, unchanged installed kernel and the same hard five-second checker/kernel limit. Installed checker stack failure remains a negative baseline; no tool/dependency was installed.
- [x] Separate exact-law proof packages contain complete general proofs, without unrelated catalogue TODOs. [Aggregate evidence](../../experiments/p-observe/evidence.json) records exit0, CHECK PASS and KERNEL PASS for all seven; package evidence records the six original ALL PROOFS CHECK results and full owned proof verdict.
- [x] Each endpoint retains original true-domain controls and compiling actual decision-path mutants rejecting unchanged proofs at their endpoint/dedicated induction. Lookup/query/flush/schedule evidence and [owned candidate evidence](../../experiments/p-approved-owned-schedule/candidate-evidence.json) retain exact diagnostics; pending work/no implicit flush and FIFO survivor controls remain active.
- [x] Exact hashes, commands, diagnostics and limits are recorded; independent [Spec](../reviews/observation-proof-spec.md) and [Standards](../reviews/observation-proof-standards.md) reviews pass. [Completion audit](../reports/p-observe-completion.md) distinguishes this bounded proof delivery from full ECS runtime/performance acceptance.

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
| `owned_runtime_schedule_correspondence` | Complete exact approved affine theorem, unchanged kernel, mixed/false-domain controls and two compiling tick mutants rejected at dedicated induction. Reviewed task-local source repair is used; installed normalization failure remains historical evidence. |

Reports: [lookup](../../experiments/p-observe-lookup/README.md), [queries](../../experiments/p-observe-queries/README.md), [flush](../../experiments/p-observe-flush/README.md), [schedule](../../experiments/p-observe-schedule/README.md), [owned](../../experiments/p-approved-owned-schedule/README.md). All seven are independently replayed and pass both review axes. Lookup and schedule inventory-order deviations remain disclosed; this delivery does not claim perfect chronology.

The original erased-owner diagnostics, partial checkpoints, stack failures and preserved-draft history remain in their reports. The separately approved binder revision changes only world quantity; original predicates/domains/core remain frozen. Two approved universal arithmetic proofs and contextual Word/safety/primitive/owner links now compose into full correspondence. The other 22 catalogue candidates remain unapproved.

## Aggregate completion gate

Run `python3 experiments/p-observe/verify.py --source-checker`: all seven exact endpoints pass the reviewed local source checker and unchanged kernel. Default installed mode still exits1 on its reproduced normalization bug. The [scoped decision](../reviews/owned-checker-local-use.md) authorizes this reversible local repair, without global installation or production compiler adoption. Endpoint mutation/review gates and this acceptance audit are delivered; coordinator reporting/closure remains the final tracker action. Next work is #19's concrete integration prerequisites, not broader proof approval or runtime/performance acceptance.
