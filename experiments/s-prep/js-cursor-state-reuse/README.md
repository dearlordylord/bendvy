# Private Cursor state reuse: bounded mechanism evidence

This separate generated-JavaScript probe removes one executed private `StructColsState` object per queried ID. It starts from the original frozen Cursor row/token/Tuple/nested programs, excluding constant-swap. The integrator's constant-swap diagnostic had no elapsed benefit (Motion196 versus parent186ms; Health192 versus parent192ms); those unqualified observations are not an acceptance result.

The exact source is `/tmp/bendvy-private-id-query-v4`, 29-module closure `bdf6b2fc46d2a89615d0e9eb48d44f4a3e8c8f2ff5b8268d7ca50463e6bfbe94`. Bend/source/compiler/Native are unchanged. The catalog pins all actual sources, upstream recipes/catalogs/receipts, six helper bodies and the unique iterative Cursor caller. Its admitted input list contains only the two batch programs.

## Ownership and confinement

The pinned source declares `StructColsState<-M: Type,-A: Type,-F: Data,-O: Data> is Type`. Its seven fields are owning Main/Aux arrays, live/flags/added/changed arrays and immutable Data observations. Main/Aux remain arbitrary affine Type, with no Data-only restriction. `prototype_cursor_read_rows` creates one state from the owned Rows fields; `prototype_cursor_struct_idx_go` moves it through the iterative loop and finally restores all fields. This exact Cursor path only collects Data U32 IDs; it does not invoke an arbitrary client or expose the state. The generic query and getters remain unchanged.

The new family clones advance → direct-Tuple helper15 → helper16 → Cursor selected → inspect → restore. Only the pinned Cursor loop's advance callee is redirected. Original functions and their other edges remain intact. Five terminal state literals become ordered evaluation of all seven original field expressions into fresh locals, followed by plain-field assignments and returning the same owned state. Main restoration, Some/Con construction, selection/live guards, true-old ownership, empty/missing/dead branches, stamp arrays and immutable Data list tails remain. The existing Array.swap constant arrow remains unchanged; no new per-call closure or Tuple is introduced.

This legality argument is specific to the typed, closed source and plain fresh state producers. The recipe refuses changed input/provenance/body/shape/arity, reflection, unknown closures or reserved names. It is not a general record optimizer, universal affine alias theorem, compiler refinement, or API approval. External getters/Proxies/frozen Type states or FFI aliases are outside its admitted programs.

## Fresh observations and explicit open scope

Both schemas pass fresh full65 fields and independent before/after nine-world counters. Motion expressions decrease 5,242,944→5,111,872; Health4,983,360→4,852,288. The exact decrease131,072 is one state object/update; closures are unchanged. This is not a physical allocation, heap-traffic or speed result.

Fresh actual private Cursor witnesses compare26 records/schema: lengths1/2/4/8, Required/Present/Absent selection, missing/dead Main, full owning payload arrays and scalars, namespace values, all metadata arrays, ascending IDs, retained frozen Data snapshots/list tails, and invalid branches. Four syntactically compiling counterexamples suppressing actual clone5 ID publication or Main restoration are detected by those witnesses. Eight structural/body/reflection refusals pass. A byte audit verifies all original functions except the one redirected caller remain identical (and that caller changes only one callee); six private clones are added. This structurally preserves generic/fallback exposure but does not independently exercise a nonidentity generic client.

**The current protected transaction matrix does not exercise this mechanism.** All eight supplied-ID Cursor controllers contain zero query advance/go helpers. The initial strict ten-input enrollment refused this missing frontier; the final catalog retains only the two actual batches. Existing576 controller observations and earlier query/lifecycle controls are not transferred. A fresh source-bound enumeration/controller integration and independent generic/fallback exposure remain OPEN. This package is mechanism-only and must not be promoted as an accepted full-chain optimization.

Motion candidate `/tmp/bendvy-cursor-state-motion.js`, SHA256 `824541a381f3196fc4e81de91d22ddd63371c40f53a387a580e2a14d9b213bd1`.
Health candidate `/tmp/bendvy-cursor-state-health.js`, SHA256 `00d696faa2249a6d67783e140157690aafe634442d4c52f0d78072b0c5e410b7`.

## Reproduction

```
node --expose-internals rewrite.cjs EXACT_BATCH_INPUT.js FRESH_OUTPUT.js
python3 count-controls.py --output FRESH_DIRECTORY
python3 witness-run.py --output FRESH_DIRECTORY
python3 mutants.py --output FRESH_DIRECTORY
node --expose-internals guard-controls.cjs EXACT_BATCH_INPUT.js EXACT_CANDIDATE.js FRESH_DIRECTORY
```

CPU7, five-second descendant-supervised runtime commands; no new tools/dependencies or compiler invocations. Full65 uses the existing unchanged recorded validator. Failed attempts remain: enrollment found the eight absent frontiers; the first closure guard incorrectly rejected the existing unchanged Array.swap arrow; the first witness used nonexistent Any/Without variants, corrected to actual Required/Present/Absent; the first refusal test changed an unrelated same-named state return, corrected to the pinned family body. These were harness/admission failures, not discarded semantic counterexamples.

A subsequent descending SOURCE cursor has higher integration priority. This probe remains separately frozen on its original source; no admission or evidence is inherited by the descending source.
