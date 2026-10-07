# Indexed lifecycle metadata — investigation

Draft implementation guidance, not a selected layout, speedup claim, law approval or package adoption. Read-only research for #30; no executable changes or measurements were made.

## Recommendation

Investigate two **owned** scalar arrays for added/changed ticks before packed flags. The current list has a concrete scaling problem: `get` passes the recursive lookup as an argument to `choose`, so the source does not short-circuit on the first matching entry; `clear` traverses/reconstructs the list and `set` calls `clear`. Repeated metadata operations over N populated entities can therefore perform quadratic list work. This is source analysis, not measured attribution ([lifecycle.bend](../../src/ecs/lifecycle.bend:15)).

Keep arbitrary affine `Type` payloads in their existing typed owner columns. Metadata can contain `U32` without imposing `Data` on component payloads. Use the newer [additive opt-in design](../design/indexed-lifecycle-metadata.md): preserve legacy fields/routes, and carry indexed owners throughout the selected ordinary/prepared/captured route without mirrored authoritative metadata.

## Exact semantics to preserve

- Missing metadata returns `Stamp{0,0}`. Clear removes all entries for the ID; set replaces all duplicates with one newest entry. A first component insertion assigns both ticks; replacement preserves added and changes changed. Removal writes zero ticks; structural cleanup clears metadata. Filtering remains strict `tick > cursor` ([lifecycle.bend](../../src/ecs/lifecycle.bend:15), [column.bend](../../src/ecs/column.bend:296)).
- `wasPresent` is determined by actual previous component ownership, not by nonzero added/changed ticks. Projection and raw owner swaps remain metadata-neutral. Metadata exists independently of payloads during prepared evacuation, so do not infer presence from an evacuated array hole ([column.bend](../../src/ecs/column.bend:294), [component.bend](../../src/ecs/component.bend:229)).
- Every undo captures the old payload and stamp. Rollback restores the payload first, then the exact saved stamp, in existing inverse order; repeated writes must restore the original state. World clock advancement is retained through rollback. Exhausted `4294967295` rejects a write without incrementing; invalid handles reject before advancing ([component.bend](../../src/ecs/component.bend:229), [component.bend](../../src/ecs/component.bend:265)).
- Foreign, dead and deferred handles retain per-operation validation. A foreign colliding ID returns zero lifecycle ticks through the checked public lookup ([component.bend](../../src/ecs/component.bend:191)).

**A separate metadata presence bit is unnecessary for these observable operations:** absence and an explicit zero stamp already have identical lookup results; component presence comes from owners. Two zero-filled arrays preserve that quotient. However, this does **not** preserve raw `List<Entry>` constructor representation, duplicate entries or enumeration order. Existing exported constructors and raw fixtures need an explicit migration/adapter decision; never claim representation identity. If a future API exposes metadata-entry membership independently from ticks, add a presence representation then.

## Candidate design and hazards

Use an affine `Metadata` owner containing `added:Array<U32>` and `changed:Array<U32>`, with common power-of-two capacity/depth. Read returns `(Metadata, Stamp)`; write/clear return Metadata. Avoid reusable `+Metadata`: sharing owned arrays can introduce reference-count/copy costs. Use independent scalar array reads and reassemble the small Stamp only at the required public boundary.

For checked entity IDs, index at `id-1` after explicit bounds validation. **Base Array indexing wraps modulo capacity**, rather than rejecting out-of-range indexes: `Array.get.at`/`swap.at` mask by `n-1` ([pinned Base](../../.references/bend2/bend2/base.bend:2279), [get](../../.references/bend2/bend2/base.bend:2395)). ID zero, capacity+1 and high IDs must never alias a real entity. Grow both arrays together with zero padding; growth must retain every prior tick. The payload column currently has an explicit 131072-slot bound ([column.bend](../../src/ecs/column.bend:148)). Raw `restore_stamp` presently accepts arbitrary IDs through list set, without this bound: a bounded array implementation must either retain a defined raw fallback or explicitly review/migrate that raw contract. Silently ignoring a raw restore is not equivalent.

Carry Metadata through `Column`, prepared `State`, prepare/recover/ensure/swap/view, lifecycle/mark/restore/clear and all captured restoration closures. Capture must return the **actual returned** Metadata after its read; captured row restoration must update only the intended stamp, preserving other entities. Preserve dirty=false metadata neutrality and dirty=true exact restore. Relevant direct-list consumers are [column.bend](../../src/ecs/column.bend:15) and [captured-column.bend](../../src/ecs/captured-column.bend:18); restored-row owns only an individual Stamp ([restored-row.bend](../../src/ecs/restored-row.bend:8)).

