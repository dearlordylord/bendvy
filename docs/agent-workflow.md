# Agent workflow

The issue and linked spec define acceptance. Apply [SPEC decisions](SPEC.md#implementation-decisions)
and [review criteria](../CODING_STANDARDS.md); Rust Bevy semantics, Bend constraints,
then bevy-ts inventory govern implementation choices.

Current priority: finish capabilities and public API documentation under the
[SPEC priority amendment](SPEC.md#current-delivery-priority--user-amendment-2026-10-20-utc).
Performance campaigns, profiling/compiler tuning and numerical #28 acceptance are
deferred; resume only on explicit user request. Keep correctness and normal CI.

## Delivery

User override (2026-10-28): use Python or JavaScript for temporary automation,
generators, diagnostics and finite observation comparisons when that simplifies
the work. Rewrite ad hoc orchestration in these languages rather than maintaining
fragile shell sequences. Scrutinize each helper's complete source, inputs and
claims before trusting its result, and scrutinize its result against the actual
consumer. Record the source hash and findings, then delete the temporary helper
after its last use. Keep necessary outputs and failure evidence. Temporary helpers
must be gone before delivery; retain existing maintained infrastructure.
These finite checks do not replace approved Bend LAWS/PROOF. Existing exact law
approvals retain their scope; new laws still require their specific approval.

Source checks and ordinary builds have no wall deadline by default. The source
wrapper accepts an explicit `BENDVY_SOURCE_TIMEOUT_SECONDS` only when requested.
Preserve CPU/heavy ownership locks. Decide how to handle a slow check from its
effect on development and users, with sub-agent consultation when available.
Time spent alone is neither a failure nor a reason to add more gates.

1. Read the current consumer and evidence; identify the exact missing acceptance
   gate. Check affected-file history before repeating a performance candidate. Before freezing backend plans, trace each operation to its changed state,
   complete observation and independently derived oracle, including IO effects.
   Reconcile physical indexing, retention boundaries and owner state with the
   model before freezing plans; use the existing review, not a separate admission.
   Reuse qualified evidence. For automatic features, verify the ordinary user
   entry supplies the behavior before preparing large backend evidence. Reuse
   qualified scenarios and assigned worktrees/file ownership. Stabilize the ordinary entry with concrete independent
   consumers before adapting dependent capabilities to its interface.
2. Implement the agreed contract. Follow bend-ldd for Bend; use
   `scripts/bend-check source.bend` for parser/type/affine repairs. Use the lightweight pinned check for development repairs, retaining diagnostics;
   older worktrees invoke the current master wrapper by absolute path;
   freeze acceptance plans after source success. API changes require undeclared-access, cross-schema, write-through-read and relevant
   abstract-handle confinement controls with arbitrary affine `Type` payloads.
3. Before preparing a multi-scenario qualification package, execute one complete
   ordinary consumer on every required backend against its full oracle, or reuse
   matching qualified evidence under [check policy](check-policy.md). If a backend
   is blocked, resolve that blocker within this capability; continue independent
   capabilities. Prepare additional scenarios only when needed to diagnose it.
   After all required backends pass, prepare the remaining affected
   gates through an existing runner. Batch necessary correctness checks on the integrated result; numerical
   [performance qualification](../benchmarks/README.md) follows the current SPEC priority.
4. Deliver exact commit, owned files, source-bound receipts, complete outputs and
   remaining gates for one independent final Spec/Standards review. Coordinator
   integrates and updates the owning issue. A bounded slice is reported as such.
   Fold routine status-only notes into the next suitable delivery commit; avoid
   separate documentation/CI cycles when no immediate correction is needed.

New observable contracts, laws, dependencies and numerical criteria follow SPEC
approval requirements. New/changed runners, compiler experiments and comparative
performance plans need the launch review defined in check policy. Existing
reviewed execution paths use final review without repeated stage admissions.

## References and storage

Verify read-only `.references/{bevy-ts,bevy,bend2}` against the
[manifest](../.references/sources.json); worktrees use absolute reference paths.
For TS execution, reuse the selected
Node adapter and delivery receipt before discovering new tooling. Source-derived
traces count as observations only after actual execution.

## Coordination

Keep current program state in one `checkpoint.json`. Use
`scripts/program-status.py CHECKPOINT` to derive counts and the live integration
HEAD; use its update options for accepted completion and in-work changes.
Completion reports and logs are evidence, not additional current-status stores.
Todos contain remaining actions; gates contain approvals; neither repeats current
counts, HEAD or running-stage narratives. Mark old snapshots historical.
The coordinator is the sole checkpoint writer. Report process liveness only from
an actual process/session handle; a checkpoint cannot establish liveness.

Use the shared runner's `StageCache` for resumable command sequences. Declare
each stage's source/tool/input closure and outputs. Successful matching stages
with intact artifacts are reused; failures and old attempts remain recorded.
After a source-grounded oracle correction, rerun its comparison and continue the
unrun stages without repeating unchanged successful emission or execution.
Run an already authorized sequence to its terminal result without manual
coordinator approval between stages. Stop on an actual failure and diagnose it;
new scope, new laws and changed acceptance criteria keep their existing gates.

Keep one owner for shared `src/ecs`; preserve other workers' changes and running
stages. Create new focused worktrees with `git worktree add --no-checkout`, then
set sparse checkout and run `git read-tree -mu HEAD` inside the new worktree to
materialize owned files and required dependencies. Reuse
immutable absolute dependency paths where supported by the runner. Resume a
completed agent with `followup_task`; use messages for agents already running.
Execution budgets follow [execution limits](limits.md); record increases there.
Parallelize authoring/research/review. Serialize source checks pinned to the same
CPU across all worktrees; `scripts/bend-check` acquires shared locks for its
allowed CPUs before starting the selected compiler budget. Use
disjoint CPU assignments for parallel checks; an unpinned check locks its full
affinity set. Queue wait still counts toward any enclosing caller deadline. Serialize heavy checks and reserve
performance cohorts exclusively under current resource limits. Ordinary runs use
the runner’s internal lock; a terminal result and release from the preceding
owner suffice to start the next admitted run. Follow the
[current coordination table](parity/README.md#current-delivery-coordination).

Experiments are disposable: follow [temporary storage policy](../experiments/README.md).
Keep only current runnable fixtures with an explicit consumer in test-fixtures;
remove completed temporary work instead of committing execution archives.
