# Agent workflow

Read the applicable branch. The issue and linked spec define acceptance;
[review criteria](../CODING_STANDARDS.md) guide review.

## Bend implementation or proof

Follow bend-ldd. Fix parser/type/affine errors with the five-second
`scripts/bend-check source.bend`; preserve raw success and failure output.
This check grants no proof or delivery acceptance; intermediate templates need
no delivery wrapper or portable capsule.

Complete the consuming fixture within assigned files and agreed contracts.
Hand off unresolved contracts, shared-file changes and backend launches for
review. Freeze source and complete oracle together; run unchanged source,
negative, mutation and backend gates. Check the existing Node adapter and
runnable Bend seam against the whole oracle before broad tool discovery.

API extensions require undeclared-access, cross-schema and write-through-read
negative controls.

## Evidence runners and parallel review

Use the [runner recipe](check-policy.md#preparing-a-focused-runner).
Inventory source, tools, environment, outputs and oracle before launch review.

Lock compiler/runtime/performance children and heavy oracle materialization;
prepare lightweight metadata outside. Use the
[immutable dependency helper](check-policy.md#immutable-dependency-stages):
discover outside the lock, review resolver inventory, statically validate,
then revalidate after acquisition. Preserve pre/post guards and unconditional
failure receipts. Guard generated artifacts before consumption.

Coordinators assign independent available reviewers; record oracle authorship,
launch admission and actual-output review. Reviewers own reports; authors fix
runners. Resume completed authors with `followup_task` after exact-plan admission.
Reviews may overlap; heavy children share the lock and existing caps.

Review routing, execution code and every stage before launch. Re-review code,
input-recipe or gate changes; preserve frozen attempts and in-flight runs.
Continue reviewed stages without intermediate handoffs; coordinators may admit
artifact-only stages matching the reviewed recipe and guarded ledger.

## Approvals

Follow [SPEC](SPEC.md) for laws, numerical performance criteria and dependencies.
Identify each outstanding approval and its reason.

## Query or storage

Read [R-A](../experiments/ra-provider/README.md) and
[R-C1](../experiments/rc1-query/README.md). Support arbitrary `Type` payloads
through Bend types and affine ownership; Data-only components remain unapproved.
Re-test abstract-handle confinement after API changes.

## Executable src/ecs delivery

Run the paired [regression gate](../benchmarks/README.md) and retain its receipt.
Use the committed baseline; baseline/workload changes require review. This gate
qualifies its workload only; SPEC separately governs full-core performance.

## References

Verify read-only, Git-excluded `.references/{bevy-ts,bevy,bend2}` against the
[manifest](../.references/sources.json); use absolute paths in worktrees and
report unavailable sources.

For TS execution, try the existing Node runtime and a Node-only adapter against
the pinned `.ts` entrypoint first. Core needs no external runtime dependencies;
new packages require SPEC approval. Source-derived traces become observed
evidence only after execution. Before rerunning a delivered comparator, apply
the [delivery-manifest selection check](check-policy.md#preparing-a-focused-runner).
