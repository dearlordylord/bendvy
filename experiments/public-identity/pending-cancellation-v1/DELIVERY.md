# Canonical pending-spawn cancellation

Own accepted deferred spawn → despawn now preserves FIFO population and cleanup.
Pending authority is separate from visible liveness; foreign and failed reserved
handles remain MissingEntity. Public constructors are unchanged. Abort clears
only newly acquired marks at the current grown capacity and preserves earlier
committed pending work. Components remain arbitrary affine Type payloads.

[Source contract](SOURCE-CONTRACT.md) follows Rust Bevy ad678262 before Bend
representation constraints; the earlier discovery and source README are retained
unchanged as historical preparation. [Adoption](ADOPTION.md) joins the exact
four promoted core bodies and reached imports without claiming a root replay.

| Executed subject | Complete bytes/backend | Retained packet |
| --- | ---: | --- |
| Direct/Batch/later-Tx cancellation; growth/abort | 22,406 | [Normal](runtime-v1/actual-attempt01/) |
| Reached live-only admission counter | 22,120; rejects normal | [Counter](live-only-mutant-v1/runtime-v1/actual-attempt01/) |
| Actual independent WorldIO foreign pending | 2,618 | [Foreign](foreign-pending-v1/runtime-v1/actual-attempt01/) |
| Both lifetime producers and live observed cleanup | 2,491 | [Scope](scope-compat-v1/runtime-v1/actual-attempt01/) |
| Existing AppA/AppB complete current observations | 47,464 /13,475 | [Applications](../../public-audit61/pending-metadata-current-v1/runtime-v1/) |

Every row passes stock Bend2.0.35 JS and ordinary Native-O3 through the existing
collector and unchanged limits, with independent full oracles and retained raw
outputs/guards. The counter executes pending `_with`; plain/observed pending
variants have source-composition applicability through the identical admission
helper and unchanged apply bodies, not three independently executed combinations.
Scope cleanup separately executes the live observed route. Opaque callbacks are
preserved and counted, never introspected; observations are finite, not proofs.

[Combined #28](../../integration-gates/combined-ordinary-app-v1/pending-cancellation-v1/actual-attempt01/)
passes unchanged default 20 balanced pairs/backend,123 commands and 110 complete
outputs. No confirmed regression against frozen Bend baseline327bec49d. Workshop
medians: JS 104.775ms, Native 27.632ms, bevy-ts 273.048ms (descriptive ratios 0.384/0.101).
These are this workload's observations, not full-product parity/performance.
No runner, numerical tolerance, law or compiler dependency changes are adopted.

Full #38 remains open for generation/reuse/exhaustion/domain policy and remaining
criterion reconciliation; full #61 and final #21/#23/#24 remain separate. Final
[independent review](FINAL-REVIEW.md) passes for this bounded delivery.
