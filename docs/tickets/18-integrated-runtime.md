# S-INTEGRATE — bounded two-schema runtime seam

**[GitHub #19](https://github.com/dearlordylord/bendvy/issues/19). Active: #18 is complete; the reference trace is reviewed. Joined functional gates pass; exact remaining workloads, measurement provenance and final research review are the current gates. Production performance is unmet.**
Parent: [#1](https://github.com/dearlordylord/bendvy/issues/1).
[Astra assessment](../reviews/approved-next-tranche.md).
Governing [SPEC](../SPEC.md), [checkpoint](../next-core-checkpoint.md),
[R-A](../../experiments/ra-provider/README.md), [R-C1](../../experiments/rc1-query/README.md),
[#16 storage evidence](../../experiments/s-layout/README.md),
[#17 capture/restoration evidence](../../experiments/s-capture/README.md),
[law audit](../reviews/laws-semantic-audit.md) and [P-OBS #18](17-approved-observation-proofs.md).
Build one operation-trace seam joining previously separate capabilities; do not
count their old passing reports as this task's acceptance.

## Bounded subject and interfaces

Two explicit nominal schemas (Motion/Health), variable live membership, Data
metadata and genuine affine Type array payloads. A world owner flows through
creation, reserve, lookup/query, declared writes, command publication, explicit
flush and sequential closed-system dispatch. Reads return observations plus their
owner; callbacks receive abstract declared schema-specific handles and fresh
operations, never a writable concrete world. Required/present/absent/optional
queries preserve ascending logical entity order independently of physical slots.

A schedule owns separate instance state. Test both explicit returned-owner state
and once-only closures regenerated from that owner; captured state stays outside
ECS transaction in the reference-compatible lexical scenario. This is not a new
Local policy. Require reversible declared writes: an updated owner plus inverse
or retained prior owner. No callback that irreversibly consumes a payload is
accepted as generally recoverable without an explicit redesign/contract decision.

Storage is an experimental adapter boundary, not an adopted production layout.
#16 improves some indexed kernels but regresses dense/JS paths; its timed churn is
a favorable head case and relocation is untimed. Retain owned-list and indexed
candidates where applicable; dynamic ID→slot/membership mapping must be exercised
if indexing/relocation is used. Compare normalized public results, not physical
row order or exact allocator numbers. The prototype's trusted one-factory lineage,
bounded capacity/no-reuse and word guards are explicit parameters, not production
exhaustion/reuse policy or global unforgeable-root authority.

## First executable step and dependencies

Prepare a small trace specification with exact inputs, schemas, operation order,
barriers, failure/retry, reader positions and expected public observations. Execute
the pinned TS failed-reservation/subsequent-reservation checkpoint to distinguish
consumed IDs from discarded structural publications. Review this trace against
the existing evidence before implementing the integrated Bend subject.

#18 is related proof work, not a blanket start blocker: trace preparation and
source/reference investigation can proceed now. Reuse a proved endpoint only when
its actual subject/domain applies; integration needs fresh capability evidence.
Unresolved observable policy choices gate only their dependent implementation.

## Staged work

1. **Freeze actual seams and observations before code.** Inventory provider/identity/command/transaction/readers/capture functions reused; specify owner-return and rollback obligations. Draft/falsify exact integration laws before implementing their subjects; obtain specific approval before any general proof. Review root construction and destruction boundaries, recording failed or unavailable capabilities instead of narrowing the full core.
2. **Join identity/query/storage.** Create two worlds through one actual threaded factory; reserve→pending→live at explicit barriers; local, mismatch, stale and colliding foreign lookup. Preserve approved foreign MissingEntity divergence in a separate comparison lane. Exercise two schemas and Type payloads through declared callbacks. Test relocation/churn if the candidate uses a map, with complete ascending queries after every lifecycle boundary.
3. **Join system transactions and captures.** A commits component/resource updates and publications. B performs two writes, observes them, allocates/reserves, changes lifecycle marks, reads streams, publishes message/command and fails. Restore B's recoverable ECS-owned payload and discard failed pending structural work/publications; restore the selected reader's observable position and preserve prior lifecycle visibility. Determine allocation consumption from an actual failed-reserve→subsequent-reserve TS checkpoint: pinned `internal/world.ts:316–320` increments `nextEntity` immediately, while `rollbackTransaction:415–424` restores the component journal, not that counter. Do not invent counter rewind/reuse or reissue an escaped reserved handle. If SPEC is interpreted to require rewind, obtain an explicit contract/divergence decision before implementation. Lifecycle marks must preserve observable change/removal reader behavior; raw transaction-generation rewind is not presumed. Retain A's commit and B's reference lexical capture state. Tail does not execute. Retry observes the expected prior stream and commits once. Add a successful structural disposal path and an explicit destructive-restoration negative/control pair.
4. **Join actual readers/provisioning.** Two registered instances run at different rates with separate message and change/removal positions. Cover added/changed/removed/despawn observations, success/failure/retry and skip advancing only the reference-defined positions. Verify registration, chosen reader/boundary, other-reader preservation and nested failure propagation through the real dispatcher. Read retained logs rather than already-deleted rows. Specify and test capacity/retention/lag before claiming these capabilities; #17's retained sequence index is not already a general tick clock.
5. **Verify and measure the seam.** Fresh pinned public TS/Native/JS traces for identical inputs; normalize only incidental physical/ID representation. The failed-allocation consumption checkpoint retains actual reservation/subsequent-ID observations; normalization must not hide exhaustion/reuse/rewind policy. Measure equivalent integrated dense/sparse/update/churn/readers/rollback work with setup/compilation outside steady-state and explicit final observations. Publish ratios, variability and memory-method limits; numerical acceptance thresholds remain unapproved, and material regressions stay visible.

## Acceptance and evidence

- [ ] Exact operation inputs, update order, failure injections, barrier placement, observations and bounded domains are reviewable before implementation. Preserve command FIFO and no implicit structural flush; commit visibility is distinct from application.
- [ ] Fresh checker positive/negative pairs at the actual integrated seam reject undeclared access, cross-schema misuse, writes through read, reconstruction and invalid owner returns for the intended diagnostic. Returned Type owners/full declared payload fields survive reads, updates and failure without Data snapshots/cloning.
- [ ] Fresh three-backend checkpoints establish stages 2–4, including discovered failed-allocation consumption versus discarded spawn, observable lifecycle marks/publication/cursor rollback and earlier commits. Reference-discovered mismatches are resolved explicitly; do not mask them with adapter constants or borrow isolated probe transcripts.
- [ ] Compiling Native/JS mutants break namespace/map/order, attempted write/inverse order, incorrect allocation consumption or reserved-handle reissue, lifecycle visibility/publication rollback, selected/other-reader routing, failed cursor, capture isolation and implicit flush. Each must differ at the intended public checkpoint; timeout/parse/type failures are not killed semantic mutants.
- [ ] Run Bend version/guide and pin compiler/Base/references. Every checker <=5 seconds; distinct build/runtime limits recorded, task-owned process cleanup only. Use existing Node direct imports and dependency-free helpers; no new dependency approved.
- [ ] Record each capability separately as passed/failed/unresolved, exact artifact hashes and two-axis review. A useful bounded negative result completes research while retaining its missing capability and concrete redesign follow-up. Do not declare production integration, performance or universal refinement complete.

## Decisions and retained follow-ups

The user explicitly selected the foreign-command result on 2026-10-04:
`MissingEntity`, with the receiver queue unchanged. E10 must exercise actual
same-schema foreign handles with colliding IDs and preserve receiver observations.
This approves that dependent behavior, not a new general proof, TS parity or
implicit exception/transaction-abort policy. The frozen #18 runtime remains its
separate bounded subject.

Before production acceptance: establish root/handle confinement beyond trusted
single-lineage fixtures; resolve failed-allocation consumption versus any requested rewind/divergence, decide allocator reuse/exhaustion; select a representation from integrated evidence; approve
numerical performance thresholds; define recoverable destructive Type mutation
and general Local lifetime/rollback; approve any new exact laws/dependencies.
None is silently chosen by this draft or the seven bounded theorem approvals.

The simple fixed-step console simulation is the next application only after the
capabilities it uses are verified and its concrete inputs/trace are specified.
Generic schemas/resources, dynamic instance lifetime/conditions/phases/provisioning,
relations/scopes, state failure ordering, restoration/tooling and parallel compute
remain later detailed packages. Tower Defense validation uses a separate copy of
needed `/workspace/typescript/jev` sources; the original repository remains untouched.

## Prerequisite progress

- [Current execution ledger](../design/s-integrate-capability-ledger.md) records delivered actual payload/storage/transaction/reader modules separately from open full-dispatch trace, confinement, retention and measurement gates. #19 remains open.

- [Checked shared vocabulary](../../experiments/s-integrate/README.md) supplies nominal full Type payload/view records and opaque owner-return controls. Actual storage, commands/query, transactions and readers now have separately checked and compiled evidence in the execution ledger. Concrete Host composition, full dispatched observations and integrated access gates remain open. [Astra interface research](../reviews/s-integrate-interface-research.md) and [reader implementation contract](../design/s-integrate-reader-implementation.md) specify the joins.

- [Astra-reviewed shared contracts](../design/s-integrate-contracts.md) distinguish exact trace requirements from proposed owner/transaction/publication/reader/provisioning interfaces. They clarify rejected versus staged Type payload ownership and complete preflight; actual Bend signature checks and runtime implementation remain open.
- [Astra-reviewed execution split](../design/s-integrate-execution.md) records draft module ownership, interface dependencies and staged delivery after #18. It preserves conditional candidate evaluation and incremental controls/mutants; it is planning evidence, not implementation or a new approval gate.

- [Fresh public TS allocation checkpoint](../../experiments/s-integrate-trace/allocation-README.md): actual dispatcher observations establish consumed failed reservation ID3, distinct subsequent ID4, discarded failed spawn, earlier commit/publication retention and explicit barriers. Coordinator and independent Spec/Standards replay pass; scalar one-schema reference scope only.
- [Concrete source seam inventory](../design/s-integrate-seams.md): provider/identity/transaction/reader/capture interfaces and missing ownership joins are recorded. This is planning evidence, not integrated capability acceptance.
- [Concrete E0–E11 trace](../design/s-integrate-trace.md) is a reviewed source-derived plan with exact schema/payload inputs, rollback/reader/capture/barrier checkpoints, controls and public capacity boundaries. Its [execution ledger](../design/s-integrate-trace.md#fresh-reference-execution-ledger--2026-10-04) now separates four fresh main public TS lanes, ten public E11 cases, five internal C3/C0 supplements and scalar X. Coordinator and independent reviews pass; E10 Bend controls (including the now approved foreign-command result/queue rule) and all integrated Native/JS results remain open.
- [Measurement draft](../design/s-integrate-measurement.md) records equivalent workloads, per-schema inputs, timing/memory limits and retained threshold gates. Its executable Bend setup/capacity/clock freeze depends on the integrated subject and parity trace. Slice-level Native/JS traces and mutations are delivered; the full dispatched three-backend trace, integrated access controls and equivalent integrated measurements remain open.

The active implementation order remains #18 then #19. Its separately permitted
trace/reference preparation is delivered; #18 is closed. New exact integration proofs still require their own subject approval.
