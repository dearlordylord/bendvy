# Final-chain same-slot Raw store elision

The exact old-role inputs are final Motion `bc4382c11d55169a8b138b8ab83ae662cd6574b98ed3ba0d347ff6f7233814b6` and Health `d443000ec80e45824ccea88ca109514076d8386a01590e2ca4ed490859e48506`; exact hashes/output hashes are in [summary](evidence/summary.json). This is separate from newer frozen-query sources. No source/compiler/core/reference change, Native claim or performance acceptance.

`rewrite.cjs` admits ten explicitly pinned final-chain programs and their actual 29 sources. All four Raw payloads remain Type. It verifies one exact projection-only caller, one referenced derived receiver, same consumed owner, exact array/old-read/metadata/value arguments, plain fields/no getters/proxies/reflection and no receiver calls/captures/owner identity/FFI escape. It resolves receiver parameters and local aliases back to the caller's original owner fields. Array RHS must retain the exact original Array.set sequence and return that identical owned array; metadata RHS must resolve to that same original Raw slot.

Only complete same-slot assignment statements are deleted. Every original const/RHS expression, old read, Array.set, argument order, Tuple/true-old return and all changed array-element writes remain byte-for-byte. All evaluations still precede the deleted property stores. A changed field, unknown expression, wrong old read, early store, extra edge or metadata arithmetic rejects; it is not silently removed. Motion removes 4 redundant Raw property stores per callback; Health 5. **Zero necessary Raw property stores remain**, because every omitted assignment's identity is established structurally. The original array element mutation remains necessary and executes.

Fresh nine complete Motion worlds and nine complete Health worlds match fresh TS on all fields. The eight exact fresh actual direct inputs had already admitted the unchanged full nine-stage chain; this recipe acts on those exact final outputs, compares each 72 records byte-for-byte and re-runs the protected independent true-old/undo/marks/rollback/value oracle plus mandatory expected_noop and cached/raw equality: **576 records**. Diagnostic counters prove both direct derived receivers execute in each program. Four trusted retained frozen Data/full raw metadata witnesses pass. Twelve intended copied-catalog refusal/order controls reject before output; shipping has no bypass.

Counter kinds, including closures and Tuples, are identical before/after: ordinary eight-world timed-phase **5,498,944** expressions, instrumented **5,498,945** with one marker object. Quiet and counted nine-world fields both pass. Store elimination does not invent allocation reduction or speed evidence. Final-chain lost-mark guard refusal remains open; no new mutation execution/full-22 claim is made by this refinement.

```sh
node --expose-internals rewrite.cjs /tmp/bendvy-js-final-profile-chain/baseline.js /tmp/fresh-raw-stores.js
python3 run.py --output /tmp/fresh-raw-stores-controls
taskset -c 10 node --expose-internals guard-controls.cjs /tmp/bendvy-js-final-profile-chain/baseline.js /tmp/fresh-raw-stores-guards
```

CPU 10, every actual runtime/instrumentation/refusal capped 5 seconds. Existing profile orchestration has 25-second supervision around its individually supervised five-second phases. Proof/default 5 unchanged; no Bend compiler call or new laws/proofs/dependencies. Receipts, exact inputs/outputs/recipes, full records, counter maps, source closures and diagnostics are retained. Root owns adjacent timing. Generic alias/FFI legality, public owner exposure, new source roles and broad acceptance remain follow-ups.
