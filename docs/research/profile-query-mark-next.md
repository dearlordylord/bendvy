# Next profile hypothesis: flatten private mark transport

Proposal only; no core/backend/compiler/reference changes or measurements performed. Inputs are `/tmp/bendvy-composed-js-profile/{summary.json,bend.js}` and the 29-module source closure `/tmp/bendvy-live-first-native`. Pinned Bend2 commit: `a950fd683c0d76f09794078e6174fe98a1492876`.

## Observed source and emitted shape

The composed sampled JS bracket attributes 14.78% self time to `query:struct_idx_selected~2`, 7.58% to `transaction:prototype_storage_mark_guard`, 3.97% to `prototype_storage_mark_loop` and 11.50% to GC. These perturbed samples identify reached work; they are neither stable timing nor acceptance.

`transaction.bend:94–113` transports `(live,changed)` through every mark. Generated JS `bend.js:3982` returns a fresh Tuple for rejected handles; its product-split live helper at `:5491` returns one for both dead and live handles. The tail loop at `:3810` immediately reads `fst/snd`, then replaces its transport parameter with the guard result. Product splitting already removes the intermediate `Array.get` pair at this call, but the final per-mark transport Tuple remains. Other World/Rows/metadata fields are already threaded without per-mark reconstruction.

The query's selected branch at `query.bend:82` emits a fresh `None` plus `array_rmw(main,index,()=>none)`. Pinned `comp.ts:225` maps `Array.swap` to that runtime operation; `comp.ts:6014` updates the affine array and returns its old value in a Tuple. This is actual ownership transfer used by the abstract read callback, not an optional copy of a Data component. Removing the swap without a replacement ownership discipline would change generic affine behavior. I would address the narrower mark tuple first.

## Exact bounded source candidate

Keep public `storage_mark_all` and transaction representations unchanged. Give the private `prototype_storage_mark_loop` **separate affine `live` and `changed` parameters**, replacing its pair parameter. Inside the `Con{Handle{foreign,id},rest}` branch, nest the existing validity match and the existing `Array.get`/live match directly:

1. Invalid namespace, zero, above capacity or above high: recurse on `rest` with both arrays unchanged.
2. Valid dead slot: recurse on `rest` with the returned live array and unchanged changed array.
3. Valid live slot: recurse on `rest` with that live array and `Array.set(U32,changed,id-1,tick)`.
4. Nil: construct the original World/Rows/metadata exactly once.

Use direct recursive calls in these exclusive branches, rather than a helper cycle returning another pair. This leaves structural recursion on the same list tail visible and is intended to preserve the emitted stack-safe loop. Whether the checker/compiler accepts and lowers it that way must be observed; no check was run here.

Each affine owner/array appears once in its selected branch. Only the already Data guard scalars may be duplicated. Do not add `Data` to M/A/L, copy a Raw owner, sort/deduplicate/filter marks, or fuse publication with marking. Keep the exact original validity expression, modulo/index semantics, repeated/nonmonotonic mark order, tick assignment, added stamps, flags, main/aux ownership, namespace/next/capacity/depth/high, pending commands, ledger and mode. `storage_commit:117` must still mark the complete committed list before publishing reversed commands and returning complete pings; Reverted still returns its original world and empty pings. Undo/journal/old Data snapshots remain unchanged.

## Decision and validation limits

First inspect generated JS: the guard/live result Tuples must actually disappear, Array.get product splitting and direct tail recursion must remain, and no hidden per-mark World/state wrapper may replace them. Native has a different flattened ABI; extra separate parameters can change transport costs, so no native benefit is inferred.

Required finite diagnostics include both schemas, empty/repeated/nonmonotonic batches, foreign/zero/hole/high/capacity/max handles, complete physical stamps/fields, rollback/journals/pings/retained old Data, and actual compiling omitted-mark/guard mutants. Re-run abstract access controls and the connected capability gates before any acceptance claim. Keep checker diagnostic15, codegen30, clang120 and runtime5; proof/default5 unchanged. Only an adjacent equivalent full-field comparison can decide whether allocation reduction improves time. E11's present TS timeout failures and unexecuted mutants remain separate open gates.

## Actual source feasibility result

The [bounded source probe](../../experiments/s-prep/mark-loop-scalar-transport/evidence/summary.json) does **not** compile. Direct nested matching rejects computed scrutinees. Dedicated scalar guard/live helpers create a live mutual forward-reference cycle and are rejected as an unfilled definition. A tiny frozen-continuation diagnostic also rejects the unfilled loop. All three precise checker failures are retained; no source candidate, normal-nine construction count, Tx/access/mutant/runtime or speed claim exists. Do not add closures or extra loop stages to force this hypothesis in the current window. An emitted-backend tuple-edge optimization is distinct and must establish its own unchanged-operation binding and controls.
