# TS graph restore scheduling successor

The original source/expected commit f7dcac04606df8f7d2369f8452f55c69a91504fb remains unchanged. Actual01 failed before stdout with `Duplicate system step in schedule: fast`. Its original INCOMPLETE receipt and raw streams are retained in `history/`; no expected-output comparison passed in that attempt.

The sole consumer change places each step in its own ordinary Schedule and passes those schedules together to the SAME `Runtime.tick`. Pinned Schedule.ts validates duplicate system identities within each Schedule; Runtime.ts tickUnsafe advances the frame once, then executes the supplied schedules in order. Thus all callbacks, boundaries and state operations occur in exactly the original order and frame. No schedule labels or profiling trace are observed. The complete source-derived Python oracle and expected 21374 bytes remain BYTE-IDENTICAL, independently justified by this source path rather than fitted to actual output (actual01 stdout is empty).

The existing reference-v1 runner is byte-identical and uses the same pinned Node, CPU5/cap5 and shared lock. Source/expected bindings are frozen in SOURCE-BASIS.json and plan.json before execution. Fresh output directory is `/tmp/bendvy60-graph-reference-actual02`.

Scope remains third-reference successful ordered Link/Parent and committed Mode restore, omitted Weather/Spare, clearing real queues and retained readers, then machine/resource omission. Full snapshots/debug dumps/stream statuses and all callback payload histories are compared. TS numeric IDs/stale aliases do not approve Bend fresh full-key identity; finite Weather vocabulary is not Bend legacy decoding; no affine undo/owner equivalence, staged room refusal, parser rejection matrix or full #60 claim follows.
