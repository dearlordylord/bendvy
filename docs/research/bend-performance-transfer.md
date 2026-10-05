# Bend product optimization: transfer to Bendvy

Research snapshot: 2026-10-05. This is an investigation and experiment shortlist, not approval of a new ECS API, law, dependency, performance keep or benchmark contract.

## Sources and applicability

- Official current source: bendlang/bend `8828cc19ed270c2144c3698bd9ebd7d504a3cab5`, disposable checkout /tmp/bendvy-research-bend-current. Installed compiler reports2.0.35; current changelog also starts2.0.35. Existing read-only Bend reference remains `a950fd683c0d76f09794078e6174fe98a1492876`, matching .references/sources.json. No compiler update performed.
- [Bendcraft investigation](bendcraft-performance.md): actual Bend/JS boundaries and benchmark evidence.
- [Other products](bend-products-performance.md): voxel renderer and toon serializer source/evidence. These examples establish mechanisms, not our ECS performance.
- Bend1/HVM2 recommendations cannot be transferred as compiler/runtime evidence for Bend2. The current repository explicitly distinguishes the languages. [README](https://github.com/bendlang/bend/blob/8828cc19ed270c2144c3698bd9ebd7d504a3cab5/README.md).

## Strongest official example: Slash Boss rasterizer

The project ships a dedicated [optimization guide](https://github.com/bendlang/bend/blob/8828cc19ed270c2144c3698bd9ebd7d504a3cab5/guide/SHADERS.md) and [actual library](https://github.com/bendlang/bend/blob/8828cc19ed270c2144c3698bd9ebd7d504a3cab5/demos/app_slash_boss_3d/bend3d.bend). The guide identifies itself as AI-written and awaiting human revision. Its numbers are author-reported M4 shader measurements, not measurements independently reproduced here.

| Mechanism | Author-reported evidence | ECS implication / limit |
| --- | --- | --- |
| Tail-recursive flat leaves rather than nested folds and non-tail continuations | Folded drawing5.5→12.6ms; per-level/per-pixel fold600ms vs8ms frame | Inspect whether the query/callback path compiles to flat spins or segmented frames. GPU frame numbers do not predict JS or single-worker ECS results. |
| Ownership shape enables compiler borrowing | Counted reads8.0→16.5ms frame | Inspect `term_peek` versus `term_keep`, `ctr_take`, `rfc_seal` in the exact timed call path. Borrowing of shareable boxed scene data does not grant borrowing/sharing of affine component arrays. |
| Narrow scalar records and typed operations |52-word records6.3→12.1ms draw | Move invariant state outside per-operation transport; count actual constructor/frame allocations. Keep every observable field and owner. |
| Static template parameters | Constants/functions become compile-time inputs | Specialize schema/provider identity while keeping the genuinely runtime user callback. A template instance alone does not guarantee a flat whole call chain. |
| Work reduction and batching | Four-pixel list walk6.6→5.6ms | Amortize query setup and storage resolution per chunk without merging per-write journals/marks or changing ordering. |
| Balanced coarse fork trees | Tiny tasks lose to scheduler; too-fine GPU work adds iterations | Native parallel experiments are separate from the accepted one-worker baseline. JS remains sequential. |

The concrete source uses specialized `word`/`pick` near its beginning, tail `Blk.go`, explicit `Tile.fin` disposal, and `~` parameters on `Tile.go`/`Cell.fork`. This confirms the mechanisms exist in the application; it does not independently confirm the reported speedups.

The guide recommends interleaved pairs in both orders, warm-ups, an A-vs-A control, stage attribution and identical output checks. Our recent complete112-record comparisons pass, but noise qualification fails; this is an experimental problem to isolate rather than a reason to weaken its10% gate.

## Bendcraft mechanism with the closest ownership analogy

The inspected Bendcraft native painter creates, writes and folds each tile array inside one task. It does **not** share one frame array or split an arbitrary pre-existing ECS owner. Its [native paint experiment](https://github.com/lennix1337/bend2craft/blob/2bd6fb0d612d16b4cade160a40102dfd67b837ba/lab/native/paint/README.md#L294-L337) reports1024-frame drawing47.65→11.65ms on one worker and81.90→3.20ms on eight. The source explains that the old fold forked the array handle at roughly350,000 interior nodes; the tile fold carries one owner sequentially. These are author-reported renderer timings, not independently rerun here.

This is stronger guidance for us than “add threads”: eliminate recursive owner-handle transport first; form independent owned storage units only where a correct ownership partition exists. Creating fresh tile arrays does not establish that arbitrary ECS component arrays can be shared or split cheaply.

The browser terrain rewrite's Nat→U32 result must be read against its older compiler pin: current2.0.35 already has the JS numeric-Nat/tail-call changes introduced in2.0.29. Per-column invariant hoisting and bulk calls remain useful hypotheses; an old475→4ms claim is not a forecast for our current core.

## What the language actually permits

[Array ownership](https://github.com/bendlang/bend/blob/8828cc19ed270c2144c3698bd9ebd7d504a3cab5/guide/GUIDE.md#arrays): `Array<T>` is affine Type, returned alongside reads; Data elements support get, Type elements require owned swap. In-place writes are already a language feature, not a reason to make all components Data or move state to foreign JS.

[Templates](https://github.com/bendlang/bend/blob/8828cc19ed270c2144c3698bd9ebd7d504a3cab5/guide/GUIDE.md#templates): closed static arguments specialize function instances. They cannot capture caller-local state. Our existing `motion_invoke(~client, owner)` passes four provider functions as ordinary arguments to a universally typed client, so specializing the outer client is not equivalent to eliminating its inner dynamic provider calls.

[Pinned compiler analysis](https://github.com/bendlang/bend/blob/a950fd683c0d76f09794078e6174fe98a1492876/bend2/comp.ts#L1170): flatness depends on the complete callee graph; borrowing/ownership is inferred by the emitter. Inspect emitted code from the installed compiler before attributing costs.

[JS2.0.29 change](https://github.com/bendlang/bend/blob/8828cc19ed270c2144c3698bd9ebd7d504a3cab5/CHANGELOG.md#2029-2026-09-26) already introduced numeric Nat, tail cycles and direct calls where safe. Installed2.0.35 already contains this generation; updating solely for that historical2.3× claim would be invalid.

## Next experiments, in order

1. **Attribution before another broad fusion.** Map the exact generated Motion/Health timed call chains to flat calls, closure dispatch, constructor/frame creation and array access. Attribute provider transport versus arithmetic/storage. Static counts are diagnostics; wall time must decide.
2. **Static provider boundary probe.** Compare an equivalent closed provider specialization with the opaque affine callback route. Preserve the same four operations, full owner and complete records. This is a separate architecture experiment: current protected callbacks/signatures must not be silently rewritten under the13-module body contract. Keep the dynamic case as a negative performance/semantic control.
3. **Owner transport probe.** Keep Type components and owned arrays; separate invariant world context from frequently changed row state internally. Test whether fewer wrapper/tuple/frame round trips survive codegen. Preserve complete rollback inverses, every mark, queue/cursor ordering, true Raw old values and ownership confinement. Existing writer fusion has no qualified speed keep.
4. **Owned chunk traversal.** Resolve the query/storage route once for a bounded owned chunk, run a flat loop, then restore ownership. Preserve iteration order and per-command/per-write effects. Generalization needs the existing negative capability controls, not a scalar Data-only benchmark substituted for ECS.
5. **Measurement isolation.** Profile a stable single-worker workload, interleave both orders and run A-vs-A. Proposed changes to workload, repetition/noise contract or evaluator require explicit governed transition; retain existing numeric targets.

Full product scope remains open. Rendering FPS, native Vulkan/C helper speed, retired Bend1 scaling and serializer instruction-count wins are not JS≤bevy-ts/native≥2× ECS acceptance. No new law or proof was written.
