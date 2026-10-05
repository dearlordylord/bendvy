# One whole-process JS profile

Executed **one** already-compiled checked combined candidate JS process, on CPU 11, under the unchanged five-second process-group deadline. Node v24.20.0 `--cpu-prof --cpu-prof-interval=100`, arguments `1 0 256 1`: Health/Dense256 with fresh warmup and measured worlds. Artifact SHA256 `93f6bceb0b8c738e566400cffc8905e74c6b4e326256678c69414f8d7f81238a` matches the passing combined construction receipt. Original stdout full fields passed the unchanged measurement validator against freshly executed pinned bevy-ts: work sum 8970240, final SHA256 `c82986e7a4eccbfd7fe8a55d5d11af17cbe619e4f34d468e60b5b9f4f83ac7de`.

The profile contains 701 samples. Exclusive sample counts below aggregate the same function across call contexts; they are **whole-process sample shares, not inner-loop time shares**.

| Exclusive function/category | Samples | Share |
|---|---:|---:|
| Garbage collector | 129 | 18.4% |
| host render_push | 46 | 6.6% |
| runtime closure trampoline `f` | 40 | 5.7% |
| String.reverse.go | 21 | 3.0% |
| Node module wrapSafe | 18 | 2.6% |
| String.reverse | 18 | 2.6% |
| transaction record_ledger | 17 | 2.4% |
| storage with_main | 15 | 2.1% |
| anonymous Ledger swap closure | 15 | 2.1% |
| authored health_rows | 14 | 2.0% |

Exact node/function sample tables, URLs, emitted-source lines and raw profile hashes are in `receipt.json`. Raw files remain under `/tmp/bendvy-twohour-cpu-profile-dr_0e6vg`; no raw profile is added to Git.

Source mapping of relevant candidate work, in the exact profiled artifact:

- Line 5185 `record_ledger`: constructs Tx, LedgerInverse, and undo-list Con for every successful scalar Ledger write. Source: `experiments/s-integrate/transaction.bend:24–30`.
- Line 5134 `with_main`: destructures World/Handle and rebuilds a World to pass the checked affine hook. Source: combined candidate `storage.bend`, `with_main`.
- Anonymous closure at line 5274 calls `health_ledger_swap` through `with_ledger`. Source: `transaction.bend:70–72`.
- Line 4531 `health_rows`: invokes the authored transactional Main read/write and Ledger read/write for each handle. Source: `candidate/measurement-bend.bend:77–80`.
- Line 130 runtime `f`: `run_clo` creates a callable wrapper that evaluates `run_loop(j(x))`, not a user ECS callback body. The trampoline supports compiled closures; samples here do not prove closures dominate the authored loop.
- Render/string functions transport full final observations. Their visible presence demonstrates why this whole-process profile cannot be read as a measured-inner-region profile.

Startup parsing/module loading, runtime/JIT behavior, warmup, measured world, final observation rendering, and profiler overhead all contribute. The actual time deltas vary despite a requested 100-microsecond sampling interval; sample shares are approximate and not confidence intervals. GC samples establish sampled collector activity, but do not identify allocating functions, retained bytes, object counts, or allocation attribution. No allocation statistics were collected. Sampling has overhead and this profiled execution supplies no comparable benchmark time, speed claim, keep decision, or accepted loop session.
