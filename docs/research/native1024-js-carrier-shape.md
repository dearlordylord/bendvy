# Dense1024 JavaScript carrier shape: concrete v3 versus fused v8

Read-only analysis during root's active raw cohort. No runtime child, profile, comparative clock, source edit or recipe edit was executed. Static constructor sites below are not executed allocation counts or physical heap measurements.

The new concrete carrier does **not** introduce a reconstructed MainSlot or extra transport Tuple at the inspected successful query/handoff boundaries. Its Native flattening changes are erased in generated JavaScript. A performance difference cannot be attributed to a new owner rebox from these bodies.

## Exact inputs and comparison

Raw Dense1024 programs, each from its completed source-specific build:

| Schema | Fused v8 program | Concrete v3 program |
|---|---|---|
| Motion | `/tmp/bendvy-handoff-v8-motion-dense1024-build-r2/batch.js`, SHA `a1d038db84faa4163c096d5ad1f6d10a864e0111f7b51c148461f61ee0881fa8` | `/tmp/bendvy-concrete-owner-motion-dense1024-build/batch.js`, SHA `e5ee1a6f0afaef8f2384945f6c934bf10cf090a4cf627d68d0cd49a81cda0d17` |
| Health | `/tmp/bendvy-handoff-v8-health-dense1024-build-r2/batch.js`, SHA `2a926fe0db04bc318ee012f14bf90da48d5fbcc2b3d470b61f7782c7d7c238c0` | `/tmp/bendvy-concrete-owner-health-dense1024-build/batch.js`, SHA `2141cba7a4a601e04745bf047b84d882bbd2761ef71630c18bed0e766962b15a` |

The concrete source closure is `a4672d110446195e3ac92911c6f41166b62025811df8816878356d0eafd08a55`. Both entries use count1024, batch64 and ticks64. The separate guarded enrollment package is commit71583e8; its consumed files remain unchanged.

Twelve corresponding query helpers were compared: inspect/restore, selected/metadata/live, advance/go, finish/read/world-return and recovery/go. Motion bodies are text-equal after replacing only exact source namespaces and corresponding private function/type names. Health has an additional specialization-label change in six helpers (`$1261$` to `$1260$` in definitions and their matching calls); the inspected diffs contain no other operations. This is an emitted binder-label difference, not a removed runtime argument. The previous admission inspection also verifies all seven owning row/provider bodies equal after namespace replacement, including their exact12/15 fields.

## Specific successful sites

`prototype_concrete_{motion,health}_handoff_inspect_state` still computes the U32 index, creates `None`, and calls `array_rmw(main,index,()=>none)` as the last argument to restore. This matches the generic v8 helper. The runtime swap returns a fresh Tuple; this Tuple comes from the existing runtime, not from knowing MainSlot's fields.

The successful restore branch is equivalent to:

```js
const main = result.fst;
const cell = result.snd;
const owner = cell.value;
return { $: State, main, aux, live, flags, added, changed,
  values: { $: Con, id, owner, rest: values } };
```

There is no MainSlot literal, spread, owner field projection or owner copy here. `owner` is the same opaque object extracted from the evacuated Some. Both versions have one State plus one Con literal in the successful branch. Across both branches, restore contains three static object-literal sites: two alternative States and one Con. The concrete Con retains exactly the same JavaScript `$`, `id`, `owner`, `rest` property layout. Native's known9/11-word owner fields do not become9/11 separate JS Con properties.

The HA drain also preserves the same ordered operations. The successful call passes a literal Tuple containing columns and `Some(owner)`, plus a Handle. The guarded direct-Tuple layer removes that literal Tuple in both source enrollments. It does not add a MainSlot rebox. Taken projects MainSlot fields into the same12/15-field row; returned reconstructs the nominal MainSlot/Some and ledger/Some at the same column/return boundaries. Those existing restoration sites occur in both versions. LedgerNone still follows the unchanged recovery path, including reconstruction of the current Con before restoring remaining columns.

## One real remaining boundary, not a concrete regression

The query inspect → restore edge still contains an eligible-looking constant-arrow `array_rmw` followed by a receiver that only projects the result's `fst` and `snd`. A separately enrolled positioned-swap scalar bridge could preserve prior argument evaluation, modulo, true-old read and None write while passing array and old cell as scalars. This targets one existing dynamic Tuple and one constant arrow at that boundary; it does not mutate owning envelopes, cached Data or nominal MainSlot values.

This is only a bounded opportunity for strict admission assessment after the cohort. It needs current source/runtime/call/body pins, plain owning-array confinement, initialized constant binding and exact projection-only receiver guards, then fresh full65, current retained/rollback/true-old/recovery and refusal controls. The old swap catalog cannot be reused as acceptance. Earlier swap-only probes were mixed; prior V8 traces showed runtime swap inlining, so lexical removals may already be optimized away. No new implementation or expected elapsed gain is approved by this note.

The completed raw cohort, actual V8 attribution and fresh semantic controls must decide priority. This analysis finds no new JS owner reconstruction mechanism to explain an apparent concrete-source regression while the cohort is still incomplete.
