# Recursive immutable Data view boxing diagnostic

Bounded source hypothesis in detached worktree from `9cc7d57`, inside the user-authorized diagnostic window. This does not reset canonical caps, adopt a representation, qualify performance, change compiler/kernel/references/dependencies, or add laws/proofs. The governing full ECS and performance gates remain open. Applied Bend LDD, read checkpoint/#19/SPEC and R-A/R-C1 boundaries; `bend version` reported 2.0.35 and `bend guide` was read. Absolute read-only reference commits match the tracked manifest (bevy-ts `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`, bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60`, bend2 `a950fd683c0d76f09794078e6174fe98a1492876`).

## Mapping and scope

The original `PositionView`, `VitalsView`, and `LedgerView` root constructors and every field remain unchanged. Each Data type gains its own `*ViewNested{inner:sameView}` constructor. The representation map recursively erases Nested wrappers and retains the complete root's Four and metadata. Every finite inhabitant reaches one root, with no dropped affine owner. Patch helpers peel Nested then replace only cell a in a fresh logical root; all b/c/d and frame/reserve/class/epoch survive. Renderers and checksums peel recursively. Eight tuple callback destructors delegate to private helpers that match on the view and recurse directly on inner, while carrying the arbitrary affine Owner unchanged. Existing public function/type headers and original root callback expressions remain intact.

Only five of the 29 runtime modules change: types, cached-payload, host-render, measurement-bend, prototype-static-client. The generic `Cache<Raw:Type,View:Data>`, protected payload, world/Held ownership, guards, journals, stamps, commands, queues and fallback algorithms remain unchanged. No Data-only Raw restriction is introduced. The baseline already includes world-context boxing and previous source optimizations. Authored construction produces only original roots; Nested cases make the extended type total rather than adding wrappers on each update. Adding variants expands the constructor set: external exhaustive view matches require corresponding peel cases. This is not a backwards-compatible production API claim.

## Reproduce

```
python3 experiments/s-prep/native-view-boxing/materialize.py --input /tmp/bendvy-live-first-native --output FRESH_OVERLAY
python3 experiments/s-prep/fivehour-measurement/prepare-bend.py --core FRESH_OVERLAY/experiments/s-integrate --output FRESH_BUILD --schema Motion --batch 64
python3 experiments/s-prep/static-schema-driver/materialize.py --driver FRESH_BUILD/batch.bend --schema Motion
```

The materializer requires a unique absent output, exact all-29 input pins, actual/overlay/both cache closures agreement, matching closure hash and coherent embedded/standalone cache receipts. It applies only the catalogued five-file patch, preserves public headers, checks the exact output closure, and refreshes both manifests. `/tmp/bendvy-native-view-boxing-reproduced` reproduces the compiled source bytes from `/tmp/bendvy-native-view-boxing-v2`. The compiled C symbols retain the latter path. Frozen static Motion64 driver/C/binary are `/tmp/bendvy-native-view-boxing-build3/{batch.bend,batch.c,batch-native}`.

CPU9 sequential diagnostics: `bend DRIVER --check-only` cap15 passed; `bend DRIVER -o C` cap30 passed; `clang -O3 C -o BINARY -lm -pthread` cap120 passed. Run `BINARY --threads 1 --gpu off` cap5 and a freshly prepared TS Motion64 adapter under Node cap5. All 65 complete worlds matched the existing full validator and independent normalized full-world equality. Default checker was used; no proven-kernel verdict or universal proof is claimed. Evidence records commands and limits. A first run incorrectly tried environment variables for Native settings; the archived authoritative run uses actual CLI settings above. Its raw phase was 254ms; this is one diagnostic observation, not a stable speed claim. Root independently owns adjacent comparisons, JS profiles, Health integration and mutation gates.

## Retained snapshots and negative controls

```
python3 experiments/s-prep/native-view-boxing/run-controls.py --core FRESH_OVERLAY/experiments/s-integrate --output FRESH_CONTROLS
```

The positive fixture retains a read view, writes through the affine Cache, then prints retained old view, updated cached view, true-old scalar, all four raw array cells and metadata. Position, Vitals, MotionLedger and HealthLedger each run with an original root and a double-Nested view. JS and Native outputs match the independently specified eight expected lines exactly. The old immutable snapshot remains unchanged; Nested and root observations agree. The raw owned array is consumed through `Array.to_list`, with no lost owner.

Four five-second checker controls fail for the intended reason: Raw duplicated (`consumed more than once`); Raw bound with `+` (`Data` expected, `Type` observed); writing through a view (`Cache` expected); cross-schema Vitals cache used as Position (`Cache<Position,...>` expected). The executable positive check uses cap15, JS/C emits cap30, clang cap120, runtimes cap5. These are finite concrete controls, not universal runtime refinement or the full project capability gate.

## Actual C transport and offsetting costs

`analyze-abi.py` follows static calls from the named Motion row FID and archives exact bodies, parameter counts and routes. Numerical spin identity alone is not a source mapping. Two reached read-transport bodies in baseline (`spin_73` and `spin_57`) carry 21 r values, seven location q values, Env/out: 30 C parameters and 27 output words. Corresponding shapes in candidate (`spin_75`, `spin_53`) carry 13 r values, nine q values, Env/out: 24 parameters and 15 output words. Candidate route includes named row -> spin99 -> spin86 -> spin75. The terminal bodies preserve owner fields and return the selected cached snapshot. Candidate has one `term_keep` in each of these bodies; baseline has none. Native Root snapshots are actually boxed Terms; JavaScript root constructors are unchanged by this source recipe, subject to the root agent's independent emitted-JS checks.

The narrowing is eight value words, but two extra location arguments appear. More importantly, boxed immutable reads now create reference-count work. Each selected getter duplicates its snapshot with `term_keep`. The view matcher calls `ctr_take`: a shared snapshot goes through `span_fade -> term_drop`, reducing the shared count before its setter runs. Patch `ctr_take` can find count one, free the reference-count cell, and reuse the existing Root allocation (`_sp >= HEAP_OFF`), rather than allocate a new Root. Position and Ledger roots contain five scalar words; Vitals contains six. Their root patch branches preserve every scalar while replacing a. Nested branches free their one-word wrapper and recurse.

Thus the actual hot root path plausibly adds two keep/reference-count-wrap/drop cycles per callback while narrowing transported values; it does **not** necessarily allocate two new Root snapshots per update. Conditional node reuse is explicit in emitted C. This is static generated-path reasoning: operation sites are not dynamic execution counts, allocations or measured cost attribution. It explains why narrower ABI alone need not improve runtime. No compiler edit or new performance assertion follows from this probe.

## Failures and evidence limits

Initial materializer validation compared changed-module order rather than its set; it refused without writing output. Driver preparation then found an existing empty failed output folder; a fresh folder was used. The first checked source placed a view before static `~` binders and failed the ordinary leading-binder rule; its patch/diagnostic are retained. Corrected helpers keep static binders first and still recurse structurally on their view. Positive fixture preparation first had an f-string brace error, then used `IO<Unit>` rather than `IO(Unit)` in the function result; the latter checker failure is retained. These are not false semantic acceptance. No checker repair, proof, law or kernel change was used.

Evidence archives freeze all 29 compiled module bytes plus coherent cache/overlay manifests, complete C, binary, static driver, derived measurement source, fresh TS adapter, full outputs, expected controls and source-level failure. `evidence/index.json` records uncompressed hashes. Broader external match updates, universal snapshot/refinement arguments, Health/full22 mutation integration, allocation-frequency evidence and canonical acceptance remain explicit follow-ups.
