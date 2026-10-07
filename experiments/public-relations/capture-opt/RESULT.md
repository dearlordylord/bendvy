# Capture full application correctness — finite PASS

The independently admitted wrapper executed baseline and candidate once each. Original public application/core and complete physical observations remain unchanged. Only the two harness capture loops differ.

- `baseline-1791387043366957571`: receipt SHA256 `c13ae7746d1168dc17db4c5cc46017e7e801fc7b98e4c0baab99df3bda693a83`; ten commands, ten complete raw logs and three generated targets; actual TS, captured TS, JS and Native full 30-record observations.
- `candidate-1791387094126836221`: receipt SHA256 `48ef9e12b0e91471c4fb84a2315c29e53a3b5b1d761ab182e9cb8f6d54ac9270`; ten commands, ten complete raw logs and three generated targets; actual TS, captured TS, JS and Native full 30-record observations.

Both runs use unchanged full validator, two schemas and five-second runtime limits. Single-run durations are incidental; no comparative timing or ECS speedup is established. Finite VM transport controls remain a separate lower-level seam. Independent terminal reconciliation and before/after CPU/allocation profiling are pending; no original helper adoption or core delivery occurs.

## CPU and collected-allocation diagnostics

Both terminal profile receipts in `.artifacts/capture-{baseline,candidate}-profiles-v1`
report COMPLETE_CPU_ALLOCATION_DIAGNOSTICS_PASS_NO_VERDICT. Each of four modes
(JS/TS CPU/heap) validates all 600 complete records. Exact receipt/profile hashes
and ranked self allocation are retained in `profile-summary.json`.

Sampled collected allocation: JS447.761 ->411.425MB (-8.115%);
TS132.895 ->59.501MB (-55.227%). Single sampled CPU profiles record
JS393.100 ->374.265ms and TS153.384 ->144.440ms. These are separate exploratory
profiles, include output flush plus20ms GC-observer drain, and grant no statistical
throughput verdict. Sampling measures collected inclusive allocations, not
physical memory or RSS. The candidate improves benchmark transport in both
roles; no ECS-only speedup or Native improvement is credited. Independent
terminal reconciliation is pending. Original helpers remain untouched.
