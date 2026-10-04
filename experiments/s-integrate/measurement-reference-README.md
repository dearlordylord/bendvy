# Pinned TS integrated measurement reference — Dense/Sparse checkpoint

Run with existing Node v24.20.0:

```sh
node experiments/s-integrate/measurement-reference.mjs --all
```

The parent invokes twelve fresh children with a hard five-second execution limit each. No dependencies are installed. Each child directly imports the pinned public `bevy-ts` core (`3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`); evidence records adapter, measurement-contract, trace and reference-module hashes. A failed assertion or child failure aborts the run instead of producing a passing sample. The adapter writes only its own evidence file.

## Actual work and validation

Both separate nominal schemas run Dense and Sparse at initial live counts 64, 256 and 1024, width four, for 64 iterations. Setup uses an actual `Seed` system, returned raw reservations and explicit deferred barrier. Every iteration dispatches the same actual `Update` system through the public runtime. Its declared writable query reads all four Main cells and sets a new payload preserving scalar metadata; each updated row performs an actual resource-provider read and write. These are not direct world/storage mutations or numeric-loop substitutes.

Sparse additionally executes independent optional/present/absent Aux queries on every iteration, reading all Main/Aux/Flag fields and ordered raw IDs through their providers. Main exists iff logical label is divisible by eight; Aux iff divisible by three, Flag iff congruent to one modulo three. Motion uses Position/Velocity/Selected/MotionLedger; Health uses Vitals/Armor/Tracked/HealthLedger. Resource initialization, complete scalar metadata and Aux values follow the measurement contract and trace.

After execution an actual read-only Dump system observes every selected row and resource field. Exact deep comparisons cover the complete final objects and their ascending raw IDs. Every iteration's four-cell read sum, updated count and ordered full-field selection checksum are compared to a separately constructed arithmetic fixture. Checksums supplement the exact full final comparison. Recorded final and oracle SHA256 values must match; evidence stores first/last complete rows and the shared lossless fixture formula (all intermediate labels obey the same recorded input definitions). Sparse unselected entities remain live but do not falsely contribute to updated counts. Raw reservations are checked as the complete sequence 1..n before compact range encoding.

Fresh replay: **12/12 PASS**. This establishes these TS authored workloads, not Bend parity or performance acceptance. Source has no failure/retry/pending-after-update or reader path in this first checkpoint: those observations belong to the three explicitly open workloads below.

## Timing boundary and remaining work

Current durations are single-run diagnostics only: setup, 64 dispatched iterations, then final dump and validation. No warmup, seven repetitions, CPU-affinity freeze, backend alternation, ratios or numerical acceptance is claimed. Process peak RSS includes Node startup/imports/setup/validation and is not component allocation cost. The workload contains dispatch costs; its only structural barrier is setup and is outside the execution interval. Dense/Sparse do not publish reader messages or structural commands after setup.

Before comparative measurements, freeze the cross-backend observation/checksum work, CPU/worker configuration and runtime limits; run separate fresh-world warmups and seven fresh repetitions only after correctness validation. Retain dispatch/barrier work required by each workload. Numeric thresholds remain unapproved.

Still to implement in this same adapter: lifecycle/churn with rotating first/middle/last targets; transient-entity Fast/Slow readers and final drain with frozen capacity/registration clocks; A commit, failing B and same-instance retry with pending spawns, full rollback/publication/reader/capture and raw allocation observations. Their absence is a coverage gap, not successful measurement. The complete main trace/ownership/access/mutation and Native/JS integration gates also remain separate.
