# T07 — bounded buffered-event reader probe

[Issue #8](https://github.com/dearlordylord/bendvy/issues/8), [SPEC](../../docs/SPEC.md).

Two independently stored reader cursors observe one Ping stream at different
rates. Each World/Log is affine Type; immutable batch payloads/cursor projections
are Data. Successful completion advances only the selected cursor; failure leaves
it unchanged; a registered skipped reader discards publications through current
tick. Emission stages a batch and publishes it only on success, without a
structural barrier. This is an executable one-stream/two-reader prototype.

The frame wrapper models explicit start/current/previous-frame retention and
system/publication ticks. Its tests compare actual public bevy-ts systems for
reader independence, retry, failure emission, state-conditioned skip and holding
messages across empty schedules. Observations are compared in exact order.

Capacity boundaries separately execute pinned `internal/streams.ts` at 3 and 0.
The public runtime's capacity remains 65,536; no adapter changes it. Capacity drops
whole oldest batches, so an oversized batch can disappear entirely. Lag compares
droppedThrough with both cursor and registration time; a new reader is not marked
lagged for drops preceding its registration.

## Reproduce and evidence boundaries

```
python3 experiments/t07/run.py
# Optional Linux affinity:
BENDVY_CPU=11 python3 experiments/t07/run.py
```

Twenty-four ordered observations: 12 public two-reader scenarios, 4 public
retention/new-reader scenarios, 8 internal small-capacity observations. Native and
JS execute the same Bend definitions and compare against freshly executed TS.
Compiling mutants cover global consumption, failed cursor advancement, skipped
backlog preservation, missing capacity, ignored registration and ignored holders.

Bend 2.0.34 / pinned Base, clang 14.0.6 -O3, Node 24.20.0. Checker/runtime limits
remain five seconds; code generation/clang have separate bounded build budgets.
No proof, public-runtime configurable-capacity claim or performance acceptance.
See [CANDIDATE-LAWS](CANDIDATE-LAWS.md).

## Remaining obligations

General keyed streams, reader lifecycles/destruction, opaque reader declarations,
Type payload projections, captured callbacks and integrated T09 schedules remain
production API work. The World wrapper has two reader slots; `Log.trim` accepts a
general list of cursors. Event payload here is U32; this does not adopt Data-only
components or resolve generic noncopyable message fan-out. Clocks use bounded U32
values under a no-wrap precondition; production exhaustion/epoch policy remains
required. No change/lifecycle reader contract is inferred from message skip rules.
Retained immutable lists and their traversal/refcount costs must be measured;
this probe is not the selected scalable storage layout or universal refinement.
