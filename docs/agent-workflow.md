# Agent workflow

Read only the branches triggered by the task. The governing issue and linked specification define acceptance; [review criteria](../CODING_STANDARDS.md) guide judgement.

## Bend implementation or proof

Follow the bend-ldd skill.

Fix parser/type/affine-binder errors with the five-second
`scripts/bend-check source.bend`; retain raw output, including failures.
This development check grants no proof or delivery acceptance; intermediate
templates need no delivery wrapper or portable capsule.

Within assigned files and agreed contracts, continue through the complete
consuming fixture, reporting intermediate milestones as progress. Hand off at
unresolved contracts, shared-file boundaries or separately reviewed backend
launches. When ready, freeze consuming source and complete oracle together;
run the task's unchanged source, negative, mutation and backend delivery gates.

Before broad installed-tool discovery, check the existing Node adapter and
runnable Bend seam against the complete observation oracle; resolve
behavior/oracle errors first.

API changes require negative controls for undeclared access, cross-schema
misuse and writes through read.

## Evidence runner development

Use the development checks above for application work and the
[focused runner recipe](check-policy.md#preparing-a-focused-runner) for frozen
delivery. Complete source, tool, environment, output and oracle inventories
before execution review.

For new collectors, lock only the compiler/runtime/performance child; prepare
immutable inputs and metadata-only probes outside the lock. Use the existing
[immutable dependency stage](check-policy.md#immutable-dependency-stages)
helper with a reviewed resolver inventory: discover outside the lock, then
statically check and revalidate the launch boundary after acquisition.
Retain full pre/post validation and unconditional failure receipts.

Review collector routing, execution code and all stages before launch.
Guard generated artifacts in the output ledger before consumption; continue
without intermediate handoffs. Re-review code, input-recipe or gate-scope
changes; preserve frozen attempts and in-flight runs. The coordinator may
admit artifact-only stages by checking exact plans against the reviewed
recipe and guarded output ledger.

## Parallel review routing

The coordinator assigns ready launch reviews to independent available agents.
Record oracle authorship, launch admission and actual-output review for each
frozen cohort. Reviewers own evidence reports; implementation authors repair
runners. Resume completed implementation agents with `followup_task` when
their exact plans are admitted. Reviews may overlap; compiler/runtime/performance
children retain the shared heavy-work lock and existing caps.

## Approval requirements

Follow [SPEC](SPEC.md) approval requirements for specific laws, numerical performance thresholds and new dependencies. Report each exact outstanding request and its reason.

## Query or storage extension

Read [R-A](../experiments/ra-provider/README.md) and [R-C1](../experiments/rc1-query/README.md) before extending query/storage.

Support arbitrary `Type` payloads through Bend types and affine ownership;
Data-only components remain unapproved. Re-test abstract-handle confinement
after API extensions.

## Executable src/ecs delivery

Run the paired regression gate in [benchmarks/README.md](../benchmarks/README.md) before delivery and retain its receipt. Use the committed baseline contract; baseline or workload changes require explicit review. This gate qualifies its named workload only; full-core performance qualification remains separate under SPEC.

## Reference inspection or execution

Read-only, Git-excluded checkouts `bevy-ts`, `bevy` and `bend2` live under `/workspace/formal-proofs/bendvy/.references/`. Verify commits against the [manifest](../.references/sources.json). Use absolute paths in isolated worktrees; document unavailable references.

For TS execution, check the existing Node runtime first and try a Node-only adapter against the pinned `.ts` entrypoint. Core has no external runtime dependencies. New packages still require SPEC approval when concretely necessary. Source-derived traces become observed evidence only after their actual checkpoints run.

For a previously delivered comparator, follow the delivery-manifest selection
check in [check policy](check-policy.md#preparing-a-focused-runner) before
preparing another execution.