The pinned compiler has specialized scalar-array operations: native `arr_op` computes a block index, keeps values for get and writes for set/swap ([comp.ts](../../.references/bend2/bend2/comp.ts:1737)). This supports the rationale but does not establish generated-JS cost or gains. Capacity growth and wrapper/tuple transport can offset lookup savings; inspect emitted code and profile both backends before selecting.

## Primary inspiration and compatibility

The supplied [NodeStore definition](https://jend.leeeet.dev/src/bend-collections-laws-containers@1.0.0.0/src/containers/balanced_search_tree.bend?def=NodeStore) was fetched as actual text with curl after web.open failed. Its comment explains separate per-field arrays to avoid copying/reference-counting shared node records. `NS` contains independent tags/left/right/parent/key arrays and doubles capacity. The [full source](https://jend.leeeet.dev/src/bend-collections-laws-containers@1.0.0.0/src/containers/balanced_search_tree.bend) identifies generator `tools/generators/tree_map.py` and named-package imports; it constrains its keys/payloads to Data. Borrow the scalar metadata layout, **not** that component restriction or the dependency. No authenticated package integrity manifest, repository commit, compiler lock or executed compatibility evidence was established from these responses; named version alone is insufficient provenance.

Pinned Rust Bevy separately stores added/changed tick arrays beside payload data ([table Column](../../.references/bevy/crates/bevy_ecs/src/storage/table/column.rs:25)). This is idiomatic ECS structure-of-arrays precedent. Its physical table-row indexing and tick aging are not Bendvy's entity-ID and exhaustion contracts; do not transplant them.

## Required evidence before selection

1. Full old/new public observations on JS/Native: absent/zero stamps, first write, replacement, removal/reinsertion, despawn, independent added/changed reader cursors, skip/failure, repeated writes/rollback and earlier commits. Include actual affine Array payloads, projection-returned owner mutation and exact full payload/tick recovery.
2. Boundary controls: zero, capacity edges, growth, 131072/131073, foreign same-ID, dead/deferred, maximum clock and maximum-minus-one repeated writes. A reached wrong-index or omitted-stamp-restoration mutant must fail. Preserve intended undeclared-access/cross-schema/write-through-read negatives.
3. Ordinary/prepared/captured/refusal/fallback paths, forward/backward traversal, dirty/clean restoration and complete retained owners. Keep normative query order and frozen Workshop work unchanged.
4. Matched before/after CPU and allocation call-stack profiles, including collected-object sampling and GC accounting, on identical frozen work. Separate profiling from timing. Record emitted source/current closure hashes.
5. Root-run unchanged default and prepared-provider paired regression gates. Scaling diagnostics should additionally freeze equal dense, sparse/high-water and churn/rollback work at multiple sizes (e.g. 64/256/1024, plus a practical larger case), compare complete observations before timing, and record tick-array capacity memory. These are diagnostic sizes, not newly approved acceptance thresholds. No new package installation, laws or proofs follow from this recommendation.

## Source identity / procedure

Read AGENTS, next checkpoint, GitHub #30 and SPEC; read Bend/research/bend-ldd skills; ran `bend version` (2.0.35) and `bend guide`. No checker/build/runtime benchmark was run. Reference HEADs match tracked report: TS `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`, Bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60`, Bend `a950fd683c0d76f09794078e6174fe98a1492876`.

SHA-256 at inspection:

| Source | SHA-256 |
| --- | --- |
| lifecycle.bend | `6585d64ff88a3985a663d42c5b9a82ff3d5067e6ad451f506fad146c4fbd09b0` |
| column.bend | `869091a81636ece3b6d8fd37bae552bcb58b76c7d3ea396e8ecdb9e6f4eeb032` |
| component.bend | `0e41557cc6b8101490eaa7f4bf5fbdf896a2646e9b2359d7daf41db6de45988c` |
| captured-column.bend | `e7257f7da54e5a2f9dfb01e892932e56810e67dcdc016aa373e75d72de2c2511` |
| restored-row.bend | `9a1e25359a7775e230ad1b720180db622c12c2e9757cba98acef9c89e8d0f2d5` |
| pinned Base | `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661` |
| pinned comp.ts | `32fb66e09f608ce9e4b173384bcfeec453db8c5bc96650e26ad861bef815a8d9` |
| pinned Rust table Column | `83fe41abd9566b3326ae5e0c3c3bf1c4c17f17d7a5a76a3e98d454b59f5d77a9` |
| HTTP NodeStore-only response (866 bytes) | `ab8bbe1b62f63d1fba410db5164acd959e271b4f62ccfafd7e01f57b5086f199` |
| HTTP full tree source (105201 bytes) | `176d7925f7f696b0ed0618c490a6801548d77f8666e82832355c1473bb2be4b3` |

HTTP source was inspected directly; responses are temporarily at `/tmp/indexed-lifecycle-primary.html` and `/tmp/indexed-lifecycle-full.bend`, not adopted dependencies or durable vendoring.

## Actual partial scaling evidence — both cohorts ERROR

Read-only analysis of root-run `.artifacts/indexed-scaling-dense-v2/receipt.json` and `.artifacts/indexed-scaling-mixed/receipt.json`: both terminate ERROR at legacy 1024 JS with `bend: memory fault (machine stack overflow?)`. Sizes 64/256 each passed the full independent operation oracle on JS/Native, then five alternating samples/backend and matched separate CPU/collected-object allocation profiles. **1024 remains unmeasured as a matched comparison**, and neither overall cohort passes. No TS/product/full-ECS qualification follows.

| Scenario / size | JS process median ms, old→indexed | Native process median ms, old→indexed | Sampled allocated MB, old→indexed |
| --- | --- | --- | --- |
| Dense 64 |21.6267→18.9578 |2.5438→2.2563 |2.520304→0.681080 |
| Dense 256 |36.9190→24.2081 |5.5989→3.8520 |31.511840→2.618544 |
| Mixed 64 |23.1632→21.7127 |4.1148→4.0694 |2.565304→7.139096 |
| Mixed 256 |37.0263→25.9502 |4.8042→3.1234 |31.413160→8.521656 |

Times include process startup, complete JSON rendering and stdout; ratios are descriptive, with no significance claim. Allocation MB is the decimal sum of V8 heap samples, including collected objects, **not exact physical cumulative allocation or retained/RSS memory**. Each profile validates one complete application; profiler/wrapper contributions remain visible. Dense 256 legacy `Lifecycle.clear` has 28.818832MB sampled self attribution and Lifecycle.get has 7.034ms CPU self attribution. Mixed 256 legacy clear has 28.227712MB sampled self attribution and 9.725ms CPU self attribution. The source-backed quadratic-list mechanism is reached, but this microdiagnostic cannot establish integrated ECS benefit.

Sparse memory cost is concrete: mixed 64 indexed sampled allocation exceeds legacy, largely `array_node` 4.153600MB and `array_new` 2.105840MB. Mixed 256 has corresponding 4.223344+2.105616MB. Separate capacity observations seed N entries then write ID 131072: legacy has N+1 list entries, indexed has 131072 slots in **each** scalar array. Capacity is not physical bytes. Do not average away the adverse mixed-small memory case.

These ERROR receipts record pre-copy/before-build source binding; they do not have successful final acceptance. Both snapshots use indexed-lifecycle SHA `e997f3b089149a54afb6485fcb2167d1fd0e86979bfa16329473d3a235e8b8d5`, old workload `9ed6098a1f0b710722819117c05591380f0d46fb8e6c11358686203636c9864c`, harness `6bba4d7f1bef4b94acf261d79f72b96b6b6ba6cbce26e020d7d67242b9089b29`; individual profile receipts bind emitted JS and complete expected output. These findings are historical once source changes.

### Small common-renderer repair

The old renderer reverses its accumulated observation list and calls Base List.show.go, whose emitted JS is non-tail recursion over 8192 dense observations ([Base](../../.references/bend2/bend2/base.bend:2226)). Root separately raised JS stack size diagnostically and validated the full 1024 oracle; that does not authorize a runtime setting change or measured acceptance.

The source-only repair consumes the already reverse-chronological observations tail-recursively, prepending bounded row fragments to a suffix initialized as `"]"`. First/latest row has no separator; earlier rows prepend `", "` before the suffix; finish prepends `"["`. Stored `[C,B,A]` therefore renders exactly `[A, B, C]`. It removes List.reverse/List.show recursion without changing operation order, complete fields, spacing or per-row IO. Native append traverses only bounded left row/separator fragments rather than an ever-growing prefix ([String.append](../../.references/bend2/bend2/base.bend:1806)); the JS backend lowers append to `+` ([compiler](../../.references/bend2/bend2/comp.ts:287)). A generated tail-loop is expected, **not yet observed** for the repair. Both representations receive the same change; fresh full-output and measurement cohorts are required. Root owns serial checks/profiles/gates; this analysis ran no executable workload or new measurement.

## Complete repaired-renderer evidence

The preceding ERROR/partial section is historical. Fresh [dense-complete receipt](../../experiments/public-optimized-compose/indexed-metadata-scaling/evidence/dense-complete/receipt.json) and [mixed-complete receipt](../../experiments/public-optimized-compose/indexed-metadata-scaling/evidence/mixed-complete/receipt.json) both **PASS at 64/256/1024**. Full independent oracle observations match both representations/backends, every timing sample is revalidated, both profile runs validate complete output, and final root/staged/generated source guards pass. Dense has 512/2048/8192 observations; mixed has 530/2066/8210. Optional 4096 remains unrun. Inspection of emitted dense legacy 1024 JS confirms `render_reverse` is now a `for (;;)` loop with `continue`; the earlier expectation is now observed.

| Scenario / size | JS process median ms, old→indexed | Native process median ms, old→indexed | JS / Native indexed-to-old ratios |
| --- | --- | --- | --- |
| Dense64 |21.152419→19.527785 |2.998185→2.703849 |0.923194 /0.901829 |
| Dense256 |40.806455→28.789841 |4.822571→2.672724 |0.705522 /0.554211 |
| Dense1024 |213.138495→42.594507 |36.682180→4.398610 |0.199844 /0.119911 |
| Mixed64 |23.366141→21.606922 |2.165305→2.381556 |0.924711 /**1.099871** |
| Mixed256 |40.336744→29.186051 |4.611237→3.015769 |0.723560 /0.654004 |
| Mixed1024 |223.727684→49.330215 |37.982146→4.748862 |0.220492 /0.125029 |

Five alternating fresh-process samples/backend/representation/size; medians include startup, rendering and stdout. **Mixed 64 Native is adverse (~10% greater median)** and is not averaged away. Descriptive ratios are not statistical/regression/product acceptance, and no TS workload is measured here.

For the complete cohorts, prefer summed **per-name node `selfSize`** attribution when discussing call-site allocation. Dense64/256/1024old→indexed decimal MB:2.332136→0.607616 /30.903896→2.537608 /458.974944→8.798280. Mixed:2.603304→7.260848 /31.609464→8.967304 /462.889112→15.323568. Raw `heap.samples[].size` sums differ slightly: dense2.350304→0.647600 /30.932760→2.562440 /459.206192→8.829192; mixed2.603616→7.305528 /31.694976→9.022064 /463.158288→15.378968. The partial section above used **raw sample-size sums**, not node-self totals; these are explicitly separate aggregations, neither an exact physical allocation count. Inclusive attribution overlaps and must not be summed as independent bytes.

Dense 1024 legacy Lifecycle.clear dominates node-self allocation with 450.725344 MB; indexed get_checked has 1.690352 MB. Mixed 1024 legacy clear has 453.963648 MB; indexed array_node/new have4.186384+2.072816MB. Mixed 64 indexed grows 6.349776 MB of array-node/new self attribution and total sampled allocation rises versus legacy, exposing the high-water memory tradeoff. This supports the reached list-reconstruction mechanism while preserving adverse sparse-small evidence.

Heap-run observed GC counts/durations, dense64/256/1024old→indexed:3/0.685921ms→1/0.334668ms;20/3.076063→3/1.068172;75/20.863629→6/2.761143. Mixed:3/0.645920→4/1.196591;20/2.960600→5/1.287883;74/21.372505→6/4.295818. CPU-run events separately give dense1024:74/19.193823→6/4.092649 and mixed 1024: 75/22.293976→9/7.426337. Delivered perf_hooks events with a drain are not guaranteed complete GC accounting; they are different from CPU sample attribution and timing-sample cost. Every profile covers one fresh complete application; instrumented startup/wrapper/renderer contributions remain present.

The selected cohort workload hash is `adb025057d7a832585c748cc69dd8c0619d8cadf3f9648f981b7e2c38ea3ee86`, metadata `e997f3b089149a54afb6485fcb2167d1fd0e86979bfa16329473d3a235e8b8d5`, iterative summarizer `622afd3dd01452195faf10b99627dd0c2ab2b10030dfdbf053147308b2ed3dd6`. Receipt SHA256s are dense `a78585d45887197247227e0566be1f6a370db696c5f8e5fde5900a6770b37d17`, mixed `2adacf2646503d086cbdbca4c7db95acca9d9ea8b30d2f93a7a1f76e27c35e78`. [Scaling README](../../experiments/public-optimized-compose/indexed-metadata-scaling/README.md) records full tables and retained artifacts. This read-only update executed no new workloads, builds, timing or profiling. Integrated #30 owner/rollback/authority/default/prepared gates and parent product qualification are still required.
