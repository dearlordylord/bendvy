# Motion split-ID source comparison

Raw diagnostic only; no qualified keep or product acceptance. Ten fixed balanced
rotations completed on CPU11. Each of five roles (fresh TS, concrete-v3 JS/Native,
direct-v1 split-ID JS/Native) compares all fields in65 fresh worlds,1024 entities,
64ticks and64measured worlds. Runtime5/outer60; all outliers remain.

| Role | Median ms | Whole-direct-child peak RSS median KiB |
|---|---:|---:|
| TS |633.347607|338604|
| Concrete-v3 JS |584.5|400370|
| Direct-v1 JS |579.5|397252|
| Concrete-v3 Native |333.5|18220|
| Direct-v1 Native |345|18276|

Direct JS/TS0.9149794; Native speedup1.8357902×. Against same-cohort concrete-v3,
JS decreases0.86% while Native increases3.45%. The counter mechanism is real
(requested words169,438,223→137,980,943), but lower word requests do not establish
faster execution: additional ID buffer accesses remain. The representation is
not selected as a Native improvement. These ratios of medians are descriptive;
qualification/causality remain open. A brief CPU10 fresh Health validation ran
during this cohort; all data, including a660ms Native outlier, is retained.

Prospective r3 plan SHA256
`d5910e4511845084022203cc06f4b189014ac95077c4816651c03f6d7513047c`
binds1134 inputs and exact source29/cache/build/92-consumed-file JS producer
maps plus fresh lifecycle/mutation/control receipts. Independent preparation
replayed byte-identically before execution. Two refused preparations are
retained: nested tool-receipt structure, then equality of raw ASLR-bearing ldd
output. Final code validates stable binary/library maps and environment instead.
No workload was run under either refused preparation.

Outer exit/timeout/owned-descendant failure remains authoritative even if a
PASS receipt was published. `outer-control.py` injects ten such failures with
zero actual children and verifies the real launcher and summary emit no medians.
This is an infrastructure control, not an ECS mutation gate.

`summary.json` retains every clock/range/RSS/status/receipt hash. The lossless
SHA256-deduplicated `evidence.tar.xz` and adjacent manifest retain all non-ELF
plan inputs, ten output directories, outer index/logs, admission, refused
preparers and infrastructure control output. Executable hashes/build commands
are retained; binaries are excluded. Every decoded blob was independently
verified. Historical review snapshots are explicitly identified if applicable.

```sh
python3 experiments/s-prep/source-motion-id-observations/prepare-plan.py --help
python3 experiments/s-prep/source-motion-id-observations/launch.py --plan /tmp/bendvy-motion-id-cohort-plan-r3.json --output FRESH_DIRECTORY --prefix FRESH_PREFIX --expected-plan d5910e4511845084022203cc06f4b189014ac95077c4816651c03f6d7513047c
python3 experiments/s-prep/source-motion-id-observations/summarize.py --prefix FRESH_PREFIX --index FRESH_DIRECTORY/results.json --output FRESH_SUMMARY
python3 experiments/s-prep/source-handoff-observations/verify-archive.py experiments/s-prep/source-motion-id-observations/evidence.tar.xz
```

Existing temporary paths and frozen deadline2026-10-06 20:25:54UTC are part of
this historical execution. Replay needs a new prospectively reviewed enrollment.
Follow-ups: common timed physical-World forcing, qualification/full5×3, active
transaction memory, whole-Host22 and production detached-batch confinement.
