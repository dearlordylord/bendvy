# #42 independent IO-authority oracle

This leaf is a source-derived finite oracle. It was generated from the current
`consumer.bend`, `main.bend`, and `render.bend`, the copied
`mutation-composition-v1` fixture/operation/consumer, and the pinned ECS
world, namespace, system, transaction, relation, event, and failure modules.
The oracle does not invoke Bend, a compiler, a generated backend, or a runtime
and does not read candidate output.

`main.bend` executes Workshop and Garden in one process. The host namespace
allocator starts at 1 and is shared across the nominal schemas, so the outer
WorldIO handles are `(1,1)/(2,1)` for Workshop and `(3,1)/(4,1)` for Garden.
Each created world is seeded with IDs 1, 2, and 3. The full report keeps the
seven checkpoints, four writer results, zero query results, and one delivery
result for each schema.

The copied mutation consumer has a source-visible binding that controls the
receiver state: `mutation-composition-v1/consumer.bend:start` calls
`F.fixture(~S,1)` and `writer_registered` receives that fixture. The reported
outer handles and canonical foreign snapshots still come from the two
WorldIO-created worlds. The static receiver fixture is therefore namespace 1
for both reports. The queue namespace gate rejects every request because each
request contains a handle from a different namespace pair; each result is
`MissingEntity`, with no staged graph, event, domain, or writer command.

The fixture's pending `tick` closure is retained through the four writes. The
deferred barrier advances the world clock to 18, then drains that closure and
advances the physical world clock to 19 while retaining runtime tick 18. The
tracked failure-reader delivery advances the world to 20, yields the missing
Parent reading `Reading{Key{2},[],False}`, creates `Position{4,20,18}`, and
updates the failure reader cursor to 20. The five pre-barrier snapshots retain
`pending=1`; the barrier and final snapshots have `pending=0`. The writer
cursor advances through the four successful tracked runs, while the inverse
cursor remains zero.

`expected.stdout` contains the two explicit `IO.print` lines rendered by
`render.bend`, and `expected.stdout.gz` is deterministic gzip with `mtime=0`.
No actual stdout, historical output, or runtime measurement was used to fit
these bytes. If the owner changes the copied consumer binding or any pinned
source, this oracle must be regenerated and reviewed rather than reused.
