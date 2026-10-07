# Indexed metadata scaling diagnostic

**Fresh complete dense/mixed diagnostic cohorts PASS at all three sizes**, with the reviewed common renderer and iterative profile summarizer. Initial ERROR cohorts and their partial results remain preserved below. This is metadata-only evidence, not ECS regression acceptance or JS/Native versus TS qualification.

`workload.bend` uses one generic owned-metadata algorithm for legacy `List<Entry>` and actual `src/ecs/indexed-lifecycle.bend.Metadata`. API was coordinated with the storage implementer: `empty`, `get -> Metadata & Stamp`, `set`, `clear`. `providers.bend` only adapts the legacy list and separately exposes trusted indexed capacity. Components/World/query authority are outside this microdiagnostic.

Frozen diagnostic sizes are 64/256/1024. `--include-4096` adds a reported limit probe; timeouts/errors remain failures, never substituted by a smaller workload. Runtime/checker caps are 5 seconds, emission 30, private Clang 19 compilation 120. No new dependency, compiler change, law/proof, benchmark baseline or numerical acceptance criterion is involved.

Dense work seeds every entity, reads all stamps, saves each original stamp, performs two distinct replacements and reads each, clears and observes zero, restores the saved stamp and reads it, then performs two complete final sweeps. Restoration is a metadata operation, **not** an ECS transaction rollback proof. Mixed work adds missing/read/write/clear/read traces for zero, size+1,65536,131072,131073,U32.max before the final sweep. Added=0/changed=77 tests zero-added semantics explicitly. Every saved/read/update/final observation is serialized; seed writes are checked by the first complete read sweep.

Run dense and mixed as separate fresh invocations so high-water array growth does not mask dense scaling:

```sh
python3 experiments/public-optimized-compose/indexed-metadata-scaling/run.py --output .artifacts/indexed-scaling-dense --scenario dense --cpu 0
python3 experiments/public-optimized-compose/indexed-metadata-scaling/run.py --output .artifacts/indexed-scaling-mixed --scenario mixed --cpu 0
```

Only after both representations/backends match the complete independent Python oracle does the harness collect alternating before/after process samples. Every timing sample is revalidated in full. Process timings include fresh runtime startup, complete JSON formatting and stdout; they do not qualify steady-state ECS speed or TS/product comparisons. There is no significance test or pass threshold here. Required default/prepared regression gates stay separate and unchanged.

Optional `--profiles` runs the existing Node inspector CPU/allocation harness **after** all timing for each size. Both representations use the identical runner/settings and complete validated output, one fresh program iteration, with 5 second child caps. CPU and collected-object heap sampling run separately. Full profile receipts and summaries are retained under the output directory. A missing/empty profile or legacy timeout is retained as failure, not a speedup. One iteration may be insufficient for attribution; root may prepare a separately frozen batching experiment after inspecting the evidence, without silently changing this workload.

A separate untimed capacity program seeds N normal entries then writes high-water131072. It reports legacy list entries (`N+1`) or indexed slots per tick array (`131072`); these intentionally representation-specific outputs are **not** normative comparison/timing work. Indexed scalar capacity is262144tick slots; native/JS actual bytes, peak RSS and sampled cumulative allocations differ. This exposes sparse memory growth rather than claiming physical memory from a slot count.

Outputs are fresh-directory receipts, compressed complete stdout/stderr for every command/sample, emitted JS/C/native artifacts and exact generated entry sources under staged input. The receipt snapshots root core/support files and workload/adapters/harness **before copying**. Immediately after copying, before each build and at final acceptance, it compares the full staged inventory/hashes with that snapshot plus recorded generated entries, and recomputes the root inventory/hashes to detect additions, removals and edits. Final acceptance also rehashes every generated workload entry against its recorded hash and checks profile runner hashes. Preserve the entire output directory or archive it with its hashes when reporting; do not retain only medians. Generated files and receipts are deliberately absent before execution.

