# Reached boxed read-wrapper fusion

This bounded emitted-JavaScript probe starts from exact store-elided Motion `177539ce9da582ed602d1a5638385ac63ae9012a3e044d34b8ef15c7a619c267`. It targets actual `prototype_boxed_motion/health_get/ledger → known client body_read/body_ledger` edges. The original getters and receivers remain byte-identical for other calls. No source/compiler/kernel/reference/dependency/law/proof change, source adoption, universal alias/FFI proof, authority-check optimization, canonical cohort or performance acceptance.

Read-only final Motion SHA256 `3c85f51917504e32769def72b4a8dfac63537e1f0708365c300b01801fc40d5e`; Health `5a98de552ee7cfb9c09f3825e2a1730ab5eb035093aedeb5ca9ab3b66d851af8`. Paths are `/tmp/bendvy-js-read-wrapper-fusion-controls-audited/baseline{,-health}.js`.

Optional **unchanged audited swap recipe applied last** gives Motion `943c15d834fbf8a9f9322904515049d304dcd25977a6b400773ea12dd2142ae8`, Health `2925168f36e0bdbdd3bc2d40897b4ede22967fdeeda0dcf23e2290d64f21c5c5`, at `/tmp/bendvy-js-read-wrapper-swap-controls/baseline{,-health}.js`. Root owns subsequent full65 timing/profiling; no speedup is claimed here.

## Preconditions and transformation

[input-pins.json](input-pins.json) admits ten exact programs: Motion/Health full64 plus eight cached/raw/suppressed fixtures. It pins each actual29 source closure, affine Held/Cache kinds, unchanged cached Data views and the actual callback source/module. Full baseline uses prototype-static-client; fixtures use explicitly pinned gate-callbacks. The initial baseline-only module guard refused fixtures before output; explicit fixture source/module coverage was added without accepting unknown callbacks.

[rewrite.cjs](rewrite.cjs) requires fields_checked → boxed taken → invoke → unique static client and exactly one initial/nested getter/receiver edge. Each getter has a pure projection-only const prefix and an exact fresh `Tuple(owner,Found/Some(cached))` return. Every original getter projection remains in the private bridge, in original order, including unused raw/owner-field reads.

Private getter bridges receive original receiver-prefix arguments followed by original getter arguments, preserving JavaScript left-to-right evaluation. Private receiver clones replace only fresh-wrapper fst/snd/tag/value projections with their exact scalar owner/tag/cached equivalents at the same statement positions. Both original branch bodies remain; the known literal tag makes the success branch identical to the original getter-produced wrapper. Missing/authority fallback functions are untouched. No immutable Data is assigned or reused as mutable state; cached view identity is preserved. Four wrappers per reached callback disappear: two Tuples, one Found, one Some. No closures are added.

Guards reject reserved names, accessors/proxies/reflection/eval, target shadow/reassignment/custom callees, captures, wrapper identity/escape, Data writes, wrong branch/tag/field shapes and mismatched nominal pooled tokens/argument order. Receiver calls must be the exact source-bound client helpers or boxed setter/ledger functions. This is a pinned closed-program argument, not all-JavaScript effect/refinement analysis.

Health first passes an exact unchanged copy of store-elision from `25198fe` on independently verified composed `17d102…`, producing `192b4b6c2ca914d7f6aa6cfdf357c584a1924a3b44de651c77b79f78eb35d0f4`. [materialize.py](materialize.py) verifies both original build/static-entry receipts, all29 hashes and matching embedded/standalone cache maps/digest before reproducing the ten intermediates. [pipeline-pins.json](pipeline-pins.json) pins recipes/catalogs/source provenance and outputs. Both full64 entries remain frozen; nine-world validation adapts only diagnostic copies.

`swap-last/rewrite.cjs` is byte-identical to audited `a96b55a`, SHA256 `b79b69dd04722ae45124c55f50d89a2cd5cc945ba57d38864f72d146108a862a`. Its original runtime/constant-arrow/scope/receiver guards run on explicitly pinned fresh read outputs; no waiver or recipe edit.

## Fresh evidence

- CPU8, five-second runtime limit: read-only and read+swap each pass quiet/counted nine complete Motion256 worlds versus fresh pinned TS; both pass nine complete Health256 worlds. Warmup +eight measured worlds,64ticks.
- Store-elided7,333,952 →read-only**6,809,664**: Tuple−262,144, Found−131,072, Some−131,072, all other normalized kinds including closures equal. Read+swap**6,285,376** additionally removes262,144 Tuples and262,144 arrows; all other kinds equal. Counts are expression executions, not guaranteed heap allocations/bytes or speed.
- Each scope passes eight fresh original/store/read-or-read+swap controller comparisons:72 full records per cached/raw/suppressed Motion/Health fixture,576 total.
- Each scope passes eight original/transformed owner/Data snapshot helper witnesses plus selected-Tx; four additional actual fused-client Motion/Health original/candidate units retain frozen prior Data history, full fields and true-old inverses, and verify main argument order owner→token and ledger prefix→owner→token. Diagnostic unit harness calls are not admitted shipping FFI/source.
- Ten synthetic read controls reject before output: getter, proxy, wrapper identity, unknown FFI, custom callee shadow, wrong owner identity, wrong argument order, cached Data write, named custom call and reserved binding. Test-only copied catalogs reach structural checks beyond initial hash refusal; shipping has no bypass.
- Final guarded reproduction is byte-identical on all ten read/swap outputs. Original getters/receivers retain exact definition hashes in each receipt. Source access checks are unchanged from the preceding exact29 source probe; they are not relabelled generated-JS rejection proofs.

Initial guard-harness argument mutation used JavaScript replacement-string dollar expansion, unintentionally renaming a callee. The unchanged recipe refused it; the harness was corrected to a literal callback and all ten intended controls were rerun. Setup refusals are retained separately from semantic results.

[Counts](evidence/counts.json), [archive index](evidence/archive-index.json), immutable recipe/source pins and primary observations retain the evidence. Broader affine layouts, aliases/interleavings, general source/compiler lowering, Native, full22 and performance acceptance remain open.

```sh
python3 materialize.py --output /tmp/fresh-read-swap
python3 run-controls.py --output /tmp/fresh-read-controls
python3 run-controls.py --last-swap --output /tmp/fresh-read-swap-controls
node --expose-internals guard-controls.cjs /tmp/bendvy-js-owner-store-elision-controls/baseline.js /tmp/fresh-read-guards
python3 run-client-witnesses.py --candidates /tmp/fresh-read-controls --output /tmp/fresh-client-units
```
