# Family reader authority controls

Frozen dependency base: `21ddb0860`. Pinned stock checker, 5-second cap, CPU 5. Two positives exit 0; nine intended negatives exit 1. Complete commands, raw diagnostics, source/tool hashes and dependency inventory are in `CHECKS.json` and `checks/`. No backend execution.

`positive.bend` calls the retained ordinary fixture `run_a`, which invokes canonical `ordinary-owned-event-family-reader.run`, with affine `Payload.Args` containing an Array. `positive-scoped.bend` registers a concrete valid rank-2 scoped callback through the canonical `O.register` and derived `Schema.a_setup`.

The three duplicate controls consume the actual reader, Registry or Args both at `run_a` and in its result. `cross-schema` sends a B runtime to the actual A run. `wrong-family-reader` passes the B selected-stream Reader to actual A run while both leaf payloads are Array<U32>; its rejection is the static FR.take/put selection index, not a metadata-name mismatch.

The four scoped controls bind the callback at actual canonical registration: opaque H cannot be used as World or Array payload; Unit cannot replace the declared affine Request; a Projection grant cannot be reused as a U32 grant. Each final diagnostic rejects the intended expression. The otherwise identical valid scoped callback passes. Preliminary draft alias errors remain separately under `checks/draft01`.

These checks bound ordinary typed entry use. Raw Setup, selectors, Frame/provider callbacks and administrative constructors remain trusted; this does not claim module privacy, universal provider purity, runtime foreign-namespace refusal, or alias rollback.
