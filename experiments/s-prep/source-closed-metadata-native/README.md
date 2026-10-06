# Closed-metadata Native operation diagnostic

Removing the wildcard seed alone yields a small finite operation reduction. Four
fresh diagnostic executions pass65 complete worlds each against pinned TS: Motion
and Health, frozen-provider baseline and closed-reader candidate. Original emitted
C is unchanged before/after. This experiment does not compose flat journals,
fold/noAux, or ledger transport into the closed-metadata source.

Baseline29 closure `409d8704…`; candidate29 closure `118c5502…`.
`pins.json` reconciles each exact C, driver, upstream build, current29 map and count
receipt. Source-worker zero-wildcard receipts are archived as separate provenance,
not claimed as executions of this diagnostic. All original-source C/build and
counter C/raw receipts are hashed in `evidence/index.json`.

| Operation | Baseline | Closed metadata | Delta |
|---|---:|---:|---:|
| Allocator requests, either schema | 32,216,007 | 32,199,623 | −16,384 |
| Created RFC redirect cells, either schema | 14,774,590 | 14,758,206 | −16,384 |
| Requested words, Motion | 81,087,503 | 81,071,119 | −16,384 |
| Requested words, Health | 85,281,807 | 85,265,423 | −16,384 |

The request reduction is about0.051%. Dominant constructor allocations stay:
Cons4,214,848; Handle3,149,824; Cache2,121,728; Main/MainView2,097,152 each;
World1,056,768; WorldRoot1,048,576; MainInverse1,048,576. These are executed
allocation sites classified by their unique static allocated-local use, not
sampled stack/time attribution. The absence of wildcard branches does not remove
these per-row constructors or the dominant RFC work.

`malloc`, `mmap`, `mprotect`, heap-miss, bank-pop and corpus-growth counters are
zero in the observed phase on all four runs. Requests/words are therefore not
physical allocations or peak memory. This is a source mechanism result, not
Native speed, JS comparability, >=2x acceptance or a universal affine theorem.
No sparse profile is needed to infer that these counted operations remain; no
elapsed improvement is inferred from them. Composition is explicitly deferred.

`count.py` uses the approved private Clang19 on diagnostic C copies (compile120,
runtime5, CPU8, oneworker/GPUoff), counts only clocks3–4 and keeps all runtime
helpers/fields/evaluation. `analyze.py` labels direct source sites; `compare.py`
requires both exact closures and common toolchain/reference/recipe/updates;
`verify-pins.py` independently checks all four source/build/count bindings.
No compiler, kernel, reference, dependency, law or proof changes are made.
