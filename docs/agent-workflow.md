# Agent workflow

The issue and linked spec define acceptance. Apply [SPEC decisions](SPEC.md#implementation-decisions)
and [review criteria](../CODING_STANDARDS.md); Rust Bevy semantics, Bend constraints,
then bevy-ts inventory govern implementation choices.

## Delivery

1. Read the current consumer and evidence; identify the exact missing acceptance
   gate. For automatic features, verify the ordinary user entry supplies the behavior
   before preparing large backend evidence. Reuse qualified scenarios and assigned
   worktrees/file ownership. Stabilize the ordinary entry with concrete independent
   consumers before adapting dependent capabilities to its interface.
2. Implement the agreed contract. Follow bend-ldd for Bend; use
   `scripts/bend-check source.bend` for parser/type/affine repairs. API changes
   require undeclared-access, cross-schema, write-through-read and relevant
   abstract-handle confinement controls with arbitrary affine `Type` payloads.
3. Run the cheapest complete consumer, then affected required gates through an
   existing runner under [check policy](check-policy.md). Batch changes for the
   unchanged [regression gate](../benchmarks/README.md) on the integrated result.
4. Deliver exact commit, owned files, source-bound receipts, complete outputs and
   remaining gates for one independent final Spec/Standards review. Coordinator
   integrates and updates the owning issue. A bounded slice is reported as such.

New observable contracts, laws, dependencies and numerical criteria follow SPEC
approval requirements. New/changed runners, compiler experiments and comparative
performance plans need the launch review defined in check policy. Existing
reviewed execution paths use final review without repeated stage admissions.

## References and storage

Verify read-only `.references/{bevy-ts,bevy,bend2}` against the
[manifest](../.references/sources.json); worktrees use absolute reference paths.
For query/storage changes, read [R-A](../experiments/ra-provider/README.md) and
[R-C1](../experiments/rc1-query/README.md). For TS execution, reuse the selected
Node adapter and delivery receipt before discovering new tooling. Source-derived
traces count as observations only after actual execution.

## Coordination

Keep one owner for shared `src/ecs`; preserve other workers' changes and running
stages. Create new focused worktrees with `git worktree add --no-checkout`, then
materialize owned files and required dependencies with sparse checkout. Reuse
immutable absolute dependency paths where supported by the runner. Resume a
completed agent with `followup_task`; use messages for agents already running.
Parallelize authoring/research/review; serialize heavy checks and reserve
performance cohorts exclusively under current resource limits. Follow the
[current coordination table](parity/README.md#current-delivery-coordination).
