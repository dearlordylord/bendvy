# #31 — Public event readers

Implementation and task-local executable gates pass. Integrator delivery still
requires the unchanged #28 Workshop regression gate, independent Standards/Spec
reviews, commit/push and issue reporting. No full-core or product-speed acceptance
is claimed here.

## Delivered behavior

The additive event Runtime owns one actual World/event domain and stamps committed
publication batches through registered execution. Read gameplay receives abstract
owner/read capabilities; publication gameplay receives write capabilities and
stages through actual Transaction.finish. Failed publication is absent, failed
reads keep positions, successful reads advance independently, and condition skip
discards backlog. Reader retention begins on its first actual valid run, matching
pinned TS lazy registration; a rejected run creates no retention holder.

Frame cleanup observes every active cursor, then enforces the actual TS65536-entry
capacity by dropping whole batches. Oversized batches and missed messages report
lag using both the reader cursor and its registration tick. Actual World payloads
are retained and projected, not substituted by counts or checksums. World append
now uses order-preserving tail traversal: the previous Base append/length path
exhausted the JS machine stack on65535 values; no compiler/runtime patch was made.

Exact-registration disposal consumes its owner, removes only that reader's hold,
and leaves another reader's10/11 backlog available. Swapping registrations with
the same closed callback rejects and preserves arguments. Per-system disposal is
a Bend lifecycle extension: pinned TS public Runtime has no such method.

## Evidence

Command: `python3 experiments/public-event-readers/build.py --output /tmp/events31-final-build-r4`.
Checker5, emission30, approved private Clang19 build120, runtime5 second limits.
Bend2.0.35, Node24.20.0 and reference commits match the tracked source manifest.
[Receipt](../../experiments/public-event-readers/evidence/receipt.json) binds the
complete staged core/fixtures, commands, generated artifacts and observations.

- JS and Native each match all18 ordinary and7 late-first-run pinned TS
  checkpoints, three complete repetitions per fixture/backend. Retained65535,
  65537 and overflow survivor values are compared in full.
- All36 ordinary/reference/mutation outputs are retained losslessly with gzip;
  source-bound rejected diagnostics are also retained.
- Separate disposal and registration-swap controls pass on both backends.
- Four event read/write/access/schema/affine-owner controls reject for their
  intended reasons. Existing ten public component/query controls pass against
  the same frozen core; this does not establish universal authority protection.
- Dropped-publication, failed-read advancement and ignore-reader retention
  mutations all check, emit and execute on both backends, then differ from the
  full original checkpoints. They are finite executable controls, not proofs.

## Performance and limits

Three whole-process observations per backend include startup and full JSON
serialization, including actual capacity-sized payload lists. Ordinary trace raw
medians: TS109.7ms, JS89.8ms, Native42.4ms. Late-first-run raw medians:
TS93.1ms, JS50.5ms, Native14.5ms. Concurrent load is uncontrolled; these raw
feature diagnostics are not statistical qualification or a new speed threshold.
The integrator must record the unchanged paired Workshop regression separately.
Full matrix and product targets remain with #21/#23/#24.

Only Data event fan-out is implemented; arbitrary affine component payloads remain
supported. Affine event fan-out is unresolved full-core work, not a final Data-only
restriction. Publishers must use the runtime's World bridge for exactly-once batch
stamping; direct out-of-band World mutation is unsupported. Mixed removal/event
logs require independent retention owners because their skip semantics differ.
Universal refinement, proofs, full connected parity and production adoption are
not established by these finite source-bound gates.

## Independent integrated replay

Root replay PASS: all 25 complete reference checkpoints, two extensions, four intended negatives and three compiling mutants on both backends. Source-current receipt and lossless observations: `experiments/public-event-readers/evidence/root/receipt.json`. The relative output-path defect is fixed. Performance and delivery remain separate.

## Root shared-live source replay

Fresh root verification passes25 complete pinned TS observations, both Array boundary extensions, four task negatives plus ten prior public controls, and three reached compiling mutants on JS/Native. Receipt/full observations are retained in `experiments/public-event-readers/evidence/root-current/receipt.json`. Recorded whole-process timing remains informational; full qualification, shared regression and final delivery are pending. This receipt is for Column869091a8/Component0e41557c, after the README skip correction.


## Current shared-source replay — 2026-10-07

Fresh root replay passes on Column `3fec368b`, captured-column `340efc23` and indexed-lifecycle `e997f3b0`: 18 main plus 7 late-registration checkpoints; disposal and registration-swap extensions; publication, cursor and retention mutations. Source-bound receipts, full observations and retention hashes are in `experiments/public-event-readers/evidence/indexed-core-current/`. Five complete feature timing observations per backend are retained in `evidence/indexed-core-timing-v2/`; they include process startup/output and do not qualify hot-path performance. Historical receipts remain historical.

Independent final Spec and Standards reviews identify no blocking bounded-feature functional defect. The unchanged default #28 gate passes on the current core; all recorded source hashes match. The additional prepared-provider gate remains failed for #30 and is not this ticket's shared regression requirement. Commit/push and governing issue reporting remain pending; this update does not close the issue or parent qualification tasks.
