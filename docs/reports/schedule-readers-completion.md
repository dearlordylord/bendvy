# #35 composed schedule readers — completion

The bounded executable reader slice is complete. Public schedules preserve
distinct event, lifecycle and removal cursor contracts through conditions,
transaction failure, retry and explicit structural barriers. This closes #35's
slice, not full parity or the product performance gates in #21/#23/#24.

## Acceptance evidence

Fresh command:

```sh
python3 experiments/public-schedule-readers/replay.py \
  --output .artifacts/schedule-readers-current-worldio-v1 --cpu 5
```

Terminal **PASS**: 99 supervised commands and 28 backend result rows. Receipt
SHA256 `ca2905320a5425fcdfb4f680f60be2808b9b706163b1cbcec05fc2e492d8f319`.
All 64 source hashes, exact 35-core-module inventory and 240 guarded artifacts
match. [Portable evidence](../../experiments/public-schedule-readers/evidence/worldio-current/receipt.json)
retains complete captures and a roundtrip-verified execution archive.

| Ticket criterion | Direct evidence |
| --- | --- |
| Composed fast/slow readers, conditions, prior commits, failing publisher/reader and retry | Actual pinned Node TS 25-checkpoint reference; complete JS/Native matches with all payload words and explicit barriers. |
| Skip/failure cursor separation and authoritative own-write consumption | Event skip discards backlog; removal/change skips retain visibility; failed readers retry; own-write success consumes post-run clock. Four actual TS Added/Changed checkpoints and reached wrong-advancement/own-write controls. |
| Independent registration/lifecycle, lag and retention, preserved earlier work | Five scoped control families cover ownership transport, disposal/re-registration, mixed recovery, added visibility and ordinary/removal partition. Complete retention/lag observations include the 65,535-publication batch and older pending commands surviving failure. |
| Meaningful defects and component/resource ownership | Seven compiling semantic mutants detected on both backends, plus four intended access/schema/read-write/affine negatives. Actual Array payloads and resources remain owned and returned. |

Pinned TS has no public per-reader disposal API. Bend disposal/re-registration
is explicitly a stronger scoped lifecycle control, not paired TS disposal parity.
Foreign-world controls are adversarial refusal cases, not alternative reference
success traces. Trusted declarations remain a provisioning boundary.

## Performance and review

The unchanged #28 gate passes on the same current 35-module inventory; see
[canonical creator regression](world-io-regression.md). Its legacy Workshop
subject is separate from the composed-reader application.

The retained complete reader feature observations contain 120 balanced pairs,
20 per backend at one, two and four full lifecycles. JS/TS medians remain
approximately 3.80–4.11; Native/TS approximately 1.13–2.02. These are substantial
product performance deficits, not speed acceptance. The feature archive retains
its earlier exact 33-module executed scope; the four additive WorldIO files are
unimported there, all 33 executed core hashes still match, and changed unrelated
nested-provision reporting/runner files are not represented as current inputs.
No timings were rerun merely to update documentation. Full numerical targets
and connected qualification remain open in #21/#23/#24 as the ticket specifies.

Independent final Spec/Standards inspection reconciles the fresh source,
artifact and acceptance coverage; see [review](../reviews/schedule-readers-delivery-final.md).
The reviewer inspected evidence and source without claiming another backend run.
Bend 2.0.35, Node 24.20.0 and the approved private Clang19 remain pinned; limits
are checker/runtime 5 seconds, emission 30, compilation 120; Native one thread,
GPU disabled. No dependencies, baseline, numerical tolerance or law approval
changed. Finite traces are not universal Type refinement or ECS proofs.