Limits: ordinary scalar metadata only; no arbitrary component owner test, public confinement test, prepared capture/fallback proof, Bevy/TS feature parity claim or product qualification. Those remain governing #30 integration gates. The sparse exceptional path uses actual metadata API behavior but does not assert raw list representation equivalence for normal indexed IDs.

## Renderer repair and retained failures

`.artifacts/indexed-scaling-dense-v2/receipt.json` and `.artifacts/indexed-scaling-mixed/receipt.json` are terminal **ERROR**, each at legacy 1024 JS semantic execution with `bend: memory fault (machine stack overflow?)`. The old renderer reversed the observations then called non-tail `List.show.go`; emitted JS recursively formats 8192 dense observations. Root's separate larger-stack diagnostic validated the full oracle, but is not an accepted setting change or a 1024 timing/profile result. Original failed outputs/receipts remain intact.

The common source renderer now consumes the already reverse-chronological recorded list directly, prepending each bounded row fragment to a suffix initially `"]"`. The first consumed/latest row gets no separator; every earlier row gets `", "` before the suffix; completion prepends `"["`. Thus stored `[C,B,A]` becomes exactly `[A, B, C]`, with unchanged JSON fields, order and spacing. Empty observations remain `[]`. No operation algorithm or expected rows change.

`render_reverse` is a self-tail call. The fresh emitted legacy 1024 JS now contains a `for (;;)` loop and `continue` for this function, and complete observations match on both backends. Every native String.append left operand is a bounded observation fragment, two-character separator or one-character bracket. It never repeatedly copies a growing left prefix. No per-row IO, new Node/profile flags or numerical gate changes are introduced. Both representations use this same renderer. Old renderer timings are historical, not timings for this source.

## Partial old-renderer measurements

All rows below validate complete normative stdout for both backends before timing and revalidate every sample. Values are medians of five alternating fresh-process samples, in milliseconds. Both **overall cohorts are ERROR**; 1024 has no matched accepted measurement. Ratios are descriptive, without a significance claim or product acceptance.

| Scenario / size | JS legacy / indexed | Native legacy / indexed | JS indexed/legacy | Native indexed/legacy |
| --- | --- | --- | --- | --- |
| Dense64 |21.6267 /18.9578 |2.5438 /2.2563 |0.876593 |0.886994 |
| Dense256 |36.9190 /24.2081 |5.5989 /3.8520 |0.655708 |0.687990 |
| Mixed64 |23.1632 /21.7127 |4.1148 /4.0694 |0.937379 |0.988972 |
| Mixed256 |37.0263 /25.9502 |4.8042 /3.1234 |0.700860 |0.650124 |

Collected-object Node **raw `heap.samples[].size` sums** (decimal MB, sampled attribution rather than physical allocation totals) were dense 64: 2.520304→0.681080; dense 256: 31.511840→2.618544; mixed 64: 2.565304→7.139096; mixed 256: 31.413160→8.521656. These are distinct from summed per-name node `selfSize` attribution reported by the summarizer; do not mix the two aggregations. The mixed 64 indexed allocation increase is retained explicitly: high-water scalar-array growth has a real cost. Dense 256 legacy `Lifecycle.clear` alone accounts for 28.818832 MB of sampled self attribution. Mixed 256 indexed `array_node`+`array_new` account for 6.328960 MB, showing sparse growth cost rather than an absent path. Samples contain rendering/wrapper overhead and one application only; module-inclusive values overlap.

Matched CPU/heap profile receipts validate one complete application per run. Dense 256 CPU self samples include legacy Lifecycle.get 7.034 ms; mixed 256 includes legacy Lifecycle.clear 9.725 ms. Profiler `post`/idle contributions are large, so whole-profile totals are not workload durations. Source-bound partial findings and exact receipt identities are recorded in [research note](../../../docs/research/indexed-lifecycle-metadata.md); no parent performance or ECS acceptance follows.

## Complete repaired-renderer cohorts

