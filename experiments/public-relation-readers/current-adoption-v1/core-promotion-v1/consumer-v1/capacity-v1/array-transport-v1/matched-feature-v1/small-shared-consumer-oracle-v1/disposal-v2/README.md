# Provider-disposal oracle, current source snapshot

This source-derived successor corrects the tracked run epochs and read cursors
in the historical v1 disposal observation. It is bound to all 63 files listed
by `SOURCE-PINS.json`; v1's generator and expected bytes remain separately
pinned and unchanged. No runtime output or receipt was consulted to derive the
current expected stream.

The initial World and route/failure state start at zero. `before_attempt`
selects `max(1, routeTick, failureTick, World.clock)`, ingests that epoch into
both route and failure state, advances the World clock once, and increments
the route tick once. The successful post-processing ingests the resulting
route tick without another World clock advance. Thus A's post-run state is
World clock 1, route/failure tick 2; B's is World clock 2, route/failure tick
3. The successful System cursors track the World clocks, so A is 1 and B is 2.

Stream registration allocates reader IDs but leaves the initially empty
position list untouched. Event preparation passes `routeTick - 1` to
`Stream.completed(False)`, which subtracts once more when creating a missing
position. A therefore has event positions `(id 2/1, cursor 1, registeredAt 0)`;
B has `(id 4/3, cursor 2, registeredAt 1)`. Relation preparation instead
activates at the current failure tick directly, yielding A `(id 1, cursor 1,
registeredAt 1)` and B `(id 2, cursor 2, registeredAt 2)`. Existing positions
are preserved by activation, and successful commit advances only their
cursors.

The foreign context remains the fixture's trusted seeded `W.Factory{2}`
context, not an ordinary `WorldIO`-origin context. This model covers only the
pinned A/B successful run and disposal observations; it does not qualify
ordinary WorldIO provenance or broader lifecycle behavior.

Run the deterministic source and model checks with:

```sh
python3 selftest.py
```

To verify the preserved immutable source snapshot elsewhere, pass its root:

```sh
python3 selftest.py --source-root /tmp/bendvy43-disposal-after-source01
```
