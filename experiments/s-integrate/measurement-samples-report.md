# CPU5 steady-state samples: Dense/Sparse

This is adverse descriptive performance evidence, not numerical acceptance. Ten cases completed seven fresh repetitions on all three backends with complete output validation every time. Dense1024 in both schemas failed the Native and JavaScript five-second prerequisite children; TS passed, but no ratios are reported for these cases.

Command: `python3 experiments/s-integrate/measurement-samples-run.py`. Source, compiler, Base, Node, clang and contract hashes, exact commands, raw inner milliseconds and explicitly withdrawn `wait4` readings are in `measurement-samples-evidence.json`. Inputs are64 iterations, width4, counts64/256/1024, one fresh warmup world and one measured world per process, CPU5, NativeO3 one worker GPUoff. Seven orders rotate Native/TS/JS. Setup, warmup and JSON output are outside the inner clock; The original RSS method is invalid and its comparisons are withdrawn. All runtime children retain the five-second limit, checker5s, codegen30s, clang120s. No existing runtime, measurement source or reference was edited.

The new TS timing adapter retains actual public queries, per-row writes and resource updates. It removes TS-only structuredClone/audit allocation and uses Bend's same full-field weighted U32 checksum. The unchanged authoritative reference is freshly run per case; every measured final object is independently checked. The checksum supplements full-object validation. Prior CPU10/batch4 evidence (`a299599`, `bc167e6`) is separate and is not relabelled as this run.

Ratios below divide median Bend milliseconds by median TS milliseconds; greater than1 means slower than TS. Integer `IO.now` quantization makes both Sparse64 cases resolution-limited; their ratios are descriptive unstable diagnostics. No acceptance threshold is approved. **RSS comparisons are withdrawn.** Fresh controls show direct `posix_spawn`/`wait4` inherits a floor from the Python observer: tiny children report its retained heap peak. Recorded values and their historical summaries are explicitly labelled contaminated/withdrawn in the evidence. No corrected ECS memory measurements have been collected; see `measurement-samples-rss-report.md`. CPU affinity reduces migration but does not establish isolation from all system contention.

| Schema/workload/count | Native ms median [min,max] | JS ms median [min,max] | TS ms median [min,max] | Native/TS | JS/TS |
|---|---:|---:|---:|---:|---:|
| Motion dense 64 | 30.000 [22.000,83.000] | 58.000 [45.000,104.000] | 6.030 [4.350,24.167] | 4.97 | 9.62 |
| Motion dense 256 | 408.000 [377.000,498.000] | 581.000 [517.000,624.000] | 21.343 [13.343,25.110] | 19.12 | 27.22 |
| Motion dense 1024 | deadline | deadline | prerequisite passed | — | — |
| Motion sparse 64 * | 4.000 [4.000,5.000] | 15.000 [14.000,40.000] | 2.933 [2.189,5.777] | 1.36 | 5.11 |
| Motion sparse 256 | 46.000 [41.000,48.000] | 85.000 [81.000,114.000] | 5.579 [3.740,15.315] | 8.24 | 15.23 |
| Motion sparse 1024 | 821.000 [749.000,1127.000] | 961.000 [856.000,1321.000] | 14.455 [12.938,29.337] | 56.80 | 66.48 |
| Health dense 64 | 24.000 [23.000,26.000] | 46.000 [41.000,57.000] | 3.958 [3.601,5.792] | 6.06 | 11.62 |
| Health dense 256 | 381.000 [314.000,428.000] | 491.000 [443.000,590.000] | 13.544 [11.350,13.905] | 28.13 | 36.25 |
| Health dense 1024 | deadline | deadline | prerequisite passed | — | — |
| Health sparse 64 * | 6.000 [4.000,17.000] | 21.000 [19.000,52.000] | 3.050 [2.531,8.810] | 1.97 | 6.88 |
| Health sparse 256 | 88.000 [43.000,277.000] | 139.000 [67.000,271.000] | 8.101 [4.601,20.609] | 10.86 | 17.16 |
| Health sparse 1024 | 793.000 [764.000,832.000] | 887.000 [856.000,1129.000] | 16.097 [14.736,17.755] | 49.26 | 55.10 |

* Native sample below10ms; integer-millisecond resolution is material. Failed cases receive no seven-run retry campaign. These results do not satisfy the project’s mandatory performance objective and do not close #19.
