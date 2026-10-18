# Agent workflow

The issue and linked spec define acceptance. Apply [SPEC decisions](SPEC.md#implementation-decisions)
and [review criteria](../CODING_STANDARDS.md); Rust Bevy semantics, Bend constraints,
then bevy-ts inventory govern implementation choices.

## Delivery

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
   gates through an existing runner. Batch changes for the unchanged
   [regression gate](../benchmarks/README.md) on the integrated result.
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
