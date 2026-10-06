# Bounded emitted affine Tx/World/Rows reuse

This probe changes only pinned emitted JavaScript. It reuses the affine owner in the actual Motion `measurement-bend.motion_select`, and the affine World/Rows in reached `prototype_boxed_motion/health_return_world`. No Bend/source/compiler/kernel/reference/dependency/law/proof changes, source adoption, universal alias proof, canonical cohort or performance acceptance.

The exact baseline is `/tmp/bendvy-cache-box-js-build/baseline.js`, SHA256 `4c01f06e3460c9b3752ec2ff3ddfbdaa8c59ec1af321d89fe83068f43c02b7dd`. The output is `/tmp/bendvy-owned-world-reuse-final.js`; its exact hash and final recipe/source pins are retained in [baseline.recipe.json](evidence/baseline.recipe.json). [input-pins.json](input-pins.json) pins nine inputs and their actual source facts. This is an independent baseline probe, not composition with token or boxed Held/Cache reuse.

## Preconditions and transformation

The recipe requires the actual source declarations `Tx`, `World`, `Rows` to be `Type`, exact source hashes, reserved-binder absence, unique target definitions/parameters, pure recognized const prefixes and ordered constructor tags/fields. It checks `fields_checked → prototype_boxed_taken → invoke/return → return_world`, the unique restore caller, and the successful branch's Held → PrototypeWorldRoot → World with detached ledger None. Handles, Data views, None nodes and snapshots are never mutated.

The selected-Tx transformation requires every field except selected to be an exact projection of the owner. It assigns only selected and returns the original Tx. The actual baseline has one Motion selector; the controller fixtures have no measurement selectors. Health selection is not claimed on these inputs.

Restore requires unchanged World fields to project the original World, unchanged Rows fields to project its Rows, and the main-array expression to be precisely the original Array.set sequence on that owner's array. It evaluates every original nested field expression **in original depth-first field order**, including Array.set, new Some ledger, new Handle and total, before any World/Rows assignment. It then assigns the owned Rows/World. Tuple, returned Tx, Handle and Some constructors remain fresh. No extra context, stale-owner global or broad optimizer is introduced.

## Fresh results

- CPU8; five-second per runtime: quiet and counted profiles each match all fields of nine Motion256 worlds against fresh pinned TS (warmup +eight measured worlds,64ticks).
- Same instrumentation baseline10,086,976 →candidate9,693,760 executed construction expressions: **−393,216 =three ×131,072 callbacks**. Tx, World and Rows each fall131,072; every other normalized kind, including closures, is equal. These counts are not physical allocation bytes.
- Eight freshly executed cached/raw Motion/Health and suppressed-main cached/raw Motion/Health controllers match72 full JSON records each,576 total. Stored normal fixtures also match. Suppressed fixtures are compared to fresh originals.
- Four original/rewritten ×Motion/Health private restore-helper witnesses retain and freeze explicit old Data snapshots across restoration. Full World/Rows fields, raw main/ledger, selected Handle and transaction journals match expectations; rewritten World/Rows identities are retained. These trusted helper inputs are not a full-world or public raw-owner API test.
- Original/rewritten Motion selected-Tx witnesses preserve all full fields, frozen cached Data and old Handle; the rewritten Tx identity is retained.
- Eight synthetic AST mutations refuse before output: wrong selected-Tx/World/Rows identity, field order, reserved binder, extra restore caller, impure prefix and disconnected reached family. Test-only copied catalogs exercise structural checks after pinning; shipping has no bypass.

The first prototype failed output parsing because an Array.set sequence needed parentheses in a const initializer. No output was written; the corrected recipe wraps captured expressions and reparses before writing. The first guard harness expected the wrong diagnostic for a nonexistent metadata binder; the shipping recipe rejected it before output. Both setup failures remain recorded, not counted as semantic failures or passing gates.

The final pure-prefix tightening changes recipe bytes but produces byte-identical baseline output to the profiled strict output. [Counts](evidence/counts.json) records exact normalized deltas; [archive index](evidence/archive-index.json) records compressed observations, controls, snapshots and guard receipts. Root owns subsequent fresh composition and timing comparisons. No runtime speedup is claimed here.

```sh
node --expose-internals rewrite.cjs /tmp/bendvy-cache-box-js-build/baseline.js /tmp/fresh-owned-world.js motion
python3 /workspace/formal-proofs/bendvy/experiments/s-prep/js-profile/run.py --cpu 8 --no-gc --generated-js /tmp/fresh-owned-world.js --output /tmp/fresh-profile
python3 run-controls.py --output /tmp/fresh-controls
node --expose-internals guard-controls.cjs /tmp/bendvy-cache-box-js-build/baseline.js /tmp/fresh-guards
node --expose-internals select-witness.cjs /tmp/bendvy-cache-box-js-build/baseline.js /tmp/fresh-owned-world.js /tmp/fresh-select.json
```

Further gates: arbitrary affine layouts, external aliases/interleavings, general compiler/source lowering, Health full-world performance, Native and full22. This bounded emitted probe does not weaken existing ownership/access/performance requirements.
