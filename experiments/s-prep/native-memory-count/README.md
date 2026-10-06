# Native phase memory-operation counts

Diagnostic generated-C copies preserve the original runtime operations and add
single-thread counters between the frozen Motion batch's third/fourth clocks.
Setup, warmup and output serialization are outside this phase. The tool requires
exactly four clocks and every field of all65 worlds equal to a fresh pinned TS
reference. No timing, physical heap bytes, resident memory, qualification or
production acceptance is inferred from these instrumented runs.

```sh
python3 experiments/s-prep/native-memory-count/run.py --source /tmp/bendvy-live-first-native-static/batch.c --reference /tmp/bendvy-view-box-motion-comparison/reference.mjs --output /tmp/fresh-memory-count --cpu 11
```

ClangO3 limit120, each TS/Native runtime5, one worker/GPUoff. Hooks match exact
runtime headers and reject duplicates/missing anchors. Counters measure function
entries; requested words sum allocator size classes, including reused blocks.
Instrumentation can affect optimizer decisions, so these are counts in the
diagnostic copies, not a universal count claim for every uninstrumented binary.

| Same1,048,576 updates | Baseline | Private cache boxes | Recursive Data views |
| --- | ---: | ---: | ---: |
| heap_alloc entries |32,920,519|74,863,559|30,774,215|
| rfc_wrap entries |15,126,846|34,001,214|15,102,270|
| term_keep entries |1,085,440|1,085,440|3,182,592|
| term_drop entries |36,928|36,928|2,134,080|
| span_fade entries |8,192|8,192|2,105,344|
| Requested allocator words |81,792,015|180,358,159|64,793,615|

Every lane passes all65 full states. Frozen receipts, derived C and raw outputs
are indexed in [evidence/index.json](evidence/index.json). Cache boxing sharply
increases allocator/RFC work; view boxing reduces requested words but adds two
keep/drop cycles per update. Combined with the separate profiles/raw comparisons,
this explains why ABI width alone is an insufficient selection criterion; it
does not establish an isolated causal elapsed-time contribution or speed win.
