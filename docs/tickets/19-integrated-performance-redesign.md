# S-PERF — integrated layout redesign decision

**Draft for Astra review and discussion; unpublished.** Follow-up to S-INTEGRATE
[#19](https://github.com/dearlordylord/bendvy/issues/19), full-core parent #1.
No production layout, numerical threshold or new universal law is approved here.

## Problem and bounded outcome

The actual integrated owned-list runtime preserves the reviewed ECS observations
but fails the required performance direction in completed Dense/Sparse and JS
Readers measurements. Dense1024 and some larger sampling runs exceed the
five-second limit. Determine a concrete representation and hot-path change
worth adopting before opening its production implementation task.

Investigate actual per-row lookup, query selection, write journals, mark updates,
command application and observation costs. Quadratic work is a hypothesis to
measure, not a conclusion from timing ratios alone. Separate diagnostic encoding
from authored observations without removing required workload operations.

## Work and acceptance

1. Freeze the completed #19 sources, exact workload adapters, raw samples and
   deadline failures. Attribute the dominant actual costs with bounded controls.
2. Compare at least the current owned-list baseline and one candidate with
   indexed logical-ID lookup and stable ordered membership. Preserve affine
   Type payload owners and returned observations; no cloning or Data-only API.
3. Connect the candidate to actual declared providers, sequential dispatch,
   transactions, explicit barriers and independently registered readers. Exercise
   first/middle/last churn and failed/retried transactions, not head-only kernels.
4. Repeat the complete two-schema/four-capture main trace, retention, access and
   semantic mutation gates for every changed subject. Preserve consumed failed
   reservations, FIFO, prior commits, full fields and foreign MissingEntity with
   the receiving queue unchanged. Representation changes cannot normalize away
   identity or lifecycle failures.
5. Measure all five equivalent integrated workloads at 64/256/1024 live entities
   on Native O3 (one worker, GPU off), JS and pinned TS. Keep setup/warmup outside
   the timed interval, authored dispatch/observations inside, seven rotated
   repetitions, full semantic validation and per-run checksums. Preserve failures.
   Use independently validated child peak-RSS collection; report its whole-process
   scope and occupancy. Prior inherited observer RSS is invalid evidence.
6. Obtain independent Spec and Standards review and record adopt/reject/unresolved
   with the exact evidence and a concrete implementation or further-research
   follow-up. A useful negative result completes this decision research.

Native substantially faster than bevy-ts and JS at least comparable remain
mandatory product requirements. Ratios and variability inform the decision;
new numerical thresholds require explicit approval. A promising microbenchmark
does not establish product acceptance or universal runtime refinement.

## Retained scope

Allocator reuse/exhaustion, unforgeable root authority, arbitrary destructive
Type recovery, general Local, dynamic provisioning and parallel compute retain
separate packages. Do not modify Canonical Tower Defense. Specification of the
simple simulation can proceed against explicitly verified capabilities, while
production adoption waits for its actual capability and performance gates.
