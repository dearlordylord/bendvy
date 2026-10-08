# Same-owner feature timing protocol — draft for review

No performance execution is authorized by this document. Population, repetitions and scheduling remain explicit inputs to an accepted run contract; none are selected here.

## Comparable work

`operations.json` is the independent operation ledger: each schema has 13 setups, 45 queue/marker/read operations and 21 checkpoints. TS, Bend JS and Bend Native must execute every operation in that order, retaining each actual application owner from setup until its scenario ends. Failures, later markers, self-queued transitions and missing inactive requirements remain real operations. Do not reconstruct cases at checkpoints or fabricate retries. The same explicit population applies to all backends; every application has distinct actual owner/namespace storage.

The complete canonical common DTO has 42 checkpoint keys and type-sensitive values. Validate every population member, not one representative. Six Bend-specific restoration/foreign-owner controls remain mandatory separate correctness evidence; they are excluded from a claimed TS-equivalent speed ratio. Preserve complete raw physical Bend observations and TS results, streams, deliveries and errors even where their representations differ.

## Clock and evaluation boundary

Setup and steady operations are separate series. Setup includes application/registry/reader construction and the real initial empty reader activation. It ends only when all actual owners are returned. A steady interval begins immediately before the operation over the batch and ends after all returned owners are available. Carry those same owners into the next operation.

TS synchronous `step` returns the actual applications before the end clock. Bend `clock-step.completed` matches the returned Batch constructor before constructing the end IO.now request. Delivered JS inspection shows synchronous argument/callee evaluation through Batch.step; delivered thin Native C inspection shows returned-owner continuations and corpus_eval preceding the next effect dispatch under sequential scheduling. These are finite emitted-code observations, not a universal evaluation proof. Whole-workload Native generated call paths must receive the same inspection before measurement admission.

No generic deep-force, JSON rendering, observer, projection or assertion belongs inside an operation interval. After each interval retain/capture the complete checkpoint state outside its clocks, with the same capture placement on all backends. Those captures can affect subsequent heap state, so disclose them and keep their placement identical. A full observer after the final end clock also makes retained work observable.

Use explicitly matched integer-millisecond monotonic clock precision for this first protocol: Bend IO.now is integer milliseconds; a TS high-resolution clock cannot silently substitute a different precision. Nonpositive elapsed intervals are inconclusive. Batching addresses resolution only after an explicit population is approved and correctness, stack capacity and memory feasibility are established; it does not permit dropping operations or checkpoints.

## Required implementation and admission sequence

1. Implement a Bend IO ledger driver around existing Batch/Stepper/clock-step. It must retain owners and samples through all scenarios, perform checkpoint observation outside each interval, and separate setup samples. Keep the operation ledger and common oracle unchanged.
2. Correctness mode must execute the complete ledger without reporting performance. Require full canonical 42 equality on TS, JS and Native, plus the six separate Bend controls. Existing JS42 and thin Native emission evidence are prerequisites; they do not replace this new driver qualification.
3. Inspect emitted whole-driver JS and Native returned-owner-to-next-clock dependencies. Freeze current participating configurations, compiler/runtime/tools, source, generated artifacts and private environment under the repository guards. Native scheduling is one runtime thread with GPU disabled.
4. Review the explicit run contract, including population/repetitions, machine contention, execution order, clock validity and retained raw profiles. Only then execute comparative measurements under the shared exclusive slot. External CPU contention prevents an uncontaminated speed conclusion; defer that conclusion rather than inventing a ratio.

Report setup separately and steady totals plus operation/scenario breakdowns. Apply only the existing JS ≤ TS and Native ≤ 0.5 × TS goals and the unchanged repository regression policy; this draft adds no numerical tolerance or statistical gate. Workshop #28 evidence remains valid for its own workload and cannot stand in for these feature-specific measurements.

## Current limits

The TS batch adapter is source-only. Bend same-owner full42 correctness passed in JS without calling clocks; thin Native Queue→Marker→Read source/C emission passed without compilation or execution. No feature timing ratio, complete Native ledger qualification, population feasibility or full resolver qualification follows from those results. The next implementable step is the complete Bend IO ledger driver and its independent no-timing correctness consumer.
