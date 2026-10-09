# Agent workflow

Read the applicable branch. The issue and linked spec define acceptance;
[review criteria](../CODING_STANDARDS.md) guide review.

## Porting scope and concerns

Apply [SPEC scope decisions](SPEC.md#implementation-decisions) before treating
an export or existing ticket as an implementation requirement.

```text
C(X) = normalized ECS capabilities of implementation X
B = C(Bevy) intersection C(bevy-ts)
Extras = C(bevy-ts) minus C(Bevy)
Scope(Bendvy) = B union explicitly_user_approved(Extras)

LanguageConcerns = {Rust, TypeScript, Bend}: types, ownership, effects, runtime
ImplementationConcerns = {Bevy, bevy-ts, Bendvy}: APIs, storage, algorithms

for capability in Scope(Bendvy):
  contract = Bevy_ECS_semantics(capability) + explicit_approved_adaptations
  implementation = idiomatic_Bend_design(contract)
  require observable_contract_preserved and agreed_performance_met
  if a proposed adaptation changes observable_contract:
    obtain explicit_user_agreement before implementation
```

Classify each item by capability, semantics, language mechanism and implementation
choice. Learn from Rust/TS implementations; select mechanisms valid for Bend.
TS-only additions, including Standard Schema/JS host integration, remain pending
scope agreement; continue independent approved ECS work.

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

Choose one lock owner from the runner implementation. Invoke collectors with
internal locking directly; reserve an external cohort lock for runners without
that lock. Lock compiler/runtime/performance children and heavy oracle
materialization; prepare lightweight metadata outside. Start with ordinary installed-tool
snapshot/verify from the [runner recipe](check-policy.md#preparing-a-focused-runner).
Use the optional [immutable dependency session](check-policy.md#immutable-dependency-stages)
when a closed resolver inventory is already reviewed; its preparation is a
separate optimization, not a prerequisite for ordinary delivery. Preserve
pre/post guards and unconditional failure receipts. Guard generated artifacts
before consumption.

Batch source, complete oracle and all stage recipes into one independent launch
review. Reviewers own reports; authors execute the admitted sequence and return
one final evidence commit. Resume completed authors with `followup_task`.
Reopen review for changed code, recipes or gates; stage status alone is not a
handoff. Coordinators may admit artifact-only stages matching the reviewed
recipe and guarded ledger. Preserve frozen attempts and in-flight runs.

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
