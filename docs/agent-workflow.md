# Agent workflow

Read only the branches triggered by the task. The governing issue and linked specification define acceptance; [review criteria](../CODING_STANDARDS.md) guide judgement.

## Bend implementation or proof

Follow the bend-ldd skill.

For API changes, require negative controls for undeclared access, cross-schema misuse and writes through read.

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

## Canonical-defense or external-repository integration

Never modify `/workspace/typescript/jev`. Use a separate copy for canonical-defense integration after its planned prerequisites are satisfied. Changes to external repositories require explicit task authorization.
