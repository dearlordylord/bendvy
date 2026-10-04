# Physical occupancy inspection — finite milestone

Contract: `occupancy-method.md`, read before implementation. This diagnostic
milestone does not complete #20 occupancy or workload/performance acceptance.
Run `python3 experiments/s-perf/occupancy-run.py`.

Observed exit0: NativeO3/JS agree on 32 stream/reader and 17 actual indexed
World/Tx checkpoints. The same nine actual callback/transaction trace lines match
independently compiled uninstrumented fixtures. Inspectors return their owners;
they invoke no begin/complete/skip/frame/trim operation to obtain a metric.

Measured from actual owners:

- Both physical Buffer lists; individual actual values, batches, declared batch
  counts, cached size, dropped stamp and independent consistency flags.
- Actual stored reader base keys/interests/registeredAt/lastRun/streamLastRun;
  registration-aware lag, actual retained unread values and independent actual
  `R.holders` lists. Equal cursor positions retain distinct holder identities.
- Indexed World namespace/allocator/live metadata/high-water, pending Type command
  entries and actual sizes of all three returned column owners.
- Actual Tx staged Type commands/Pings, inverse entries and marks, including
  repeated Main writes and a Ledger write, inspected after every finite append.

The finite controls distinguish absent registration and registeredAt0; failed
read/retry; late registration (unread selection is not clipped by registration);
skip's stream-only advancement; front versus rear; whole Ping batches versus unit
lifecycle batches; two equal-position holders; malformed cached/batch sizes;
staged commands2 versus pending1; failure retaining prior pending1; successful
publication raising pending2; and empty unread for one successful reader while
physical retention remains Ping3/removed2/despawned1 with three holders.

Seven compiling instrumentation mutants are detected on both backends while
preserving the exact uninstrumented callback trace: omitted rear, stale size,
lost holder, swapped cursor kind, ignored registration, staged-as-pending and
hardcoded physical zero. The initial staged-as-pending mutation failed checking
because its Data `ws` was consumed twice. This was an invalid mutation attempt,
not a semantic kill; adding `+ws` in that mutant only produces the delivered
compiling comparison. No compiler/kernel repair or ECS proof was involved.

CPU8; NativeO3 one worker/GPUoff; existing Node for JS. Checker/runtime5s,
codegen30s, clang120s. Runner freezes the baseline plus indexed overrides in its
own temporary copy, records reachable source hashes, cleans its own process
groups on deadlines and removes the temporary package. No dependency/reference
or main candidate source was changed.

Unavailable at this milestone: actual five-workload boundary records and maxima,
transient publication-before-trim positions, running callback boundaries, active
Tx append peaks in real workloads, arbitrary component-specific removal logs,
process RSS and allocation counts. Finite fixture maxima are not workload maxima.
The next return gate is actual Readers64-iteration diagnostic replay at all three
sizes and both schemas with complete unchanged public trace/ref comparison,
explicit publication/barrier/frame source order and per-cell availability.
Other workload active-Tx instrumentation requires a separate owner-carried meter
or actual hook; no missing value may be inferred from post-commit empty state.
