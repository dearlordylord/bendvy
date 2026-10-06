# Concrete-owner raw Dense1024 comparison

Diagnostic only; no qualification, canonical keep, production adoption or full
performance acceptance. Twenty fixed, prospectively pinned rotations completed
on CPU11 with five roles per attempt: fresh actual bevy-ts, source-v8 JS/Native,
and concrete-v3 JS/Native. Each role compares all fields at all65 fresh worlds.
Count1024,64ticks,64worlds; runtime5s, outer attempt60s. All attempts and outliers
are retained. Timed work includes the existing physical forcing bridge; complete
serialization happens after timing, so the common physical-World gate remains
open. Peak RSS is fresh Linux whole-direct-child KiB, not active transaction or
aggregate process-tree occupancy.

| Schema | TS median ms | v8 JS / Native ms | concrete JS / Native ms | concrete JS/TS | concrete Native speedup |
|---|---:|---:|---:|---:|---:|
| Motion |635.4188185|564 /354|603 /331|0.9489804|1.9196943×|
| Health |614.561384|524 /376|542.5 /320.5|0.8827434|1.9175082×|

Concrete Native median decreases6.50%/14.76% against same-cohort v8, while JS
increases6.91%/3.53%. Both Native ratios miss the unchanged2× requirement.
These are ratios of medians, not qualified causal conclusions. Use same-cohort
TS measurements; earlier windows have different TS medians.

`summary.json` preserves every clock, range, RSS value, status and receipt hash.
The prospective r2 plan SHA256 is
`c91aa83b291440cb3e7cf7edc048458e96dc5241c4fcc164d6e8f33971d7049b`.
It pins989 inputs, including89 exact consumed JS pipeline files and current
control receipts. Initial r1 enrollment correctly refused before work because
14 actual temporary pipeline inputs had not been pinned; refusal/history is
included. The r2 runs use independently reviewed scoped admission, not full22.

`evidence.tar.xz` is a lossless SHA256-deduplicated capsule. Its adjacent manifest
maps original absolute paths to decoded blobs. It contains all non-executable
plan inputs, the exact plan/admission/history, all20 output directories and
launcher logs. Executable binaries are hash-pinned and excluded; sources and
build commands are retained. The source audit at enrollment is archived at its
then-current hash: the later conditional split-ID design append (`ca94b97`)
changed that document after this cohort finished. This is an explicit historical
snapshot, not a claim that every current checkout file still matches enrollment.

Commands (same environment/source paths required):

```sh
python3 experiments/s-prep/source-concrete-owner-observations/prepare-plan.py --help
python3 experiments/s-prep/source-concrete-owner-observations/launch.py --plan /tmp/bendvy-concrete-owner-cohort-plan-r2.json --output /tmp/bendvy-concrete-owner-raw-cohort-r2 --prefix /tmp/bendvy-concrete-owner-observed-v3
python3 experiments/s-prep/source-concrete-owner-observations/summarize.py --prefix /tmp/bendvy-concrete-owner-observed-v3 --output /tmp/concrete-summary.json
python3 experiments/s-prep/source-handoff-observations/verify-archive.py experiments/s-prep/source-concrete-owner-observations/evidence.tar.xz
```

Launcher deadline2026-10-06 20:25:54UTC is intentionally frozen; archived replay
requires an explicitly new prospective plan/launcher, not editing past inputs.
Follow-ups: complete qualification/full workload-size matrix, shared timed
physical forcing, authority/confinement/full22 and transaction occupancy gates;
reduce carrier word cost without changing affine behavior and remeasure.
