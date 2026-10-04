# Next core checkpoint — draft for discussion

This is a **draft guideline for discussion and review**, not approved proof laws,
performance thresholds, a selected production layout or published next-stage tickets.
The complete [core map](reference/core-map.md) and [SPEC](SPEC.md) remain the goal.

## Current evidence

R-A/R-C1 establish bounded abstract providers/two-schema queries. T04 exercises
an affine owned-array payload. T05 establishes bounded identity/deferred commands;
T06 actual inverse rollback/publication; T07 independent message readers;
T08 independent change/removal positions; T09 closed nested provisioning.
These are executable probes, not one integrated production runtime.
[T10](../experiments/t10/README.md) rejects adopting the current ordered-list layout
on performance. [T11](../experiments/t11/README.md) retains historical helper/model evidence;
its old public-law proposal was withdrawn after the [source decision](reviews/laws-decision.md).
A connected transition package must be drafted/falsified before new law approval;
numerical thresholds remain pending. No general proofs exist.

## Detail now

1. Replace the withdrawn T11 bundle with connected transition/observation laws,
   admissibility and computed-guard/runtime correspondence controls. Review and
   approve exact replacement IDs/revision before any general proof. Keep helper/model proofs separate from provider
   confinement, owned runtime refinement and backend/host IO.
2. Compare owned indexed columns/slot map with stable ordered membership against
   current dense/sparse/update/churn/read/rollback workloads. Preserve Type payloads,
   identity/bounds/order, explicit barriers and both cursor kinds. No production
   layout selection from microbenchmarks alone.
3. Integrate the verified provider, identity, transaction, readers and schedule
   seams on two schemas. Test declared-access/cross-schema/read-write/reconstruction
   controls again; include allocation/mark/cursor rollback and earlier commits.
4. Investigate captured Local/closures and noncopyable payload restoration before
   generalizing System. A failure triggers a bounded explicit contract decision.

Proposed local packages S-LAYOUT, S-INTEGRATE, S-CAPTURE and P-ID/P-Q/P-CMD/
P-TX/P-READ/P-PROVIDE are **unpublished drafts**. Law packages depend on their exact
subjects and approval, not a blanket benchmark gate. Production integration/layout
adoption waits for their actual capability/performance evidence.

## Next application specification (after those gates)

Headless CPU simulation: fixed seed/input, fixed tick count; ordered entities spawn,
move toward a goal, receive damage, publish hits/deaths and are explicitly removed.
Two readers run at different rates. Include one expected system failure/retry,
showing earlier commits remain and failed publications disappear. Print a stable
per-tick trace and final state on Native/JS and a TS reference. No renderer or DSL.

Specify exact inputs, update order, barrier positions, failure injection, trace
schema and selected general laws before publishing implementation tickets. Benchmark
this integrated workload with approved numerical thresholds; primitive timings
alone cannot accept native/JS performance.

## Less detail later, retained scope

Relations/inverse hierarchy + lifetime scopes; state exit/transition/enter failure
ordering; fragments/features/conditions/phases and dynamic provisioning; validation,
snapshot restoration, inspectors and debug noninterference remain explicit core
packages. Refine each when its upstream identity/transaction/reader seams are ready.
Full-core completion tracks the parity matrix, not the number of closed probes.

Then copy only needed Canonical Defense sources from /workspace/typescript/jev
into an isolated integration directory. Determine which remaining contracts it
uses, establish those gates, preserve Canonical.step and compare fixed-input
results. The original repository stays untouched; reducer migration is a separate
conditional task. Parallel compute is revisited with reproducible independent
workloads after the storage/CPU evidence, not silently removed.

## Decisions for review

- Review the replacement law package after connected transition statements and
  meaningful falsification exist. The old fourteen-law approval request is withdrawn;
  no runtime-proof approval is inferred.
- Numerical proposal: native >=2x per representative workload/size; JS <=1.10x
  time with uncertainty below that margin. Both unapproved; current layout fails.
- Is the ordering above suitable for the next detailed ticket breakdown? Publish
  new packages only after this checkpoint's human review; no premature ready state.
