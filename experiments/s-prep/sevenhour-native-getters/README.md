# Direct Native cached getters

Only the four cached getter bodies in `cached-payload.bend` change from the static-cache baseline: Position, Vitals, MotionLedger and HealthLedger now match the nominal `C.Cache` directly and return the affine Raw owner plus its complete Data view. All existing imports, types and definition headers remain exactly equal. No private added header, callback edit, Raw mutation or representation change is introduced. This is a separate Native candidate; the selected JS source is untouched.

Fresh finite controls passed NativeO3 and JS against the full original Raw/cache field oracle, including scalarold0, metadata, allfour cells, independent uncached reads and repeated restoration. Wrong-cache-cell and Raw-tail-corruption mutants compile on both backends and are detected. Cache owner cloning is rejected. Fresh complete144 Tx cases passed on both schemas, with cached and independent original Raw observations, unchanged callbacks, inverse/marks and success/rollback. `tx-evidence.json` contains all eight72-record lanes.

Fresh complete measurement checker5s and C codegen30s passed on CPU8. All checks/builds/runtimes remain CPU8; runtime/checker5s, codegen30s, clang120s. No timing or execution on reservedCPU11 occurred.

`codegen.json` binds both complete generated C files and exact getter excerpts. Baseline Position getter `spin_14`3074–3167 materializes Raw/View boxes, calls generic Cache getter, then unpacks them. The subject `spin_13`2983–3033 returns the same fields and duplicate Data view directly in registers, with no heap_alloc/ctr_take/nestedspin call. The identified representation roundtrip disappears in emitted C; this is not a dynamic allocation count, dominance or speedup claim. Other ABI/materialization sites remain.

Reproduction:

```sh
python3 experiments/s-prep/sevenhour-native-getters/run.py
python3 experiments/s-prep/sevenhour-native-getters/materialize.py --baseline /tmp/bendvy-sevenhour-raw-intrinsic01 --output /tmp/EXPLICIT-NEW-NATIVE-GETTER-ROOT
python3 /workspace/formal-proofs/bendvy-worktrees/twohour-indexed-query/experiments/s-prep/fivehour-connected-gates/tx-controls-run.py --overlay /tmp/bendvy-sevenhour-native-getters01 --output /tmp/bendvy-sevenhour-native-getters-tx01 --cpu 8 --split-schemas
```

Actual tested copy01 and rematerialization03 have identical complete source manifests. Derived source binding is refreshed; inherited other recipe metadata is historical. No production, evaluator, loop or baseline source was edited. The first small run's generator files were reduced to pinned hashes and specific retained excerpts; changing retention did not change subject code. `measurement-check.json` retains the actual commands. Full workload integration/measurement and adoption remain the root's separate gates. No laws/proofs/dependencies are added.
