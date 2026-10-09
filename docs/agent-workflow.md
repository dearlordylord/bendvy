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

Within assigned files and agreed contracts, carry local implementation through
the complete consuming fixture; report helper/source milestones as progress while
continuing. Request a handoff at an unresolved contract, shared-file boundary or
the separately reviewed backend launch, rather than before each local adapter.
Freeze the consuming source and complete oracle together when that boundary is
ready.

For application fixtures, run the existing Node adapter and runnable Bend seam
against their complete observation oracle before broad installed-tool discovery.
Retain failed development attempts. These checks locate adapter/oracle errors;
the frozen source, negative, mutation and backend delivery gates still apply.

For API changes, require negative controls for undeclared access, cross-schema misuse and writes through read.

## Evidence runner development

Classify the next run first: application development follows the direct fixture
checks above; frozen delivery uses the collector recipe below. Resolve behavior
and oracle errors before preparing full installed-tool qualification.

Start new collectors from the [focused runner recipe](check-policy.md#preparing-a-focused-runner).
Before execution review, complete its source, tool, environment, output and
oracle inventories. For child-only locking, select the existing
[immutable dependency stage](check-policy.md#immutable-dependency-stages) helper
with a reviewed resolver inventory: discovery runs outside the lock and its
static check runs at the launch boundary after acquisition.

For new collectors, hold the shared heavy-work lock around the actual compiler,
runtime or performance child. Prepare immutable inputs and metadata-only
verification probes outside that lock; keep the full pre/post validation and
unconditional failure receipt. Revalidate the launch boundary after acquiring the lock. Review this
routing as a collector change before execution; keep frozen in-flight runs intact.

Before launch, review execution code and all stages; guard generated artifacts
in the output ledger before consumption and proceed without intermediate handoffs.
Re-review code, input recipes or gate-scope changes; preserve frozen attempts.
The coordinator may admit artifact-only stages by checking their exact plans
against the reviewed recipe and guarded output ledger.

## Parallel review routing

The coordinator assigns ready launch reviews to an independent available agent;
one oracle author need not review every task. Keep oracle authorship, launch
admission and actual-output review explicit for each frozen cohort. Reviewers
own evidence reports; implementation authors repair their own runners. Resume a
completed implementation agent with `followup_task` when its exact plan is admitted. Independent
reviews may overlap; compiler, runtime and performance children retain the
shared heavy-work lock and existing caps.

## Approval requirements

Read [SPEC](SPEC.md) for approval requirements on specific laws, numerical performance thresholds and new dependencies. Record the exact outstanding request and why it is needed in the task report.

## Query or storage extension

Read [R-A](../experiments/ra-provider/README.md) and [R-C1](../experiments/rc1-query/README.md) before extending query/storage.

Support arbitrary `Type` payloads through Bend types and affine ownership;
Data-only components remain unapproved. Re-test abstract-handle confinement
after API extensions.

## Executable src/ecs delivery

Run the paired regression gate in [benchmarks/README.md](../benchmarks/README.md) before delivery and retain its receipt. Use the committed baseline contract; baseline or workload changes require explicit review. This gate qualifies its named workload only; full-core performance qualification remains separate under SPEC.

## Reference inspection or execution

Read-only checkouts are `/workspace/formal-proofs/bendvy/.references/bevy-ts`, `/workspace/formal-proofs/bendvy/.references/bevy` and `/workspace/formal-proofs/bendvy/.references/bend2`. Check commits against the tracked [manifest](../.references/sources.json). They are excluded from Git; use these absolute locations in isolated worktrees or document unavailable references.

For TS execution, check the existing Node runtime first and try a Node-only adapter against the pinned `.ts` entrypoint. Core has no external runtime dependencies. New packages still require SPEC approval when concretely necessary. Source-derived traces become observed evidence only after their actual checkpoints run.

For a previously delivered comparator, follow the delivery-manifest selection
check in [check policy](check-policy.md#preparing-a-focused-runner) before
preparing another execution.
