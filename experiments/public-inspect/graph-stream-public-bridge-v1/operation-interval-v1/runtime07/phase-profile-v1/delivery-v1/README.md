# Retained runtime06/07 emitter diagnostics

`PORTABLE.zip` retains the raw runtime06 stock-Bend process observation and the
runtime07 exact-source Bun phase profile, including their plans, receipts,
guards, output streams, observer/profile scripts, compiler snapshot, license,
instrumentation patch, and source maps. `MANIFEST.json` binds every archive
member to its original logical path, byte count, and SHA-256.

Both attempts are `INCOMPLETE`, diagnostic-only, and stopped at the existing
30-second source-emission deadline. Neither produced C; neither ran Clang or a
consumer. The runtime06 plan is the installed Bend 2.0.35 binary, hash-pinned
in its plan. Its observer’s first-to-last one-second samples cover 29.302310958
seconds and show a 29.07-second process CPU-tick delta, with maximum sampled
RSS of 3,660,964 KiB. This sampled interval omits startup and final sub-second
work; the observer adds small overhead and does not provide a phase breakdown.

Runtime07 profiles a private copy of official Bend source commit
`79df8d9c40722ee9507a1e253f283b51025f9d6c` under Bun 1.3.14. The archived plan
binds the 97-file upstream and copied-source inventories. Only `comp.ts` differs
from the upstream file, by the retained exact patch; the plan records both
hashes. Its 23,181-line JSONL contains monotonic source-emitter phase/body
records, not process CPU time. The Bun-based profile is a diagnostic of the
instrumented source and is not a measurement of the installed Bend binary.

These records explain the two bounded diagnostic attempts only. They do not
qualify feature behavior, performance, or an installed-compiler result. External
executables and dependencies remain hash-pinned in the plans; they are not
copied into this packet. Run `python3 verify.py` here to validate the retained
archive and its provenance joins without executing Bend, Bun, or a backend.
