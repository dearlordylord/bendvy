# Agent workflow

Read only the branches triggered by the task. The governing issue and linked specification define acceptance; [review criteria](../CODING_STANDARDS.md) guide judgement.

## Bend implementation or proof

Follow the bend-ldd skill.

During source development, use `scripts/bend-check source.bend` to find parser,
type and affine-binder errors before preparing a complete receipt cohort. This
five-second development check grants no proof or delivery acceptance. Once the
source is ready, freeze and run the governing task's unchanged evidence gates.
Retain the raw development output. Repair ordinary parser/type/binder errors
with this direct check; prepare a frozen delivery cohort when the actual
consuming application and its complete oracle are ready. Intermediate template
checks do not require a new delivery wrapper or portable capsule.

For application fixtures, run the existing Node adapter and runnable Bend seam
against their complete observation oracle before broad installed-tool discovery.
Retain failed development attempts. These checks locate adapter/oracle errors;
the frozen source, negative, mutation and backend delivery gates still apply.

For API changes, require negative controls for undeclared access, cross-schema misuse and writes through read.

## Evidence runner development

Use [check policy](check-policy.md) for cheap consumer preflight, immutable
dependency stages and focused failure reproduction before complete cohorts.

## Approval requirements

Read [SPEC](SPEC.md) for approval requirements on specific laws, numerical performance thresholds and new dependencies. Record the exact outstanding request and why it is needed in the task report.

## Query or storage extension

Read [R-A](../experiments/ra-provider/README.md) and [R-C1](../experiments/rc1-query/README.md) before extending query/storage.

Use Bend types and affine ownership for arbitrary `Type` payloads; Data-only components remain unapproved. Re-test abstract-handle confinement when extending the API.

## Executable src/ecs delivery

Run the paired regression gate in [benchmarks/README.md](../benchmarks/README.md) before delivery and retain its receipt. Use the committed baseline contract; baseline or workload changes require explicit review. This gate qualifies its named workload only; full-core performance qualification remains separate under SPEC.

## Reference inspection or execution

Read-only checkouts are `/workspace/formal-proofs/bendvy/.references/bevy-ts`, `/workspace/formal-proofs/bendvy/.references/bevy` and `/workspace/formal-proofs/bendvy/.references/bend2`. Check commits against the tracked [manifest](../.references/sources.json). They are excluded from Git; use these absolute locations in isolated worktrees or document unavailable references.

For TS execution, check the existing Node runtime first and try a Node-only adapter against the pinned `.ts` entrypoint. Core has no external runtime dependencies. New packages still require SPEC approval when concretely necessary. Source-derived traces become observed evidence only after their actual checkpoints run.

For a previously delivered comparator, follow the delivery-manifest selection
check in [check policy](check-policy.md#preparing-a-focused-runner) before
preparing another execution.
