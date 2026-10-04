# Withdrawal of sampling RSS comparisons

All RSS comparisons in the Dense/Sparse and Readers sampling reports are withdrawn. Direct Python `posix_spawn` followed by `wait4.ru_maxrss` returned an observer-dependent floor; using the same collector for all backends did not make the values comparable. The earlier claim that `posix_spawn` avoids the Python pre-exec heap contribution was incorrect. The common108952KiB values are not evidence that the backends use equal memory.

Fresh CPU5 command: `python3 experiments/s-integrate/measurement-samples-rss-probe.py`. `/usr/bin/time` and `/bin/time` are absent, so the check uses a small locally compiled C launcher. The launcher starts with an exec-reset address space, forks from that small address space, execs the requested child and records that child's `wait4` result. The outer Python observer still enforces the five-second process-group deadline. No new dependency is used.

| Python observer | Child | Direct wait4 KiB | Small-launcher child wait4 KiB |
|---|---|---:|---:|
| Small | `/bin/true` |15260|728|
| Small | Empty Node |41444|40960|
| Small |32MiB allocated and page-touched C process |33576|33580|
|192MiB retained heap | `/bin/true` |211880|728|
|192MiB retained heap | Empty Node |211880|40972|
|192MiB retained heap |32MiB allocated and page-touched C process |211880|33480|

These controls demonstrate the contamination and show a concrete way to avoid this floor in this environment. They do not themselves provide corrected memory measurements for any ECS workload. A subsequent separate run is recorded in `measurement-samples-memory-report.md`; the original timing-run RSS remains withdrawn. Launcher/compiler overhead, allocator/GC behavior, descendants, setup, retained observation snapshots and output all need an explicitly bounded future memory protocol; process peak RSS is not component allocations or steady-state live storage.

The two sampling evidence files preserve every original timing interval, validation result, backend order, ratio and deadline outcome. Original wait4 values are renamed `contaminatedWait4RssKiB`; their summaries are retained only as `withdrawnWait4RssSummaryKiB`. The original run is pinned to374d9f7 and its original runner hashes. Current runners label raw wait4 readings as contaminated and no longer summarize them as peak RSS. Reports remove memory comparison columns. The original sampling contract remains frozen as a historical artifact; this correction supersedes its RSS-method claims.

No timing sample was rerun or numerically adjusted in this correction. The descriptive timing results retain their existing resolution, workload-equivalence and whole-process deadline limitations. No allocation claim, memory advantage or #19 performance acceptance follows.
