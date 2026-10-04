# S-INTEGRATE — bounded two-schema runtime seam

**Draft for discussion/review; unpublished. No implementation authorized by this draft alone.**
Governing [SPEC](../SPEC.md), [checkpoint](../next-core-checkpoint.md),
[R-A](../../experiments/ra-provider/README.md), [R-C1](../../experiments/rc1-query/README.md),
[#16 storage evidence](../../experiments/s-layout/README.md),
[#17 capture/restoration evidence](../../experiments/s-capture/README.md),
[law audit](../reviews/laws-semantic-audit.md) and [proof draft](17-approved-observation-proofs.md).
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

## Staged work

1. **Freeze actual seams and observations before code.** Inventory provider/identity/command/transaction/readers/capture functions reused; specify owner-return and rollback obligations. Draft/falsify exact integration laws before implementing their subjects; obtain specific approval before any general proof. Review root construction and destruction boundaries, recording failed or unavailable capabilities instead of narrowing the full core.
2. **Join identity/query/storage.** Create two worlds through one actual threaded factory; reserve→pending→live at explicit barriers; local, mismatch, stale and colliding foreign lookup. Preserve approved foreign MissingEntity divergence in a separate comparison lane. Exercise two schemas and Type payloads through declared callbacks. Test relocation/churn if the candidate uses a map, with complete ascending queries after every lifecycle boundary.
3. **Join system transactions and captures.** A commits component/resource updates and publications. B performs two writes, observes them, allocates/reserves, changes lifecycle marks, reads streams, publishes message/command and fails. Restore B's ECS-owned payload, allocator state, marks, pending commands, staged publications and selected cursors; retain A's commit and B's reference lexical capture state. Tail does not execute. Retry observes the expected prior stream and commits once. Add a successful structural disposal path and an explicit destructive-restoration negative/control pair.
4. **Join actual readers/provisioning.** Two registered instances run at different rates with separate message and change/removal positions. Cover added/changed/removed/despawn observations, success/failure/retry and skip advancing only the reference-defined positions. Verify registration, chosen reader/boundary, other-reader preservation and nested failure propagation through the real dispatcher. Read retained logs rather than already-deleted rows. Specify and test capacity/retention/lag before claiming these capabilities; #17's retained sequence index is not already a general tick clock.
5. **Verify and measure the seam.** Fresh pinned public TS/Native/JS traces for identical inputs; normalize only incidental physical/ID representation. Measure equivalent integrated dense/sparse/update/churn/readers/rollback work with setup/compilation outside steady-state and explicit final observations. Publish ratios, variability and memory-method limits; numerical acceptance thresholds remain unapproved, and material regressions stay visible.

## Acceptance and evidence

- [ ] Exact operation inputs, update order, failure injections, barrier placement, observations and bounded domains are reviewable before implementation. Preserve command FIFO and no implicit structural flush; commit visibility is distinct from application.
- [ ] Fresh checker positive/negative pairs at the actual integrated seam reject undeclared access, cross-schema misuse, writes through read, reconstruction and invalid owner returns for the intended diagnostic. Returned Type owners/full declared payload fields survive reads, updates and failure without Data snapshots/cloning.
- [ ] Fresh three-backend checkpoints establish stages 2–4, including allocation/marks/publication/cursor rollback and earlier commits. Reference-discovered mismatches are resolved explicitly; do not mask them with adapter constants or borrow isolated probe transcripts.
- [ ] Compiling Native/JS mutants break namespace/map/order, attempted write/inverse order, rollback allocation/marks/publications, selected/other-reader routing, failed cursor, capture isolation and implicit flush. Each must differ at the intended public checkpoint; timeout/parse/type failures are not killed semantic mutants.
- [ ] Run Bend version/guide and pin compiler/Base/references. Every checker <=5 seconds; distinct build/runtime limits recorded, task-owned process cleanup only. Use existing Node direct imports and dependency-free helpers; no new dependency approved.
- [ ] Record each capability separately as passed/failed/unresolved, exact artifact hashes and two-axis review. A useful bounded negative result completes research while retaining its missing capability and concrete redesign follow-up. Do not declare production integration, performance or universal refinement complete.

## Decisions and retained follow-ups

Before production acceptance: establish root/handle confinement beyond trusted
single-lineage fixtures; decide allocator reuse/exhaustion and foreign-command
observable result; select a representation from integrated evidence; approve
numerical performance thresholds; define recoverable destructive Type mutation
and general Local lifetime/rollback; approve any new exact laws/dependencies.
None is silently chosen by this draft or the seven bounded theorem approvals.

The simple fixed-step console simulation is the next application only after the
capabilities it uses are verified and its concrete inputs/trace are specified.
Generic schemas/resources, dynamic instance lifetime/conditions/phases/provisioning,
relations/scopes, state failure ordering, restoration/tooling and parallel compute
remain later detailed packages. Tower Defense validation uses a separate copy of
needed `/workspace/typescript/jev` sources; the original repository remains untouched.
