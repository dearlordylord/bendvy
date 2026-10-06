# Native1024 phase CPU diagnostic

`sample.py` is the fresh r2 Linux/aarch64 sampler. It inserts only a fixed
lock-free atomic SIGPROF PC buffer and clocks3/4 phase hooks into copied C.
The original C/compiler/runtime binaries remain unchanged. ITIMER_PROF requests
1ms process-CPU intervals and may deliver signals to any unblocked OS thread.
Samples are not worker residency, exact durations, call stacks or causation.

Both schemas freshly match all65 complete TS observations. Motion/Health collect
413/366 PCs with zero pending slots. [`summary.json`](summary.json) retains exact
function counts; many samples occur in reference-count/owner transport routines.
This supports investigating that seam, without proving it is the sole bottleneck.

Original source29/build/reference/validator, installed tools, new include closure,
nm/addr2line binaries/libraries and sampled binary are prospectively pinned and
rechecked. Existing Dense enrollment supplies the reference-driver join; this
sampler does not independently reproduce that derivation. `-g`, `-no-pie`, signal
interrupts and clock4 stop/printing perturb the run. **No elapsed clock from these
runs may support a performance comparison.** Runtime5/Clang120 remain unchanged.

`sample-r1.py` and r1 receipts retain historical full65 controls with incomplete
header/symbol-tool provenance. Fresh r2 supersedes only that diagnostic admission.
Read [independent review](../../../docs/reviews/native-phase-profile.md) for all
remaining failure-path/provenance limits.

`evidence.tar.xz` plus adjacent manifest preserves exact decoded C, logs, PC
symbolization, receipts and both recipe versions. Native executables are hash
pinned and reproducible, excluded from the compact capsule. Verify:

```sh
python3 ../source-handoff-observations/verify-archive.py evidence.tar.xz
```

No laws/proofs, dependency installation, compiler/kernel/reference modification,
performance acceptance or production adoption is claimed.
