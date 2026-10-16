# Ordinary owned-event oracle: frame-boundary successor

This additive successor corrects the source-derived model from `../oracle/`; the original model, expected bytes, and failed JS actual01 receipt remain unchanged. It covers the same 32 complete snapshots for the frozen two-schema public trace.

The frozen `src/ecs/event-runtime.bend` distinguishes the reported `Runtime.boundary` from the cutoff used to retain batches. `frame` constructs a runtime with `frameStart=tick` and `boundary=the incoming frameStart` (lines 89–91). `trim` computes `hold_boundary(positions,boundary)` and passes that value to `past_window` for retention (lines 85–87). `trim_result` reconstructs the Runtime with its unchanged `boundary` argument (lines 81–83). Therefore, when the incoming frame start is 7 and reader cursors are 5 and 8, the batch-retention cutoff is 5 while the reported boundary remains 7. On the next frame, the reported boundary becomes 8. The model now represents these as separate values.

The predecessor oracle mistakenly stored the effective retention cutoff in the public boundary field. The retained JS actual01 output was inspected after its complete-output mismatch: the first difference was byte 8642, and all ten differing bytes were only those boundary digits (one `7` and four `8`s per schema had been modeled as `5`). The source-derived successor was generated from the frozen source semantics, then compared byte-for-byte with that already-retained JS stdout. The complete 24,875-byte outputs match; this is a correction and validation of the model, not a passing receipt for actual01. Its receipt remains `INCOMPLETE` because it was run against the predecessor expected bytes.

`SOURCE-BASIS.json` preserves the producer and runtime source pins and records the predecessor, the failure receipt, the diagnostic use of actual output, and the corrected output hashes. `derive.py --selftest` checks the complete stdout invariants and a focused example where the retention cutoff is 5 while the reported boundary is 7.

To regenerate and verify:

```sh
python3 experiments/public-owned-events/ordinary-v1/oracle-successor-v2/derive.py
python3 experiments/public-owned-events/ordinary-v1/oracle-successor-v2/derive.py --selftest
```

No Native execution or rerun was used for this diagnosis. The corrected oracle alone does not change the retained actual01 receipt's status.
