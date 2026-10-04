# Replacement ECS law package — draft for human review

This is a specific **unapproved candidate**, not approval or a proof. It replaces
the withdrawn historical proposal while preserving its exact files and results.
Governing task: [#12](https://github.com/dearlordylord/bendvy/issues/12).

Exact subject: [LAWS.bend](../../experiments/t11-replacement/LAWS.bend), SHA256
`e0c607d723ad250a189c096d9fa3fd6a36913f4c72efd3a3be6dacd7fadb2cbc`. There are **31 open laws**; no general ECS proof exists.
The [package report](../../experiments/t11-replacement/README.md) supplies each
law's reason, exact domain, controls, mutant evidence, proof sketch and dependency.

Proposed IDs:

- `admissibility_independent`
- `namespace_creation_exact`
- `namespace_two_created`
- `reservation_exact`
- `reservation_pending_lookup`
- `query_any_complete_ordered`
- `query_present_complete_ordered`
- `query_absent_complete_ordered`
- `lookup_full_exact`
- `publication_authorized_target`
- `explicit_flush_independent`
- `schedule_execution_exact`
- `admissibility_preserved`
- `query_independent_physical_order`
- `owned_runtime_creation_correspondence`
- `owned_runtime_projection_exact`
- `owned_runtime_projection_preserves_owner`
- `owned_runtime_step_correspondence`
- `u32_increment_no_wrap`
- `u32_comparison_agrees_nat`
- `message_failure_helper`
- `message_success_helper`
- `message_skip_helper`
- `lifecycle_failure_helper`
- `lifecycle_success_helper`
- `conditional_type_true`
- `conditional_type_false`
- `owned_runtime_query_result_and_owner`
- `owned_runtime_lookup_result_and_owner`
- `owned_runtime_reservation_result_and_owner`
- `owned_runtime_schedule_correspondence`

The connected model covers actual creation/reservation/pending/live, scoped
lookup, handle-bound publication, independent FIFO, ascending queries, real
bounded schedules and preserved admissibility. The owned runtime has **direct
proposition equalities** for initial creation, Data projection, returned-owner
observation, actual step, query/lookup/reserve result-plus-owner and actual tick.
No Boolean certificate or equality validator is used as a runtime guarantee.

Erased owners occur only in mathematical propositions. A paired checker control
permits this encoding and rejects a live erased-owner leak; live operations still
consume and return affine owners. Independent conditional Type guards demand
exact equalities when true; both encoder branches have their own laws, and false
Unit controls are excluded from equality/mutant success counts. Tick's width and
admissibility domain is checked at every independent prefix, not only initially.

Finite evidence: 1,411 true-domain exact equality instances, 635 excluded Unit
controls, 31 compiling primary mutants and twelve extra mutants killed; 72 actual
TS/Native/JS checkpoint comparisons and twelve Native/JS mutants. Local execution
is explicitly segmented (complete primary law stage followed by refreshed extras),
with the old whole process's nonzero exit recorded. The coordinator independently
verified 25+6 law grids, all twelve extras and the complete runtime artifact.

Review decisions and limits remain explicit:

- Namespaces originate in two calls through a returned affine factory, under one
  trusted lineage. Independent-root global provenance is still open.
- Bounded rejection/exhaustion is an experiment parameter, not an approved product
  allocator/reuse/error policy. Public foreign-command rejection results remain
  unresolved. Foreign authority preserves the owner; the approved lookup result
  is MissingEntity, including colliding local IDs.
- Arrays are nonempty; index zero is defined. The arbitrary erased owner quantifier
  observes element zero of each array. Preservation is at that declared projection,
  not all array contents or physical owner identity. Fixtures use one-element
  arrays; broader Type payloads remain explicit follow-ups.
- U32 MAX-1/MAX has actual compiled guard/no-wrap observations. Two U32-to-unary-Nat
  equations have small literal falsification and a high-bound normalization gap;
  neither finite observation establishes a universal arithmetic proof.
- This value/tag slice does not choose a production layout, Data-only components,
  a general schema/system API or performance acceptance. The five cursor helpers
  remain separate from future selected-reader transaction/retention/lag laws.
- External lawcheck/bend-falsify compatibility remains unverified; no dependency
  was adopted. No general model/helper/owned-refinement/backend proof exists.

Approval must name these exact IDs/revision (or an explicit subset) before proof
work. Approving the investigation does not approve unresolved product policies,
dependencies, performance margins or this replacement automatically.
