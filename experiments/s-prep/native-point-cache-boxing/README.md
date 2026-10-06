# Private Native point cache boxing

Bounded #21/#24 source hypothesis, based on master `9cc7d57` and the exact 29-module `/tmp/bendvy-live-first-native` overlay. No adoption, full connected-gate acceptance, universal refinement/proof, or speed acceptance is claimed.

The patch changes only `held-adapter.bend`: new `prototype_cacheboxed_{motion,health}_*` private helpers hold Main and Ledger as `PrototypeWorldBox<CC.Cache<Raw,View>>`. Existing World boxing, public Cache/storage types, every original definition/type header, callback signatures, guards and fallback bodies remain. Both schemas use the same generic recursive affine box and total finite recursive unbox. Neither Raw nor the box requires Data.

Existing invariant mapping: get preserves raw ownership and returns the immutable Data snapshot; setters retain actual raw swap's old value, patch the cache view, and retain inverse/journal/mark ordering; return consumes both boxes once and restores every original storage/transaction field. Nested cache constructors recursively peel only the affected field; untouched cache ownership is transported. This mapping introduces no new ECS law. The exported experimental recursive constructors do not establish a new production authority boundary.

## Reproduction

```sh
bend version
bend guide
python3 materialize.py --input /tmp/bendvy-live-first-native --output /tmp/bendvy-native-point-cache-boxing-fresh
python3 probe.py --candidate /tmp/bendvy-native-point-cache-boxing-fresh --baseline /tmp/bendvy-live-first-native-static --output /tmp/bendvy-native-point-cache-boxing-build-fresh --cpu 10
python3 controls.py --candidate /tmp/bendvy-native-point-cache-boxing-fresh --output /tmp/bendvy-native-point-cache-boxing-controls-fresh --cpu 10
python3 abi.py /tmp/bendvy-live-first-native-static/batch.c /tmp/bendvy-native-point-cache-boxing-build-fresh/batch.c
```

Executable checker 15 seconds is explicitly opted in for this task; proof/default 5 seconds are unchanged. CPU 10; C emission 30 seconds, clang 120 seconds, runtime 5 seconds. The runner supervises process groups and records failures. Static Motion64 driver and measurement source change only their exact absolute runtime import prefix, preserving all original callbacks/work. Materialization checks all 29 source pins, cache closure receipts, original headers and a single changed runtime module.

## Evidence and limits

`evidence/build.json`: static Motion64 checks, emits C and builds successfully. `runtime.json` plus compressed raw logs: baseline and candidate each finish within runtime 5 seconds; all 66 output lines and every non-timing field agree after removing only top-level JSON `milliseconds` and the `BATCH-MILLISECONDS` line. These runs are diagnostic, not a performance sample/cohort.

Reached actual Motion row C ABI (`abi.json`): read branch goes from 21 value/7 quantity parameters and 22 return words to 9/7/10; setter branch 22/7/28 becomes 10/7/28; return branch 10/6/11 stays. Spin identifiers are discovered from generated row dispatch, not assumed stable. Pinned compiler `bend2/comp.ts:938` boxes recursive datatypes; this explains the layout reduction, not runtime speed. Extra boundary allocations, reboxing and recursive drop can offset transport savings.

`controls.json`: an arbitrary affine Array-owning Raw survives two nested boxes and returns 30; generic box duplication and cross-schema cache conversion are rejected for their exact intended reasons. Initial computed-scrutinee fixture failure and subsequent diagnostic-recognizer mismatch are retained separately; neither is counted as an intended negative witness.

Follow-ups owned by integration: actual Tx/access controls, Health callback runtime, full connected gates, and measured allocation/drop/speed comparison. Actual new mutation anchors are `prototype_cacheboxed_*_set_fused_done` (`X.MainInverse{handle,old}`, `handle <> marks`) and `prototype_cacheboxed_*_setledger_fused_done` (`X.LedgerInverse{old}`). Shared recognizers must target these reached helpers, not unused original fallbacks. No canonical autoresearch packet, cohort, keep, or cap reset occurred.

## Adjacent actual-owner controls

`evidence/new-control-summary.json` records fresh CPU 10 runs using the exact master shared runners and explicit checker 15-second opt-in. Original Tx and both compiling lost-mark/inverse-order mutants each exercise all eight cached/raw × Motion/Health × JS/Native lanes, with 72 records per lane. Original full fields agree; mandatory suppressed-setter controls preserve the unchanged affine raw/cache owner, true-old journal and Main marks. Both mutants are detected at the actual `prototype_cacheboxed_*_set_fused_done` sites. No terminal compiler blocker occurred.

Negative access passes all nine existing cases (including the historical String duplication case); static provider boundary passes two positive and six negative cases; actual factory boundary passes all 16 existing controls. Source-bound receipts and compressed derived sources/output are retained. This is finite control evidence, not full connected acceptance or universal confinement.

Two failed attempts remain: expanded `--raw-snapshots` control-overlay measurement imports produce 30 reachable modules, so suppression's exact 29-module closure assertion fails; Tx/suppression reruns use the original exact29 recipe overlay. First access destination collided with existing `/tmp/static-world`; fresh unique-parent rerun passes. Follow-up: shared access receipt currently serializes checker limit 5 although its checker honors the explicit environment opt-in 15; `new-control-source-binding.json` records the actual configuration and pinned unchanged runner sources. Shared runners were not edited.
