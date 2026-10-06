# Motion JS CPU/GC diagnosis

Delivered bounded profiling; full core/performance acceptance remains incomplete. Governing issues #21/#24. Original generated JS matches the current 29-module candidate provenance. Core, compiler/kernel, laws and read-only references are unchanged.

## Findings

V8 CPU/GC profiles cover eight distinct worlds ×64 ticks ×256 entities, with the same warmup and full nine-world observations as TS. Reducing batch64 to8 is a profiling-only adjustment to fit the unchanged five-second process limit. It is not a replacement benchmark. Execution-phase marks exclude world creation and final serialization; profiler timings are not uninstrumented speed ratios. CPU sample intervals are clipped to the marked bracket.

| Observation (corrected baseline v2) | Bend JS | bevy-ts |
| --- | ---: | ---: |
| GC CPU self share in execution bracket |12.85%|11.48%|
| Approximate allocation bytes reported by GC intervals |453.7 MB|81.4 MB|
| GC events falling inside bracket |40|13|
| Approximate summed GC pause |69.4 ms|24.8 ms|

Allocation intervals can straddle bracket boundaries; GC event timestamps have millisecond resolution. These are approximate diagnostic values. More allocations are supported by this run, but GC alone does not explain the slowdown: most sampled time remains in the mutator. Initial baseline captured lazy stderr setup inside the start mark; v2 warms stderr first. Both are retained. Shared-machine/profiler noise precludes performance acceptance.

Largest v2 JS self-time sites include static motion callback7.4%, mark_main7.0%, take_rows4.8%, indexed selected query4.7%, take_main_done4.5%, static ledger callback4.1% and metadata membership3.8%. This spreads work across component/transaction owner transport. Generated array_new is a flat JS array; array_rmw directly indexes and updates it. No whole-array copy appears in that primitive. Generated getters rebuild Held and Cache even though their fields are unchanged; point take/return, mark and query also rebuild multiple records/tuples. This source observation motivates targeting wrapper allocation rather than another storage layout rewrite.

## Single controlled probe

read-wrapper-probe.py changes only two private emitted getter bodies (motion_get and motion_ledger). Each returns the unchanged owner identity instead of reconstructing Held+Cache; the tuple/view result and callback signatures remain. Exactly two object literals/call disappear. No raw-owner authority is added. This is a generated-code hypothesis probe, not a Bend implementation, general optimizer, proof or production path.

The probe passed every normalized field of all nine Motion worlds against fresh pinned TS. Approximate allocation fell from453.7 to430.0 MB (about5.2%). Profile bracket time was651.6 ms before vs616.1 ms after, but the accompanying TS bracket changed335.8 to234.1 ms; no speedup is established. Probe GC CPU share increased to18.21%. No keep/adoption follows. Only this dense Motion scenario was tested; rollback/foreign-world/negative-authority/general Type gates and full22 are not established for emitted rewrite reuse.

## Reproduce

No dependency installation is required (Node24.20.0, Bend2.0.35). Archived CPU profiles can be opened in Chrome DevTools Performance after decompression; URLs map to the archived derived sources. All commands/flags, source pins and raw outputs are archived in [evidence-index.json](evidence-index.json).

```sh
# Extract the pinned baseline generated artifact:
gzip -dc evidence/original-batch.js.gz > /tmp/original-batch.js
python3 run.py --generated-js /tmp/original-batch.js --output /tmp/fresh-profile
python3 summarize.py /tmp/fresh-profile
python3 read-wrapper-probe.py --input /tmp/original-batch.js --output /tmp/read-probe.js
python3 run.py --generated-js /tmp/read-probe.js --output /tmp/fresh-read-profile
python3 summarize.py /tmp/fresh-read-profile
```

## Next seam

### Collected-object heap sampling continuation

`heap-sampling-probe.py` attaches installed Node Inspector sampling at the existing
execution markers (32KiB interval, collected minor/major objects included). A
canary observes allocations after explicit GC with that option enabled versus
disabled; this is infrastructure evidence, not an ECS law. The sampled candidate
passes all nine full worlds against fresh TS. [Pinned archive](heap-evidence/index.json).

Sampled attributed self size is406.4MB over12,324 samples: callback frames124.6MB,
held-adapter117.5MB, query94.0MB, storage34.9MB. Inlined allocation may be attributed
to its caller; these estimates are neither exact bytes nor retained heap. Neighbor
same-CPU GC diagnostics report direct-raw405.2MB / batched380.2MB despite two fewer
executed closure expressions/update. No raw-swap heap or speed win is established.

```sh
node --expose-gc experiments/s-prep/js-profile/heap-sampling-canary.cjs
python3 heap-sampling-probe.py --input /tmp/batch.js \
  --output /tmp/heap-probe.js --profile /tmp/candidate.heapprofile
python3 run.py --generated-js /tmp/heap-probe.js \
  --output /tmp/fresh-heap-profile --cpu 11 --no-gc
python3 heap-sampling-summary.py /tmp/candidate.heapprofile \
  --output /tmp/heap-summary.json
```

The injection has no remote Inspector endpoint and changes no Bend/compiler source.
Core profiles, full22 failures and all unfavorable raw times remain documented in
[continuation report](../../../docs/reports/profile-directed-optimization.md).

Target owner-transport allocations around point take/return, mark and indexed query, while preserving actual callbacks, journals, stamps and abstract authority. The narrow getter probe removes only a small part of observed allocation. A source-level continuation/fusion candidate needs fresh complete field/rollback/access/cursor/mutation controls; a general emitted-record reuse pass would require separately authorized compiler work and affine alias/safety validation. Do not hand-edit generated JS as a shipped Bend implementation. Complete full22 and resolve codegen/runtime blockers before qualified Native/JS performance claims. No measured-loop cap was reset.
