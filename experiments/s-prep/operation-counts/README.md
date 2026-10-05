# HealthDense256 operation diagnostic

Copied protected retained JS artifact SHA256 `b671f0fa6160d7a9ae659737315a0d96bd1b682987c3fbb9893b2513588728cb`. Instrumentation modifies only function-entry counters and phase bookkeeping in the copied JS; it does not change candidate Bend or the evaluator. No result is timing or allocation attribution.

Executed fresh warmup plus distinct measured world in the same Node process, 64 ticks each, five-second runtime limit. All original fields passed the protected validator against freshly executed bevy-ts; work sum 8970240 and final SHA256 `c82986e7a4eccbfd7fe8a55d5d11af17cbe619e4f34d468e60b5b9f4f83ac7de`. Each world has identical entry counts:

| Operation | Entries per world |
|---|---:|
| rows_extract / rows_restore | 16384 each |
| take_rows / hook_return / put_rows | 32768 each |
| record_main / record_ledger | 16384 each |
| health_ledger_get / health_ledger_swap | 16384 each |
| mark_main / mark_meta | 16384 each |

Outside the loop brackets, final full observations cause 512 extract/restore pairs and two ledger gets across both worlds. This distinguishes final observation work from loop work but does not establish timing attribution. Representative wrapper allocation totals are not inferred from function entries: branches and compiler specialization make such inference unreliable.

First construction attempt placed counter output after the runtime's process exit; full fields passed but counters were unavailable. Retained in `first-failed-evidence.json`. Repaired with an exit listener; exact recorded positive runner hash predates addition of the optional mutant flag, which leaves positive instrumentation identical. Raw artifacts remain in `/tmp/bendvy-twohour-counts`, `/tmp/bendvy-twohour-counts-fixed`, `/tmp/bendvy-twohour-counts-mutant`.

Counter mutant increments record_main twice. Its original full fields still pass, but expected 64×256 operation-count assertions fail. `mutant-evidence.json` retains that negative; it is not a semantic candidate mutation.

Replay from repository root:

```sh
python3 experiments/s-prep/operation-counts/run.py --artifact /tmp/bendvy-prep22-paired-control/1-reference/measurement-samples-bend.js --output /tmp/operation-counts-replay
python3 experiments/s-prep/operation-counts/run.py --artifact /tmp/bendvy-prep22-paired-control/1-reference/measurement-samples-bend.js --output /tmp/operation-counts-mutant-replay --mutant
```

The second command must exit 1 after full-field validation. No optimization, benchmark qualification or keep decision occurred here.
