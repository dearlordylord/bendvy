# S-LAYOUT: Owned indexed storage comparison

**Status:** published, `ready-for-agent`. [GitHub #16](https://github.com/dearlordylord/bendvy/issues/16). Parent: [#1](https://github.com/dearlordylord/bendvy/issues/1).

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

- [ ] Document representation, ownership, slot/ID correspondence, free/vacant membership and all bounds checks before array access. Preserve the current bounded identity contract; reuse/exhaustion policy changes remain unresolved decisions, not optimizations.
- [ ] Preserve ascending entity-ID query observations, exact membership and values, explicit deferred visibility, logical FIFO command order and approved foreign-handle lookup rejection. Validate the approved foreign-lookup divergence separately; do not demand TS parity for that result. Include sparse holes, slot movement/reinsertion, pending/live states and capacity boundaries without wraparound.
- [ ] Exercise a bounded T06-style reversible owned-payload read/update and failed-system restoration through a concrete ownership-preserving interface, plus successful structural removal with explicit ownership disposition. Data-copy rollback cannot satisfy this bounded owned-payload criterion. Arbitrary destructive affine restoration is a conditional integration gate tracked in S-CAPTURE, not required for research completion here.
- [ ] Re-test provider confinement on two schemas: paired positives/negatives for undeclared access, cross-schema handles, fabricated/reconstructed authority and writes through read. Explain what the experiment does and does not establish universally.
- [ ] Stage the comparison: first mandatory equivalent Data kernels for dense/sparse traversal, update, churn, messages and rollback; then the bounded owned-payload probe. Preserve two-reader independence and separate message/change positions in the relevant reader kernels. Include positive success plus failure/retry and earlier-commit preservation in rollback kernels. Label unintegrated seams explicitly; full reader/schedule/owned-payload integration belongs to S-INTEGRATE, not this completion gate.
- [ ] Use the same logical workloads for candidate/list/TS at sizes 64, 256 and 1024 (or report a justified bounded failure). Compare exact final ordered IDs/values, relevant reader positions/publications and observed intermediate checkpoints. Use meaningful compiling mutants for ordering, index/identity mapping and rollback; do not rely on checksums alone.
- [ ] Publish reproducible commands, pins, workload counts, worker settings, warmups, at least five samples, dispersion and raw results. Exclude build/setup from timed execution; describe memory measurement and inherited-process limitations. Give each checker a five-second timeout and separate bounded build/runtime limits.
- [ ] Report per-workload/size tradeoffs against both baselines and explain unresolved integration costs. Numerical native/JS acceptance thresholds remain unapproved: research completion is not final performance acceptance.
- [ ] Record follow-ups and a proposed next integration interface, including affinity/ownership, identity, rollback and reader seams. Do not claim general laws, production adoption or full-core completion.

## Outcome and dependencies

A reproducible negative/partial result can complete the investigation, while the
corresponding capability remains blocked. Record a bounded redesign decision rather
than reducing payload/ordering/rollback scope. S-CAPTURE may inform restoration; it
is not a blanket start dependency. General integration waits for the capabilities
it actually uses. No original Tower Defense edits, new dependencies, new proofs or
numerical/scope approvals are authorized by this ticket.
