# Bendcraft optimization research

Inspected lennix1337/bend2craft at `2bd6fb0d612d16b4cade160a40102dfd67b837ba`, read-only disposable checkout /tmp/bendcraft-research. Research date2026-10-05. Background source investigation plus integrator verification; no dependencies installed or benchmarks rerun. Author-reported results remain distinct from independently reproduced results.

## Browser product

Bend owns terrain, game rules and simulation; JavaScript handles browser APIs, derived caches and rendering. Normal terrain loading uses bulk chunk results rather than one World.block bridge call per cell. Terrain/light generation runs in workers. [Architecture](https://github.com/lennix1337/bend2craft/blob/2bd6fb0d612d16b4cade160a40102dfd67b837ba/README.md#L7-L12). Worker parallelism does not turn one emitted Bend JS evaluator into native Bend parallelism.

The terrain hot core uses U32 arithmetic and precomputes quantities per column instead of repeatedly computing them for every cell. [Source](https://github.com/lennix1337/bend2craft/blob/2bd6fb0d612d16b4cade160a40102dfd67b837ba/world/world.bend#L72-L213). README reports warm medians over16 chunks: roughly475ms→4–5ms terrain and78ms→1.5–2ms lighting per fresh chunk, with a village chunk near20ms. Original-rule fingerprints cover seeds, positive/encoded-negative coordinates and edited saves. [Reported results](https://github.com/lennix1337/bend2craft/blob/2bd6fb0d612d16b4cade160a40102dfd67b837ba/README.md#L232-L246), [benchmark](https://github.com/lennix1337/bend2craft/blob/2bd6fb0d612d16b4cade160a40102dfd67b837ba/benchmarks/chunk-generation.mjs).

**Version caveat:** the source comment explains the earlier JS Nat as BigInt/trampolined. Bendvy2.0.35 already includes the numeric-Nat/direct-call/tail-cycle changes released in2.0.29. Do not forecast100× ECS improvement from that old result. Invariant hoisting and bulk operations remain plausible on the current compiler.

The browser indexes entities into spatial buckets and updates distant entities less frequently. [Entity workload](https://github.com/lennix1337/bend2craft/blob/2bd6fb0d612d16b4cade160a40102dfd67b837ba/benchmarks/entities-step.mjs), [product scope](https://github.com/lennix1337/bend2craft/blob/2bd6fb0d612d16b4cade160a40102dfd67b837ba/README.md). Bucket indexing can reduce lookup work; reduced tick cadence changes simulated work and cannot satisfy our equivalent64-tick ECS comparison.

Renderer caches, buffers and browser scheduling are useful product techniques, but their speed is not evidence that Bend ECS beats TypeScript. The README's greedy meshing example reduces geometry by68% yet reports36.7ms build against32.2ms scalar build: fewer quads do not establish faster rebuilding. Treat geometry and elapsed time as separate results.

## Native painter: ownership topology matters

The native experiment compares a single frame-wide array painter with tile-owned arrays at1024×1024. Author-reported timings:

| Painter | One worker | Eight workers |
| --- | --- | --- |
| Whole frame |47.65ms |81.90ms |
| Tile-owned |11.65ms |3.20ms |

[Recorded experiment and explanation](https://github.com/lennix1337/bend2craft/blob/2bd6fb0d612d16b4cade160a40102dfd67b837ba/lab/native/paint/README.md#L294-L337). This is a renderer draw comparison, not an ECS/native-versus-TS comparison. The old fold recursively forked an array handle at roughly350,000 interior nodes; each new tile creates, writes and folds its own Array inside one task, and carries its single owner through a sequential traversal. Only the coarse tree above tiles forks.

[Actual tile array and fold code](https://github.com/lennix1337/bend2craft/blob/2bd6fb0d612d16b4cade160a40102dfd67b837ba/native/paint.bend#L873-L991). No shared mutable frame array is required by this path. This does not demonstrate a generic split operation for already-existing arbitrary affine ECS owners; tiles allocate their own fresh arrays. Eight-worker results cannot replace our accepted one-worker gate.

## Transfer shortlist

1. Resolve query/storage once for an owned chunk; hoist loop invariants and use a flat traversal. Validate exact entity order, namespace/generation and complete effects.
2. Inspect owner-handle transport and generated allocations before adding threads. Form independent owned storage units only where ownership can be correctly partitioned. Keep arbitrary Type components.
3. Cache derived query/index work at correct invalidation boundaries; preserve per-write marks, true-old inverse journals and rollback visibility.
4. Use genuinely equivalent64-tick work for JS/native comparisons. No reduced simulation cadence, skipped failure effects, JS replacement core or Data-only restriction.

These are research hypotheses. No new law, API, benchmark contract, compiler update, dependency or performance keep is approved by this report.
