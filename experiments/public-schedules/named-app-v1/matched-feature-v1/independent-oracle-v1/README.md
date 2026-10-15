# Matched named-plan independent oracle v1 (final source freeze)

This source-only oracle follows the frozen `matched-feature-v1` entrypoint and
its final 64-file Bend closure plus 34-file TypeScript reference closure, pinned
by freeze `646e6d3e703c726bcd4e871cd39f12b70cf4a263782af1c4047125068ad33434`.
It models
`main.bend`'s four fresh scenes in order (`Workshop` and `Garden`, debug off and
on), all 26 action records in each scene, and scales 1, 2, and 4.  The model
keeps the complete shared record: insertion/replacement/refusal, run outcomes,
local memory counters, resource mode value, retained named plans, enabled
schedule descriptions, and plan-selected grouped Counter readers/writers.

`model.py.source` is a finite source-derived interpreter.  Its Counter field is
projected through the final observer's ordinary `F.observe` DTO path.  It never
invokes a backend and never reads runtime output.  `expected-scale-{1,2,4}.stdout` are
compact UTF-8 JSON returned by `run(N)` followed by the one terminal LF added
by the pinned `IO.print` effect; deterministic gzip companions are provided.
The final TypeScript reference retains complete invalid-plan constructor
sequences; those refusals have the same shared logical record as the Bend
model.  The TypeScript reference is pinned as a source cross-check, while physical
WorldIO/Runtime owner and cursor behavior remains explicitly backend-specific.
