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

Use the checks above for application development and the
[runner recipe](check-policy.md#preparing-a-focused-runner) for frozen delivery.
Inventory source, tools, environment, outputs and oracle before execution review.

For new collectors, lock compiler/runtime/performance children and heavy oracle
materialization; prepare lightweight immutable metadata outside. Use the
[immutable dependency helper](check-policy.md#immutable-dependency-stages)
with a reviewed resolver inventory: discover outside the lock; statically check
and revalidate the launch boundary after acquisition. Keep full pre/post
validation and unconditional failure receipts.

Review routing, execution code and all stages before launch. Guard generated
artifacts in the output ledger before consumption; continue without intermediate
handoffs. Re-review code, input-recipe or gate-scope changes; preserve frozen
attempts and in-flight runs. Coordinators may admit artifact-only stages whose
exact plans match the reviewed recipe and guarded ledger.

## Parallel review routing

Coordinators assign ready launch reviews to independent available agents.
Record each frozen cohort's oracle authorship, launch admission and actual-output
review. Reviewers own reports; implementers repair runners. Resume completed
implementers with `followup_task` upon exact-plan admission. Reviews may overlap;
compiler/runtime/performance children retain the shared lock and existing caps.

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
