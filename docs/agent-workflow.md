# Agent workflow

Read only the branches triggered by the task. The governing issue and linked specification define acceptance; [review criteria](../CODING_STANDARDS.md) guide judgement.

## Delivery

Write issues, task instructions, reports and executor/integrator messages in English; user conversation may remain in Russian.

Deliver on `master`: commit verified changes, push and report against the governing issue before closing it. An explicit session request for a PR or another workflow overrides this default. Preserve unrelated changes and processes.

Keep task artifacts small and verifiable: record commands, inputs, output evidence and limits. Claim acceptance only from evidence for the governing task.

## Bend implementation or proof

Follow `/home/node/.codex/skills/bend-ldd/SKILL.md`. Run `bend version` and `bend guide` before Bend work. Limit every checker invocation to five seconds. Draft and falsify specific laws before requesting approval; write ECS proofs only against approved laws, preserving their exact statements.

For API changes, require negative controls for undeclared access, cross-schema misuse and writes through read.

For a scoped task-local checker repair, read [owned-checker-local-use](reviews/owned-checker-local-use.md); retain the five-second limit and unchanged kernel.

## Approval or historical-evidence dependency

Read [SPEC](SPEC.md) for approval requirements on specific laws, numerical performance thresholds and new dependencies. Record the exact outstanding request and why it is needed in the task report.

When reusing an earlier approval or receipt, consult the [unchanged checkpoint archive](next-core-checkpoint-history.md) and its linked originating evidence. Check scope, source pins and explicit approval before reuse; the archive contains historical, sometimes superseded states rather than current task instructions. The withdrawn fourteen-law proposal is not an approval source.

## Query or storage extension

Read [R-A](../experiments/ra-provider/README.md) and [R-C1](../experiments/rc1-query/README.md) before extending query/storage. Their bounded query return results permit dependent experiments; the exported-constructor T03 report remains failed. Production API, Data-only scope, universal authority/refinement, proofs and performance require their own acceptance gates.

Use Bend types and affine ownership for arbitrary `Type` payloads; Data-only components remain unapproved. Re-test abstract-handle confinement when extending the API.

## Executable src/ecs delivery

Run the paired regression gate in [benchmarks/README.md](../benchmarks/README.md) before delivery and retain its receipt. Use the committed baseline contract; baseline or workload changes require explicit review. This gate qualifies its named workload only; full-core performance qualification remains separate under SPEC.

## Reference inspection or execution

Read-only checkouts are `/workspace/formal-proofs/bendvy/.references/bevy-ts`, `/workspace/formal-proofs/bendvy/.references/bevy` and `/workspace/formal-proofs/bendvy/.references/bend2`. Check commits against the tracked [manifest](../.references/sources.json). They are excluded from Git; use these absolute locations in isolated worktrees or document unavailable references.

For TS execution, check the existing Node runtime first and try a Node-only adapter against the pinned `.ts` entrypoint. Core has no external runtime dependencies. New packages still require SPEC approval when concretely necessary. Source-derived traces become observed evidence only after their actual checkpoints run.

## Canonical-defense or external-repository integration

Never modify `/workspace/typescript/jev`. Use a separate copy for canonical-defense integration after its planned prerequisites are satisfied. Changes to external repositories require explicit task authorization.
