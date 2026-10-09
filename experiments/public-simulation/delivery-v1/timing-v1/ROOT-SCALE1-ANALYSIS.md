# Full simulation scale1 paired analysis

The admitted plan `b429fc3ba3e588254b3da439f78427426eb11a8edd6cb91d6de12bac85ad4f37` completed 86 fresh application processes, including two warmups and 20 balanced pairs per candidate backend. Original session 65920 terminated with exit 0. All 86 command receipts have exit 0 and no failure. The ordinary collector validates the complete outputs; independent [actual-archive review](../oracle-review-v1/sampling-scale1-actual-review.md) passes all complete outputs, guards, archive members and analysis joins.

Original receipt: `/tmp/bendvy63-timing-paired-scale1-v1/receipt.json`, SHA256 `2144396bf0850ccb908d7fba561711b8f61544ce5bc9362310493f8ff3dfb824`. Its descriptive observations remain unchanged.

Separate analysis reuses `benchmarks/decision.py` (`c16d3ffe4a0cc47354522c7e4639b92a11fdbc444e366074da73c63f82272a6a`), `assess(rows, 20, 0.05)`, with each complete lifecycle pair's simulation nanoseconds divided by 1,000,000. This is the existing approved one-sided paired sign test and Holm family correction; no numerical tolerance or #28 baseline change. Reference here is pinned TS on the complete simulation, not the frozen Bend Workshop baseline.

| Backend | Median candidate / TS time | Slower pairs | One-sided p | Holm cutoff | Result |
| --- | --- | --- | --- | --- | --- |
| JS | 3.371247992365852 | 20/20 | 0.00000095367431640625 | 0.025 | Confirmed slowdown against TS |
| Native | 0.06240076467572741 | 0/20 | 1 | 0.05 | No confirmed slowdown against TS |

Native's descriptive median corresponds to about 16 times faster execution. This test does not independently establish a universal speedup or the full-core performance gate. Internal simulation regions exclude startup/build/transport, and retain all agreed operations. Transport is reported separately. Groups 2/4 remain unexecuted and are independent fresh-lifecycle sums, not same-process population scaling.

Per-command CPU/load/frequency/pressure telemetry is retained. A brief root Git push occurred during the cohort; no guaranteed quiet-host claim is made and no outlier is removed. The consistent JS signal warrants the already reviewed conditional CPU and sampled-allocation profiles before further scaling or optimization. Allocation sampling is not physical memory/RSS.
