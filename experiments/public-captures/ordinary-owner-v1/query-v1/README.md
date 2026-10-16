# Ordinary captured query: first consumer

Additive `ordinary-capture-query` accepts the ordinary `Query.Declaration` and a
rank-2 body with an affine accumulator. It derives access metadata. The body
receives declared providers, capture, and arguments; no concrete World. The
implementation reuses Local ownership/refusal and transactional compose selectors;
a separate library-owned cursor advances only on success to returned World.clock.

The unchanged first consumer runs for Workshop and Garden through WorldIO:
register primary and genuine foreign twin; run empty; allocate three entities and
populate Value on IDs 1/2; fail on the second matching row after both writes;
retry; run with no changed rows; externally replace ID1 and run again; skip;
refuse a foreign run with a colliding valid registration; unregister both owners.
Each pack contains two affine arrays. Selection is ordinary Write + Changed.

Every checkpoint retains both complete capture trees and registration metadata,
query cursors, World namespace/allocator/live tree/capacity/depth/resource/events/
pending count/full registrations/next-system ID/clock, and all allocated payload
slots and lifecycle stamps (plus sentinel slot zero). Successful outputs and
failure variants are retained. Observers return owners unchanged. This is logical
and ownership-bearing state, not a universal private backing-layout equivalence.
The pending queue is never populated in this workload.

Frozen `SOURCE-FREEZE.json` contains 47 Bend bodies and two namespace sidecars.
Fold, entry and scenario checks pass within the existing five-second cap. Main
reports only six foreign-dependent IO definitions; its check is not labeled PASS.
The [retained packet](runtime-v1/README.md) contains the independent oracle
and complete stock JS/Native observations.

This is the first query consumer. The [App successor](app-v1/README.md)
qualifies independent query cursors and automatic debug bindings; authority-v1
retains the intended query refusals. The [TS packet](reference-delivery-v1/README.md)
records shared query behavior. Full #50 acceptance is tracked in the
[governing spec](../../../../docs/parity/captures.md).

Rollback here means component payloads and lifecycle stamps are restored. Existing
transaction semantics retain the advanced World clock; failure preserves the query
reader cursor. The observer records all three separately. Access metadata retains
both declaration clauses (`Value`, `Value`); it is not normalized by the fixture.
