# Simulation reader seam

`readers.bend` specializes the actual `event-runtime.bend` registration, run and disposal APIs for observation-only readers. The root simulation consumer supplies its nominal schema, arbitrary affine store/resource types, and merged `SimulationEvent` Data type; no World payload is copied or replaced here.

Register independent owners using `register(..., "Simulation/ReaderA")` and `register(..., "Simulation/ReaderB")`. Thread each returned owner into its next run. `Args{journal, fail}` contains the host/local observation journal and one invocation's failure flag. Every invoked runner appends the complete `ER.Reading{values,lagged}`. `ER.Succeeded{journal}` returns the new journal; `ER.Failed{ReaderFailed{journal}}` also returns the new journal. Feed that failed journal into the retry with `fail = False{}`. The actual `ER.run` advances cursors only on success, so the retry sees the same unread payloads. `ER.Rejected{args}` returns the untouched input arguments. Registration failure and disposal rejection retain all available owners.

The journal is an explicit Data fixture observation, not a persistent affine capture implementation or a decision about the unresolved general ownership policies in #50/#53. Event publication, frame maintenance, checkpoint formatting, and hit/death splitting belong to the actual consumer.

## Development evidence

`development/source-v1/` retains the unchanged five-second `scripts/bend-check readers.bend` output (`BEND_NO_TELEMETRY=1`, shared `/tmp/bendvy-parity-heavy.lock`). Exit 0, `ALL PROOFS CHECK`. This establishes source parsing/type/affine checking only. No new laws or proofs were introduced. The complete #63 application oracle, runtime execution, negatives, mutation and backend delivery gates remain consumer work; this seam does not complete #63.
