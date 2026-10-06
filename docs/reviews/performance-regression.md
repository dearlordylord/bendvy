# Performance regression benchmark review

Independent read-only review of `benchmarks/contract.json`, `run.py`, `decision.py`,
decision controls and both executable cohorts. No unresolved actionable findings.

The exact one-sided paired sign calculation excludes ties and tests positive
candidate-minus-baseline differences. Holm step-down correctly handles two
endpoints at family alpha0.05. Four statistical controls pass, including an
unadjusted-significant result rejected by Holm.

Both roles compile the fixed baseline's identical Workshop workload with the
same toolchain. Each backend has20 adjacent pairs, exactly10AB and10BA orders.
Every process executes ten complete22-point applications. All samples remain.
The reviewer independently decoded110 outputs in each cohort (24,200 complete
checkpoints/cohort) and checked source/artifact hashes. Earlier missing staged
inventory/reference-drift checks were fixed before these admitted cohorts.

Ordinary cohort correctly returns NO_CONFIRMED_REGRESSION: JS p0.057659,
Native p0.942341. The real30ms-delay control retains all observations and rejects
both endpoints:20/20 slower, p2^-20. Source and artifact pins match final files.

Acceptance remains the approved no-confirmed-slowdown policy for this workload;
finite power, host stability and startup/output remain explicit limits. No
equivalence, qualified hot-path or full-matrix acceptance is inferred.
