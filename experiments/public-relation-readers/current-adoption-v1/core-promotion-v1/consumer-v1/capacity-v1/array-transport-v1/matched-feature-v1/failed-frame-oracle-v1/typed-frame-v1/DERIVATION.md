# Typed plus keyed frames: independent applicability and isolated event mutant

The ordinary consumer is the integration worktree's
`ordinary-failed-typed-frame-consumer.bend`, SHA256
`d831ca2768aaaa67193792b9f7a275c245d2ec4fcd1fdc82d250f98ab981bc20`.
This leaf was derived from its actual source and the patched helper source;
no runtime stdout, generated JS/C, or backend receipts were consulted. Existing
parent and sibling model artifacts remain unchanged.

Complete accepted output:5320 bytes, SHA256
`5ca28434e0b92396ba05496fea0e6fbec1ff9d87ba734aec1c60f359a1bb988f`.
Complete rejected event-only mutant prediction:5210 bytes, SHA256
`8f42ef1f75ae3b401ffd068d4e1d0bdd2fc71450b56d20602ba9afbade240e0c`.
Both are complete JSON objects followed by one LF. Matching the parent's accepted
hash follows the independently calculated operation/serialization projection;
it was not assumed from the previous output.

## Actual typed-frame semantics

The source imports the actual scheduled Core consumer and uses the same setup,
real Writable self-relation transaction, discarded Failure77 transaction, actual
World barrier, first failed A callback, two frames, and successful retry as the
parent witness. Its significant new operations are `typed_frame`,
`keep_publications`, and `frame_both`.

`typed_frame` calls actual `event-stream.bend` `Leaf.frame`. `frame_both` passes
that function and `keep_publications` to `Mixed.frame`, then calls
`Mixed.frame_failures`. The typed and keyed runtime clocks have separate frame
boundaries: the typed frame uses routeTick2, whereas the keyed frame uses its
failure tick1. Neither frame advances a clock or consumes a callback cursor.

The pinned patched `ordinary-reader-stream-parameter.bend` `event_prepared`
snapshots the reading, then returns the real stream through
`Stream.completed(stream,id,Nat.sub(routeTick,1),False{})`. The source's
`event-stream.bend` `completed_positions(False)` calls
`Ev.activate(positions,id,Nat.sub(readThrough,1))`. First prepare occurs at
routeTick2, so each event owner activates unread cursor0 with registeredAt0.
Left-to-right pair preparation activates ID1 then ID2, producing physical order
`[(2,0,0),(1,0,0)]`. No callback success is needed for activation, and callback
failure7 consumes no position. This is the existing first-valid-failed-run
retention contract in `docs/design/public-event-readers.md` and dispatcher
begin/failure hooks in `docs/design/s-integrate-reader-implementation.md`.

Initial ingestion stamps the actual original Value11 into typed batch1. The
first `Leaf.frame` uses old frameStart0 and hold=min(0,0,0)=0; it retains batch1,
sets typed frameStart2, boundary0. The second frame uses old frameStart2 and
hold=min(2,0,0)=0, retaining batch1 again; it sets frameStart2/boundary2.
No capacity enforcement removes anything (one value is below65536). Dropped0,
leaf positions and payload publication order are preserved.

`Mixed.frame` calls the source retention callback once per original publication.
`keep_publications` returns every publication and the actual family unchanged.
`retention`, `retained_records`, `kept_batch` and `rebuilt` reconstruct the same
original Value11 and Removed(entity1,value) journal and actual World log in their
original order, including the removal even though only Value was forwarded to
the event stream. No re-ingestion duplicate occurs on retry. The typed family
frameStart becomes2; this administrative metadata is preserved internally.

The independent keyed activation remains descriptor1/readers[1], position
`(1,0,1)` after failure. Its first/second frames retain the one complete error in
queue front batch1, set failure frameStart1, and exposed boundary0 then1. Retry
therefore returns the complete same five-part Data product as the first failed
callback: query entity1/null; eventA and eventB each one full original Value11;
one full removal; keyed relation1 one full self-relation failure. All lag flags
are false. Callback success changes leaf positions to `[(2,2,0),(1,2,0)]`, keyed
position `(1,2,1)`, removal count2, provider query cursor2. Route/failure tick3,
World clock2; complete World events remain the two originals and graph remains
empty. No new callback or namespace is introduced.

## Why complete stdout is unchanged

The actual serializer was inspected in full. `snapshot_state` still emits only
`FailureImage` and Core `WorldObservation`; it does not include typed stream
positions, typed frameStart, boundary or dropped counters. The failure image's
routeTick/tick/frameStart/boundary/capacity/nextReader/positions/domains fields
are unchanged, as are World namespace/clock/pending/graph/events. `frame_record`
has view null for each frame. The actual callback view arrays retain their values
under the correct activation transition. Thus every observable field, key order,
array order and phase label is equal to the independently derived original
failed-keyed-frame expectation. The renderer adds no invented typed metadata.
Installed Base and both print effects specify the final one LF.

## Exact isolated event-only mutant

The counterfactual removes only the newly added `Stream.completed(...False{})`
application from `event_prepared`: it returns the prepared original `stream`
through `Mixed.put`, retaining the new keyed `KRead.activate` and `Ev.activate`
code. It changes no commit function, serializer, frame function, capacity or
publication callback. This is a prediction; this oracle neither edits a helper
nor generates or executes a mutant.

First-failed event readings are still complete, but no leaf position survives
that failure. Frame1 retains batch1 at old frameStart0 and sets frameStart2.
Frame2 has no leaf holders, so hold2 removes batch1 and records dropped1.
The keyed holder still retains its complete batch. Retry cannot republish the
message from journal: keep_publications retained it, and synchronization drops
the already-journalled originals. Each event reading is therefore empty. Its
missing-position fallback has registeredAt=routeTick3, so lag remains false
(`max(0,3) < dropped1` is false). The full keyed failure and removal remain,
query remains entity1/null, and every serialized shared/World field is unchanged.
Success creates leaf positions `[(2,2,1),(1,2,1)]`, but the serializer excludes them.

The self-test asserts the full mutant JSON equals accepted JSON with exactly
both retry event values arrays replaced by empty arrays. No other observable
change is permitted, including lag, physical failure metadata, World event/order,
provider cursor, graph, clocks, or full relation error. The mutant prediction is
rejected diagnostic output, never an accepted expected artifact.

## Pins and checks

`source-pins.json` binds64 actual recursively imported Bend source bodies,
installed Base plus its two print effects, and both existing contract references:
69 files total. In particular it binds the exact entrypoint, helper,
`Leaf.frame`/`completed_positions`, `Mixed.frame`/retention/rebuild, keyed frame
and queues, Core serializers and real transaction/barrier/provider sources.
`derive.py` models both typed and keyed state explicitly; it does not read the
parent's expected bytes or invoke any backend. The model is a local derivative
of the already source-derived parent computation, with typed state/frames and
the isolated event mutation independently added from these actual bodies.

`python3 derive.py` verifies all pins, exact full accepted and counterfactual
artifacts, unread positions and holder ordering, belowcapacity holds, typed
frame boundaries, journal/order preservation, separate clocks, successful cursor
updates, complete first-failure/retry equality, false lag without drops, keyed
retention under the event-only mutant, silent typed loss under that mutant, and
strict two-array-only observed divergence. Python source checks pass.

This establishes source-only applicability and an isolated mutation prediction.
Backend qualification, other schedule forms, overflow, cleanup/disposal,
performance, and combined regression remain separate. No contract, law, numeric
limit, dependency, runtime flag or compiler change is proposed.