[Dense receipt](evidence/dense-complete/receipt.json) and [mixed receipt](evidence/mixed-complete/receipt.json) both PASS: full oracle checks, all five samples per representation/backend/size, separate matched CPU/heap profiles, and final root/staged/generated-source guards. Dense observation counts are 512/2048/8192; mixed counts are 530/2066/8210. Each profile validates one complete application. Optional 4096 was not run. Retained emitted JS proves the tail-loop; retained stdout proves unchanged observations.

| Scenario / size | JS process median ms, legacy / indexed | Native process median ms, legacy / indexed | JS indexed/legacy | Native indexed/legacy |
| --- | --- | --- | --- | --- |
| Dense 64 |21.152419 /19.527785 |2.998185 /2.703849 |0.923194 |0.901829 |
| Dense 256 |40.806455 /28.789841 |4.822571 /2.672724 |0.705522 |0.554211 |
| Dense 1024 |213.138495 /42.594507 |36.682180 /4.398610 |0.199844 |0.119911 |
| Mixed 64 |23.366141 /21.606922 |2.165305 /2.381556 |0.924711 |**1.099871** |
| Mixed 256 |40.336744 /29.186051 |4.611237 /3.015769 |0.723560 |0.654004 |
| Mixed 1024 |223.727684 /49.330215 |37.982146 /4.748862 |0.220492 |0.125029 |

The adverse mixed64Native ratio is retained: approximately 10% greater process median. No averaging, significance inference or acceptance allowance follows. Process/JSON startup limits still apply to every row.

| Scenario / size | Per-name node selfSize sum MB, legacy→indexed | Raw sample-size sum MB, legacy→indexed | Heap-run observed GC count / duration ms, legacy→indexed |
| --- | --- | --- | --- |
| Dense 64 |2.332136→0.607616 |2.350304→0.647600 |3 /0.685921→1 /0.334668 |
| Dense 256 |30.903896→2.537608 |30.932760→2.562440 |20 /3.076063→3 /1.068172 |
| Dense 1024 |458.974944→8.798280 |459.206192→8.829192 |75 /20.863629→6 /2.761143 |
| Mixed 64 |2.603304→7.260848 |2.603616→7.305528 |3 /0.645920→4 /1.196591 |
| Mixed 256 |31.609464→8.967304 |31.694976→9.022064 |20 /2.960600→5 /1.287883 |
| Mixed 1024 |462.889112→15.323568 |463.158288→15.378968 |74 /21.372505→6 /4.295818 |

SelfSize totals sum every per-name self attribution once; inclusive stacks overlap. Raw sample-size totals are a separately labeled aggregation. Neither is exact physical bytes, retained heap or RSS. GC counts/durations are delivered perf_hooks events with the runner's drain, not guaranteed complete GC accounting; CPU-profile GC samples are different metrics.

At dense 1024 legacy `Lifecycle.clear` has 450.725344 MB node-self attribution, versus indexed top metadata `get_checked`1.690352MB. Mixed 1024 legacy clear has 453.963648 MB; indexed `array_node`4.186384MB + `array_new` 2.072816 MB exposes sparse growth. Mixed 64 indexed array-node/new self attribution is 6.349776 MB and total sampled self allocation rises; this limitation remains despite larger-world benefit. CPU-run observed GC is dense 1024: 74 events/19.193823ms→6/4.092649ms; mixed 1024: 75/22.293976ms→9/7.426337ms. These are separate instrumented runs, not timing samples.

Bound source identities: workload `adb025057d7a832585c748cc69dd8c0619d8cadf3f9648f981b7e2c38ea3ee86`, indexed metadata `e997f3b089149a54afb6485fcb2167d1fd0e86979bfa16329473d3a235e8b8d5`, iterative summarizer `622afd3dd01452195faf10b99627dd0c2ab2b10030dfdbf053147308b2ed3dd6`; complete receipt maps retain the rest. Receipt SHA256: dense `a78585d45887197247227e0566be1f6a370db696c5f8e5fde5900a6770b37d17`, mixed `2adacf2646503d086cbdbca4c7db95acca9d9ea8b30d2f93a7a1f76e27c35e78`. These results cover this exact metadata microdiagnostic; integrated ECS/default/prepared regression and parent product gates remain separate.
