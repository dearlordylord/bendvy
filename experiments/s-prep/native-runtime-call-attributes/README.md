# Native runtime call-attribute diagnostic

Negative optimization result; no adoption or performance acceptance. One adjacent uninstrumented Motion comparison preserves all 65 complete states against fresh bevy-ts: TS 590.856 ms, original Native 732 ms, derived Native 1095 ms. Derived execution is about 1.50× slower in this diagnostic. This single comparison is not a stable estimate or canonical cohort.

Only two unique generated-C definition headers change from `OUTLINE` to `INLINE`: `rfc_wrap` and `heap_alloc_miss`. Every body, operation, algorithm, other annotation and macro remains byte-identical; reversing those two replacements restores the exact original C. `heap_alloc`, `heap_free` and `term_keep` were already INLINE. The recipe pins the full input C SHA256 and rejects unpinned source before compilation. No Bend, compiler, kernel, reference, dependency or shared runner was edited.

The host OUTLINE macro combines noinline/cold with conditionally enabled preserve_most. Actual clang 14.0.6 supports preserve_most but not preserve_none; the emitted macro requires both, so preserve_most is disabled here. Both selected baseline symbols disappear from the derived binary's defined symbols; this is compatible with inlining, not a runtime call-count proof. Calling-convention support was an investigation clue, not an established root cause or solution.

```sh
python3 run.py --baseline-c /tmp/bendvy-live-first-native-static/batch.c --baseline-native /tmp/bendvy-live-first-native-static/batch-native --overlay /tmp/bendvy-live-first-native --comparison-runner /workspace/formal-proofs/bendvy/experiments/s-prep/cache-box-comparison/run.py --output /tmp/bendvy-runtime-attributes-fresh --cpu 10
```

`evidence/recipe.json` binds original/derived C and binary hashes, the unchanged exact29 Bend runtime pins and the exact comparison runner. Original and derived generated C plus raw comparison outputs are compressed alongside fresh-TS/full-field receipts. CPU 10; clang O3 build 120-second cap (observed 29.17 seconds), each TS/Native runtime 5-second cap. All full fields agree. Unsupported C input is rejected by a finite negative control; no terminal build/runtime failure occurred on the pinned input.

Follow-up: do not adopt this joint attribute change. Separate helper/cold-only hypotheses would require a new bounded diagnostic; no additional cohort, keep or allowance reset was made here. The original performance goal remains unmet.
