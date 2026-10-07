# Capture iterator candidate

The full relation diagnostic attributes 37,958,888 of 38,008,088 sampled JS
iterator `next` bytes to `io_feature_capture` (99.87%). This candidate replaces
only the bytewise FNV for-of loop with indexed iteration, in both Bend JS capture
and TS capture. UTF-8 conversion, newline, digest operations, byte counts, chunk
retention, clock boundaries and output flush are unchanged.

Baseline copies and exact singleton deltas are bound in source-plan.json. This
is a harness allocation optimization, not an ECS speedup or Native repair.
Original timing helper files remain untouched. Qualification needs exact byte/
digest controls, unchanged complete application observations, and before/after
profiles. Any comparative timing needs a fresh frozen protocol and host window.

## Finite development controls

`controls.mjs` compares both helpers in both roles against independent complete
UTF-8 byte, count and FNV observations for five input sets: no chunks, empty text,
multiline text, NUL/Unicode/unpaired surrogate, and 4096 distinct code units.
The Bend helper executes in an IO-supplied VM; the TS helper executes its actual
async capture function. This is a finite harness control, not emitted application
execution or a universal equivalence proof. Timer elapsed values are deliberately
excluded from equality; Bend missing/nested timer refusal controls execute.

Source/tool/environment/raw-log-bound development receipt:
`.artifacts/capture-controls-1791386774130388257/receipt.json` — PREFLIGHT_PASS,
one owned five-second command, 20 complete comparisons. Independent review is
pending. The preceding attempt retained an INCOMPLETE receipt because the
expected-output file had not yet been created; no passing status is borrowed.
Neither original helper nor public ECS implementation changed. Full application
correctness and before/after allocation profiles are still required before adoption.
