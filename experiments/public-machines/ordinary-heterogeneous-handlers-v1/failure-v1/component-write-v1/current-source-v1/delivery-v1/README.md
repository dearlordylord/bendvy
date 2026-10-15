# Current-source component-write qualification

This bounded delivery covers the first-transition component-write consumer in this current-source fixture. JS and Native both match the full 24,422-byte independent oracle. The retained trace includes successful Exit writes, a tentative Transition write followed by callback failure and transaction rollback, retry, the second machine's writes, reader positions, component/resource state, and deferred-command application.

The oracle was derived from the frozen current-source closure and independently reproduces the complete historical `tracked-cursors-v2` output byte-for-byte. The retained adaptation diff distinguishes import-only fixture changes from the added `Initial` observation paths. This consumer does not execute those `Initial` paths, so the packet makes no initialization claim. It also makes no two-schema, component-undo mutant, performance, or full-issue acceptance claim.

The source checker passed with `ALL PROOFS CHECK`; its raw stdout/stderr, source freeze, adaptation diff, complete oracle inputs, runtime plans, receipts, generated sources, guards, and output streams are retained.

Run `python3 verify.py` for offline verification or `python3 verify.py --selftest` to also exercise exact-parent stream rejection and relocated-file drift detection.
