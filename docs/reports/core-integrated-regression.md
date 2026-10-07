# Integrated core regression

Command: `python3 benchmarks/run.py --output .artifacts/core-integrated-default-regression-v1 --cpu 11`.

Terminal result: **NO_CONFIRMED_REGRESSION**. The unchanged #28 contract runs
20 balanced pairs per backend against baseline `327bec49`, retaining every
sample and all 110 complete warmup/timed observations. Statistical controls
also pass (`python3 benchmarks/test-statistics.py`, four tests).

| Measurement | Median ratio | Boundary |
| --- | --- | --- |
| JS / frozen Bend baseline | 0.9497114128 | Paired protected Workshop workload |
| Native / frozen Bend baseline | 0.9783580956 | Paired protected Workshop workload |
| JS / bevy-ts | 0.3992360770 | Descriptive equivalent Workshop work |
| Native / bevy-ts | 0.0691918848 | Descriptive equivalent Workshop work |

JS has four slower pairs of 20; Native has six. The one-sided slowdown p-values
are 0.9987115860 and 0.9793052673, respectively. This is a regression decision,
not a statistical proof of speedup or equivalence. The TS ratios do not qualify
all new feature workloads or full parity.

## Exact source and execution binding

All 38 recorded source hashes match: 33 core `.bend` modules and five benchmark
scripts/contract files. The 33 recorded core paths exactly match the current
core, with no unrecorded or removed modules, verified using:

```sh
python3 scripts/check-receipt-sources.py --require-core-inventory \
  benchmarks/evidence/core-integrated-default-regression-v1/receipt.json
```

The new source set includes `state.bend`; the preceding receipt contained 32
core modules plus the same five benchmark inputs and does not qualify this set.
The receipt SHA256 is
`6a35aad279e8bc08ae92c552366ce3c8e1f43f5918d8b8c3e5550d3b84aabbdd`.
Portable receipt/observations are in
`benchmarks/evidence/core-integrated-default-regression-v1/`. The accompanying
execution archive retains all 202 source, generated-code, executable and log
files; roundtrip file membership and hashes were verified. File manifests are
retained alongside the archive. The runtime/compiler/kernel were not changed.

Before starting, a five-second host sample showed CPU11 100% idle and the host
70.75% idle. This is an interval observation, not a contention-free guarantee.
Close randomized pairs mitigate drift; all observations remain in the result.

## Changes exercised and separate obligations

- World handles use a descending tail scan and prepend live handles, preserving
  ascending output and every returned World owner. Original high-water JS faults
  are retained; the separate 53-command scan control includes actual queued
  spawn payloads, Resource Arrays and four reached mutants on both backends.
- Event size counts batch payload lengths without concatenating them. Empty
  append inputs return the other list; nonempty concatenation is unchanged.
  Reader collection computes its identical concatenated Data list once.
  Full reader observations, finite actual mutants and before/after CPU/allocation
  profiles are retained in the parity-feature experiments.
- The public component-state candidate is present in this source inventory.
  Its own state, error, ownership, mutant and feature-timing requirements remain
  governed by #47; an unused-module baseline workload cannot satisfy them.

This report delivers the protected regression evidence only. #38 identity and
failed-reservation contracts, #34/#35 feature delivery, #47 feature qualification,
and full-core performance #21/#23/#24 remain separate. New laws remain unapproved;
no ECS proof or universal runtime refinement is claimed.
