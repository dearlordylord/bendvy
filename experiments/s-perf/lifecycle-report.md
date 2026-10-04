# Indexed Lifecycle results

**All six cases measured.** Native O3, JS and pinned TS pass each complete
192-boundary trace before timing, including 6112 historical stale lookups, 64
actual reservation payloads, complete Main/Aux/flag fields, ordered queries,
ledger, final world, captures and clocks. Seven rotated samples follow each
passing gate, with one fresh warmup world and one fresh measured world.

| Schema | Count | Native ms | TS ms | JS ms | Native/TS | JS/TS |
|---|---:|---:|---:|---:|---:|---:|
| Motion | 64 | 7.000 | 15.268 | 41.000 | 0.458 | 2.685 |
| Motion | 256 | 20.000 | 24.195 | 62.000 | 0.827 | 2.563 |
| Motion | 1024 | 65.000 | 71.071 | 152.000 | 0.915 | 2.139 |
| Health | 64 | 7.000 | 14.151 | 33.000 | 0.495 | 2.332 |
| Health | 256 | 19.000 | 26.440 | 61.000 | 0.719 | 2.307 |
| Health | 1024 | 70.000 | 81.880 | 193.000 | 0.855 | 2.357 |

Medians above are inner-interval times. Setup, warmup and final serialization
are outside that interval; authored dispatch, barriers, observations and ordered
full-field checksum work remain inside. Raw values and min/median/max variability
are in `lifecycle-evidence.json`. No Native sample falls below the 10 ms
resolution-warning boundary. Ratios are descriptive; no numerical acceptance
threshold has been approved. Native is faster on these cases, with gains narrowing
at larger sizes; JS remains roughly 2.1–2.7 times slower than TS. These results
do not establish the mandatory product performance requirement.

| Schema | Count | Native peak RSS KiB | TS peak RSS KiB | JS peak RSS KiB |
|---|---:|---:|---:|---:|
| Motion | 64 | 4188 | 100016 | 74300 |
| Motion | 256 | 6620 | 100428 | 102244 |
| Motion | 1024 | 16032 | 119220 | 252776 |
| Health | 64 | 4196 | 108544 | 73668 |
| Health | 256 | 6752 | 108160 | 102528 |
| Health | 1024 | 16556 | 119188 | 268448 |

RSS is the whole backend child peak, including warmup/setup/final output,
collected by the reviewed small C exec-reset launcher with `wait4`. It is not
an allocation count. Actual physical log/holder retention, staged/pending peaks
and registered-reader positions/unread/lag are **unavailable in this adapter**;
empty final pending does not imply zero peak occupancy or physical retention.

Replay after materializing the final candidate overlay:

```sh
python3 experiments/s-perf/overlay.py /tmp/indexed-lifecycle-overlay
python3 experiments/s-perf/lifecycle-run.py --overlay /tmp/indexed-lifecycle-overlay --build-dir /tmp/indexed-lifecycle-results --cpu 10
```

Exact overlay sources, compiler/Base, references, validator, helper and launcher
hashes are pinned in the evidence. Checker/runtime limits remain 5s, code
generation 30s and clang 120s; Native uses O3, one worker and GPU off. CPU 10
affinity is not an exclusive machine reservation. The final run has no
overlapping task-owned CPU 10 builds.

Preserved earlier attempts are summarized in `lifecycle-attempts.json`:
final2 exposed a pure/IO wrapper mismatch; v3 exposed obsolete `CMD.apply` in
foreign-world setup. The candidate timing wrapper now binds IO barriers and
handles checked foreign setup rejection explicitly. Superseded v4 was stopped
when command preflight changed to direct self-tail recursion after the E11 JS
overflow. Its partial data and Native/JS Motion1024 deadlines remain recorded.
It also overlapped task-owned CPU 10 control builds, so its deadline change
cannot be attributed solely to the preflight repair. Full raw outputs, RSS
metadata, build artifacts and the final immutable overlay are retained in
`.artifacts/indexed-lifecycle-20261004.tar.gz`, with its SHA256 in the attempt
record. The wrapper compatibility fixes do not relax payload or observation work.

Recommendation: retain this candidate as a bounded native improvement, continue
profiling JS provider/query and authored-observation costs, and add actual
occupancy/reader instrumentation. Return to adoption only after the same complete
field gates still pass and equivalent JS work meets the product requirement.
No universal runtime refinement, production adoption or new proof is claimed.
