# Independent JS profile preparation review

BLOCKED for immutable preparation `6978543862342b5ad86dcf74a1ee360b4e2ff25a`; no subject was run. The four INDEX plans (27a437d2/70f2dd10/29dd7a07/9a1045d0) remain unadmitted.

Concrete defect: `development.py` CPU validation rejects any negative timeDelta. V8 CPU profile timeDeltas are signed integer deltas; this repeats the previously corrected Node24 raw-profile signedness assumption. A valid signed sample delta must not invalidate otherwise complete capture. Minimal correction is exact-int validation without the nonnegative constraint, with negative-integer acceptance and bool/noninteger refusal controls; preserve these old plans and freeze successors after changing pinned code/tests.

All four exact original plan digests, 71 current pins per plan, resource bytes/memberships and fresh output directories containing only plan.json independently pass. Exact existing before/after JS artifacts are qualified whole-output subjects; no emission command exists. Settings match by mode: Node24.20, CPU5, cap5, CPU100µs or heap8192B, unchanged full 5,077,477-byte oracle.

Reviewed bootstrap captures verified helper source before execution. One internal lock per child, acquired/post/final progressive guards, completed result ledger before publication, regular partial profile capture in finally before failure interpretation and unconditional failure receipt are retained. Full stdout and empty stderr are required before profile qualification.

Accounting labels Linux ru_maxrss as peak across reaped subprocess subtree including runner owner and Node, not Node-only or timed-region RSS. CPU profiles cover the whole process; heap samples describe sampled retained allocations at exit, not total allocation traffic. No timing speedup, stock compiler or adoption claim follows from these profiles. Final admission awaits the narrowly repaired immutable batch.
