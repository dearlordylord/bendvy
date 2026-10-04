# Corrected whole-process memory samples

The collector completed 294 fresh children: 284 passed full validation and 10 hit the five-second deadline. Twelve cases have all seven samples on all three backends. Both Readers256 cases are incomplete. No failed sample was replaced. The JSON status is `PARTIAL_MEMORY`, not a performance acceptance gate.

Deadline failures:

- Motion readers 256, JS: repetitions 3.
- Health readers 256, Native: repetitions 5, 6, 7.
- Health readers 256, JS: repetitions 1, 3, 4, 5, 6, 7.

This separate run uses the tested small C launcher to remove the Python observer's inherited RSS floor. Earlier RSS comparisons remain withdrawn; they are not silently replaced. The original timing repetitions and ratios are unchanged. Memory samples have their own UTC timestamps and full-output validation evidence.

Command: `python3 experiments/s-integrate/measurement-samples-memory-run.py`. Sampling uses CPU5, seven fresh repetitions with rotated Native/TS/JS order, the same 64 authored iterations, payload width 4, one fresh warmup plus one fresh measured world per process, and unchanged actual workload closures. Native remains O3/one worker/GPUoff; JS and TS use the same Node binary. Checker 5s, complete runtime process group 5s, codegen 30s and clang 120s remain unchanged. The selection is exactly the ten Dense/Sparse and four Readers cases whose previous complete correctness gates passed. Dense1024 and Readers1024 in both schemas remain excluded; no failed gate becomes a memory sample.

The outer observer posix-spawns a small C launcher. After exec resets its address space, the launcher forks from that small address space and execs the actual workload. The launcher collects that workload child's Linux `wait4.ru_maxrss` in KiB. Its own inherited peak is recorded separately as a diagnostic, and the outer observer's value remains explicitly contaminated. Tiny-child controls in `measurement-samples-rss-probe-evidence.json` demonstrate that the inner collector is insensitive to a 192 MiB retained Python heap for `/bin/true`, empty Node and a touched 32 MiB child. No new package/dependency is used.

Each memory sample still performs the full original validation of both warmup and measured output, including all final fields for Dense/Sparse and complete 234-line actual reader traces for Readers. No checksum-only shortcut replaces that gate. Build artifact hashes, full source closures, reference/validator hashes, commands, individual RSS values, process durations and timestamps are retained in `measurement-samples-memory-evidence.json`. Inner timing values are retained only as validation output; no new timing ratios are calculated.

Values cover the complete workload process: startup/imports, warmup, both setups, actual operation loops, retained observation snapshots, serialization, runtime/allocator/GC overhead and child-owned validation. The launcher itself is excluded. These are not component allocations, steady-state storage, or allocation counts. They are bounded measurements of this complete protocol; observer work outside the child is excluded, while backend-specific internal representation and output machinery remain included. CPU affinity records placement; it does not prove exclusive CPU or memory-bandwidth isolation, and these failures have not been causally attributed. No memory or performance acceptance threshold has been approved.

| Schema/workload/count | Native KiB median [min,max] | JS KiB median [min,max] | TS KiB median [min,max] | Status |
|---|---:|---:|---:|---|
| Motion dense 64 | 2772 [2752,2776] | 76180 [73920,78496] | 100328 [99744,104940] | MEASURED |
| Motion dense 256 | 3920 [3916,3924] | 205384 [138184,207712] | 100484 [99632,108936] | MEASURED |
| Motion sparse 64 | 2772 [2748,2780] | 66308 [64392,67232] | 99984 [99628,104576] | MEASURED |
| Motion sparse 256 | 3800 [3784,3916] | 93200 [91360,93460] | 100556 [98272,106204] | MEASURED |
| Motion sparse 1024 | 8408 [8400,8424] | 228860 [227256,230852] | 109752 [100568,109848] | MEASURED |
| Health dense 64 | 2904 [2880,2912] | 74936 [72844,76320] | 104284 [98756,104436] | MEASURED |
| Health dense 256 | 4316 [4308,4440] | 205472 [145376,208168] | 108704 [100008,109120] | MEASURED |
| Health sparse 64 | 2772 [2756,2784] | 64856 [62940,66016] | 103232 [99484,104376] | MEASURED |
| Health sparse 256 | 3796 [3792,3804] | 91692 [90500,92672] | 102568 [99660,106320] | MEASURED |
| Health sparse 1024 | 7904 [7888,7912] | 231064 [227824,232520] | 109864 [100068,110012] | MEASURED |
| Motion readers 64 | 5980 [5968,5992] | 104616 [102928,106268] | 103732 [102788,113016] | MEASURED |
| Motion readers 256 | not complete | not complete | not complete | REGRESSION |
| Health readers 64 | 5968 [5968,5984] | 103584 [102528,104212] | 112740 [103300,113776] | MEASURED |
| Health readers 256 | not complete | not complete | not complete | REGRESSION |

The original repeated 108952 KiB floor was measurement contamination, not equal memory use. Corrected measurements do not repair failed runtime gates or adverse timing results and do not close #19.
