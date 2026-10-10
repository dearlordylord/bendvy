## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

An ordinary ECS application user enables debug. Structure, declared access and schedules derive from the application's ordinary ECS declarations, without repeated descriptions or user-written metadata adapters. Additional presentation functions are allowed for opaque user values. Debug preserves ECS behavior.

## Acceptance criteria

- [ ] Demonstrate an ordinary public ECS application that only enables debug: existing component/resource/query/system/schedule declarations supply structure, access and schedule descriptions. No parallel metadata declaration or manual metadata adapter is required from the application user; opaque-value presentation functions are allowed.
- [ ] Determine feasibility against the pinned Bend compiler/runtime and public ECS declaration model, with Rust Bevy as the architecture authority and bevy-ts as the feature-scope reference. The low-level metadata candidate alone does not fulfill this requirement. If automatic behavior is technically impossible, mark #56 as skipped with a precise source-backed obstruction. Missing plumbing or implementation difficulty alone is not impossibility.
- [ ] Inventory pinned description/lint/access-index/population/dump/naming formats and execute complete public observations including graph, machine and transient/plain values.
- [ ] Repeated descriptions and dumps neither register/advance readers nor retain events, mutate owners or flush pending work. A dump is not a restorable snapshot.
- [ ] Disabled debug performs no description work; measure enabled overhead separately. Reject foreign/schema misuse and detect a reached filter/noninterference mutant.

## Blocked by

- #55

## Delivery and evidence

- Apply the [SPEC reference order](../SPEC.md#implementation-decisions): Rust Bevy architecture and ECS semantics first; Bend types, affine ownership and runtime constraints second; bevy-ts feature inventory and porting inspiration third. Record exact reference commits. Execute bevy-ts comparisons for shared agreed scenarios, not as a blanket behavior authority; preserve approved contracts and record reference differences explicitly.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native observations and timing/scaling evidence without dropping work. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.

## Remaining automatic declaration bridges

Source preparation for #56; these are implementation gaps, not executed acceptance
or evidence of technical impossibility. Rust Bevy retains access from system
parameters (`crates/bevy_ecs/src/system/system_param.rs`, `Res`/`ResMut::init_access`)
and exposes registered systems in `schedule/schedule.rs`. Reference commits are
fixed in [the manifest](../../.references/sources.json).

| Ordinary declaration | Existing operational information | Required App bridge |
| --- | --- | --- |
| Resource/schema | [ordinary-schema](../../src/ecs/ordinary-schema.bend): `resource`, `resource_schema`, `entries`, `product` retain keys, names and order; their type parameters carry physical types, not runtime type descriptors. | Derive schema descriptions from these same entries. |
| Resource access | [compose](../../src/ecs/compose.bend): `resource_read`/`resource_write`; [inspector](../../src/ecs/inspector.bend): `read_resource`. | Retain the ordinary resource identity and access clause with the grant. The separate caller-authored identity in [inspector-declaration](../../src/ecs/inspector-declaration.bend) is reusable plumbing, but not automatic declaration integration. |
| Schedule | [schedule](../../src/ecs/schedule.bend): `Schedule` retains names and ordered steps, system/condition IDs and barriers. [schedule-provision](../../src/ecs/schedule-provision.bend): `Plan` retains per-step requirements before `build` lowers them to steps and a requirement union. | Describe the actual executable schedule. Preserve the operational Plan if per-step requirements are exposed; the union cannot recover that association. |
| Storage classification | [persistence-declaration](../../src/ecs/persistence-declaration.bend) distinguishes Plain/Transient/Constructed; [snapshot-leaf](../../src/ecs/snapshot-leaf.bend) retains recipes. | Connect classification to the ordinary schema; current schema entries omit it. |
| Relations and machines | [relation-types](../../src/ecs/relation-types.bend): `Descriptor` retains name/kind/inverse. [machine](../../src/ecs/machine.bend) and [machine-handler-bundle](../../src/ecs/machine-handler-bundle.bend) retain slots, selectors, order, requirements and registries. | Derive descriptions at their actual App registration/build seams. |

Descriptions must be derived only when debug is enabled. Do not add unconditional
description copies or require user metadata adapters.

Resource-only bodies should run once per permitted registered invocation with
valid resource grants, including an empty World, as in pinned Bevy
`function_system.rs`. Use the existing
`System.run_checked`/`Capabilities.invoke_owned` seam and resource transaction
grants. `OrdinarySystem.runner` uses `Compose.each_since`: it runs zero times
without matching entities and once per match otherwise, so it cannot supply
resource-only execution. Keep entity-query iteration unchanged.

Schedule descriptions read retained steps and actual Registry owners without
executing conditions, dispatch or barriers. Condition IDs remain available;
condition names are absent from the current declaration model. Runtime system
IDs also prevent treating every operational Plan as an erased static index.

The retained full80 fixture contains reusable Registry/schedule projections
(see [the source archive](../../experiments/public-inspect/debug-study-v1/production-adoption-v1/canonical-system-retention-v1/detached-observable-generic-v1/diagnostic-js-v1/actual-js-v1/manifest.json)), but does not establish an
ordinary automatic public App or complete #56 acceptance. Pinned bevy-ts
`Debug.ts` identifies output categories; it does not determine the contract.
