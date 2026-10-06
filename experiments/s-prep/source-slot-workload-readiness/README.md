# Frozen Slot workload readiness

**Partial readiness; no #21/#24, full22 or performance acceptance.** This task
adapts original workload fixtures to the unchanged private Main Slot Host closure
`4baad4960575cda216576e8b90593fbd7ed7dcd44cfa86836b8d87dd5af71f5c`.
The 29 protected runtime files remain byte-identical. Trusted fixture transport
is copied into separately named `workload-*` modules; the protected benchmark
entry is not substituted for other workload algorithms.

`prepare.py` guards the original fixtures at commit `8250177`, maps concrete
Main/Host/Tx types to the existing affine Slot services, wraps raw seed/spawn
payloads once, lifts actual IO barriers and transports current template binders.
The six authored Dense/Sparse callbacks and the entire generic dynamic failure
callback module remain byte-identical. Ledger retains its existing cached
payload; Main is an affine persistent Slot. Original query, dispatcher,
capture/readers, command queues, real factories and live foreign-world handles
remain in the fixture routes. Foreign lookup semantics preserve Bend
MissingEntity and the intentional TS receiver-local raw-ID collision.

## Complete diagnostic fields

Each cell covers Motion and Health. Every passing backend cell validates one
fresh warmup world and a second fresh world in the **same process**, against
freshly executed pinned bevy-ts references and unchanged original validators.
All 64 authored iterations execute. `T` means the unchanged **five-second**
runtime limit fired, including diagnostic rendering/output; it is not a
qualified algorithm timing or performance ratio.

| Diagnostic fixture | 64 JS / Native | 256 JS / Native | 1024 JS / Native |
|---|---|---|---|
| Dense | pass / pass | pass / pass | pass / pass |
| Sparse | pass / pass | pass / pass | pass / pass |
| Legacy Lifecycle full fields | pass / pass | T / T | T / T |
| Legacy Readers full fields | pass / pass | pass / pass | T / pass |
| Dynamic FailedTxn full fields/effects | pass / pass | pass / pass | T / T |

These full diagnostic Lifecycle/Readers/failure fixtures establish their
original authored algorithms and observations. They do **not** replace the
frozen buffered-reader, historical-stale Lifecycle or quiet failure wrappers.
No partial timeout output is admitted as a passing result.

## Frozen wrapper distinctions

`frozen.py` checks the available original workload bodies at size 64, Motion and
Health, both JS and Native, with two fresh worlds in the same process:

- Buffered Readers: original buffered event-batch work and complete output pass.
- Historical-stale Lifecycle: original full mode passes all 192 observations,
  6,112 historical stale lookups, all 64 raw reservations, the complete final
  owner/query and actual captures/clock **per fresh world**. Its actual frozen
  TS full counterpart also executes twice and passes. Distinct expected TS/Bend
  foreign lookup digests remain explicit in the unchanged validator.
- Dense/Sparse: unchanged shared sample **inner body** passes; the diagnostic
  wrapper calls that body twice with identical fresh warmup. The sample module
  is included, but this receipt does not independently invoke
  its outer `run(batch)` wrapper or admit a timing batch.
- Quiet FailedTxn: **not admitted**. The actual quiet-specific helper closure
  and tuple codec fail closed at unknown `E.FailureObserved`. Protected
  `host-observations.bend` also lacks `FailureRead` and `FailureResult`;
  `dispatcher.bend` lacks `Recorded` Audit and its existing Console service
  prints authored effects. See [quiet-interface-gap.json](quiet-interface-gap.json).

A task-local diagnostic sidecar cannot make that original service execution
quiet while retaining the protected callback/runtime interface. Follow-up:
freeze a separately reviewed source with real recorded Audit and failure event
owner/observer transport, preserve all authored workload work and observations,
and run fresh exact closure/type/negative/full-field gates before quiet timing.
Do not retrofit the protected source or claim the emitting diagnostic run as
quiet codec admission. Frozen 256/1024 wrapper admission remains a follow-up.

## Evidence and limits

[summary.json](summary.json) distinguishes diagnostic and frozen rows.
[evidence/manifest.json](evidence/manifest.json) pins every decoded archive
member. The archive retains the exact source overlays, generated entry fixtures,
complete passing stdout, partial timeout stdout, checker/build logs, actual
command arguments and original validator/reference pins. Generated JS/C/native
file hashes are retained separately; binaries are reproducible from the archived
source and recorded build commands. Every archived member digest was decoded
and checked. Historical recipe status strings are retained unchanged and are
interpreted by the narrower scope above.

Commands: `prepare.py --source /tmp/bendvy-slot-host-v1 --output <new-folder>`;
`run.py --prepared <folder> --output <new-folder> --sizes 64` (then 256 1024);
`frozen.py --prepared <folder> --output <new-folder> --sizes 64`.
CPU 6 diagnostics use executable checker 15s, emit 30s, private Clang19.1.7/O3
build 120s and runtime 5s; Native uses one thread, GPU off. No ECS proof, law,
compiler/kernel/reference change, dependency, RSS/timing cohort, cap reset,
keep/qualification or another task's gates are claimed. Comparative timing is
owned by the root task. After these bounded children CPU 6 is paused for its
controlled timing request.
