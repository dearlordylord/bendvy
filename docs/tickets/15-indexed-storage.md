# S-LAYOUT: Owned indexed storage comparison

**Status:** completed bounded research; production adoption and performance acceptance remain open. [GitHub #16](https://github.com/dearlordylord/bendvy/issues/16). Parent: [#1](https://github.com/dearlordylord/bendvy/issues/1).

Review: [Astra assessment](../reviews/next-research-tickets.md).

## Goal and prerequisites

Determine whether Bend-native owned indexed columns/slot mapping plus stable ordered
membership can remove T10's traversal/churn regressions without weakening semantics.
Read SPEC, the current checkpoint, T04–T08, R-A/R-C1, T10's corrected runner/results
and the source-law decision. These completed probes are evidence prerequisites.
This research can start alongside #12 and S-CAPTURE; it needs no approved ECS proof.

## Bounded deliverable

Implement an experimental owned indexed candidate and compare it with the committed
list baseline and actual pinned bevy-ts. Use a small fixed schema, explicit capacity
and at least one genuinely affine Type payload. Separate Data-only measured kernels
from owned-payload measurements. Do not select a production layout from this probe.

## Acceptance criteria

- [x] Document representation, ownership, slot/ID correspondence, free/vacant membership and all bounds checks before array access. Preserve the current bounded identity contract; reuse/exhaustion policy changes remain unresolved decisions, not optimizations.
- [x] Preserve ascending entity-ID query observations, exact membership and values, explicit deferred visibility, logical FIFO command order and approved foreign-handle lookup rejection. Validate the approved foreign-lookup divergence separately; do not demand TS parity for that result. Include sparse holes, slot movement/reinsertion, pending/live states and capacity boundaries without wraparound.
- [x] Exercise a bounded T06-style reversible owned-payload read/update and failed-system restoration through a concrete ownership-preserving interface, plus successful structural removal with explicit ownership disposition. Data-copy rollback cannot satisfy this bounded owned-payload criterion. Arbitrary destructive affine restoration is a conditional integration gate tracked in S-CAPTURE, not required for research completion here.
- [x] Re-test provider confinement on two schemas: paired positives/negatives for undeclared access, cross-schema handles, fabricated/reconstructed authority and writes through read. Explain what the experiment does and does not establish universally.
- [x] Stage the comparison: first mandatory equivalent Data kernels for dense/sparse traversal, update, churn, messages and rollback; then the bounded owned-payload probe. Preserve two-reader independence and separate message/change positions in the relevant reader kernels. Include positive success plus failure/retry and earlier-commit preservation in rollback kernels. Label unintegrated seams explicitly; full reader/schedule/owned-payload integration belongs to S-INTEGRATE, not this completion gate.
- [x] Use the same logical workloads for candidate/list/TS at sizes 64, 256 and 1024 (or report a justified bounded failure). Compare exact final ordered IDs/values, relevant reader positions/publications and observed intermediate checkpoints. Use meaningful compiling mutants for ordering, index/identity mapping and rollback; do not rely on checksums alone.
- [x] Publish reproducible commands, pins, workload counts, worker settings, warmups, at least five samples, dispersion and raw results. Exclude build/setup from timed execution; describe memory measurement and inherited-process limitations. Give each checker a five-second timeout and separate bounded build/runtime limits.
- [x] Report per-workload/size tradeoffs against both baselines and explain unresolved integration costs. Numerical native/JS acceptance thresholds remain unapproved: research completion is not final performance acceptance.
- [x] Record follow-ups and a proposed next integration interface, including affinity/ownership, identity, rollback and reader seams. Do not claim general laws, production adoption or full-core completion.

## Outcome and dependencies

A reproducible negative/partial result can complete the investigation, while the
corresponding capability remains blocked. Record a bounded redesign decision rather
than reducing payload/ordering/rollback scope. S-CAPTURE may inform restoration; it
is not a blanket start dependency. General integration waits for the capabilities
it actually uses. No original Tower Defense edits, new dependencies, new proofs or
numerical/scope approvals are authorized by this ticket.

## Delivered outcome

Implementation: [276a71c](https://github.com/dearlordylord/bendvy/commit/276a71c).
[Research report](../../experiments/s-layout/README.md) records representation,
ownership, bounds, interface proposal and integration limits. Primary evidence:
[semantic verification](../../experiments/s-layout/verification.json),
[provider controls](../../experiments/s-layout/controls.json),
[Data measurements](../../experiments/s-layout/results.json), and
[owned measurements](../../experiments/s-layout/owned-results.json).

All nine research criteria are covered: 59 stored semantic checkpoints, ten
compiling mutants and ten paired provider controls; six Data workloads at three
sizes across five backends with five samples each; a separate genuinely Type
payload comparison against an owned-list counterpart and actual TS. The executor
ran all three reproduction commands; the coordinator independently reran semantic
verification and audited source hashes, pins, sample counts and medians/ranges.
[Standards](../reviews/implementation-standards.md) and
[Spec/Astra](../reviews/implementation-spec.md) reviews found no blockers.

The result is partial/negative for product capability: dense traversal and some
JS workloads regress against TS; indexed owned storage also loses to its owned-list
counterpart in the two-cell probe. No production layout is selected. General
compaction, non-head churn, integrated providers/readers/schedules, destructive
restoration and representative performance remain explicit
[follow-ups](../follow-ups.md#s-layout-return-conditions). Native substantial
improvement and JS comparability remain mandatory, with numerical thresholds
unapproved. No ECS proofs, full-core completion or original Tower Defense edits.
