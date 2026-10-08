# Timing adapter — source proposal, no measured result

The candidate reconstructs neither application nor failure checkpoint during a scenario. `stepper.bend` consumes and returns the actual application; `stateful-driver.bend` threads the same registry, Local, command, machine and Reader owners through operations. The independent ledger has thirteen scenarios, forty-five operations and twenty-one common checkpoints per schema. The canonical oracle remains forty-two common records; six Bend-only foreign/restoration records remain mandatory separate controls from the qualified baseline.

`batch.bend` retains affine application owners in order, performs the same operation on each, and returns those owners. `clock-step.bend` reads start time, calls that batch operation, matches its returned Batch constructor, and only then constructs the end-clock action. Observation/formatting/oracle comparisons are outside this interval. No batch population, sample count, tolerance or performance run is selected.

## Evaluation boundary to verify before measurement

Pinned Bend `a950fd683c0d76f09794078e6174fe98a1492876`:

- `bend2/bend.ts:184–202` describes strict by-value closed reduction.
- `bend2/comp.ts:2110–2113` evaluates argument expressions through emit_each. `2126–2150` emits native callee invocation, reads returned owner words, then continues. `2243–2287` evaluates constructor fields before construction; `2444` evaluates let values before binding.
- JS `comp.ts:2887–2913,2939–2980` emits direct calls or run_loop tail-call resolution and constructor field expressions. The generated result must be returned before completed schedules end-clock.
- Native `comp.ts:2051–2068` can return scheduler tasks when !seq. This prevents treating the strict source description alone as sufficient evidence that elapsed time includes all actual work. Inspect the fresh generated clock continuation, work-loop reduction and returned Batch match; verify the end IO effect cannot run while the measured operation remains queued.
- Native `comp.ts:5251–5288` corpus_eval calls work_loop with `seq = !BANGS && pool_size == 1`, resolves scheduler continuations until root result, then returns root_take. `5844–5878` io_step applies the actual continuation/item through corpus_eval before selecting and executing the next effect. Base `IO.bind:156–158` passes the prior result into the continuation. This is source-backed causal evidence at the IO request boundary, subject to fresh emitted Batch.step → returned owners → completed → endNow dependency inspection. It is not a universal normalization/timing proof. Thread1/GPUoff remain required.
- `bend2/effs/now.js` floors performance.now; `now.c` divides monotonic io_tick by1000000. Both expose integer milliseconds. Zero intervals are inconclusive; batching may address resolution, but its population requires review. TS high-resolution source clock is not silently declared equivalent to these units.

The next executable gate is a frozen cheap source/import and emitted-code inspection plan, followed by full canonical consumer correctness. This is separate from comparative timing admission. Same forcing work must apply to TS and Bend; full diagnostic serialization is excluded on both sides, rather than forcing Bend work by observation after end-clock.

## Preserved development attempts

- `development-source-1791442390780297680`: decreasing-call source error; failed bytes/raw and transcribed failure observation retained.
- `development-source-1791442462932997662`: stateful driver and batch source5 typing PASS; exact standard banner and empty stderr. No mathematical proof/runtime/timing credit.
- `development-clock-source-*`: clock source command exits0 with standard typing banner, but update-notice stderr causes INCOMPLETE under the declared empty-stderr criterion. Original raw/receipt retained; no unchanged retry or dependency update.

TS source adapter, operation ledger and independent common oracle are prepared before timing outputs. TS batched execution still needs the same per-population ledger/owner continuation as Bend before a measurement contract can be reviewed. Existing accepted Workshop regression evidence does not qualify this new feature-specific timing adapter.
