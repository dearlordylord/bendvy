# Supplementary internal C3 retention diagnostic

**PASS: five fresh invocations**, each bounded to five seconds. This is the
explicitly named small-capacity supplement in the [E11 trace](../../docs/design/s-integrate-trace.md),
separate from the [public 65536-capacity execution](retention-README.md).
It contributes **no public capacity configurability or dispatcher coverage**.

```sh
node experiments/s-integrate-trace/reference-retention-internal.mjs --all
# Individual replay (JSON status/firstDifference is authoritative):
timeout 5s node experiments/s-integrate-trace/reference-retention-internal.mjs Health despawned
```

The runner pins the actual reference commit against the tracked manifest,
records Node/source/adapter/trace hashes and executes five sequential children
with `execFileSync(timeout:5000)`. Each complete child invocation includes
imports, source-pin checking, operations, every comparison and serialization.
Recorded wall times were 120–149ms. `--all` exits nonzero if any recorded lane
fails or times out; no failed/unresolved case remains. Cleanup can affect only
its own timed child. No dependency, reference, runtime, Bend or Tower Defense
source was changed.

| Internal API and exact input | Observed and checked |
| --- | --- |
| `Streams.make(3)`, two registered holders at stream boundary0; append [1,2]@1 and [3,4]@3, trim0 | Both values of retained [3,4] match. Old cursor0 is lagged; cursor2 is not. Repeating the old cursor read preserves the same values/lag. |
| Append oversized [5,6,7,8]@5 to that stream, trim0 | All values drop; old boundaries0,2,4 see []/lag=true; registeredAt5 sees []/lag=false. |
| `Streams.make(0)`, holder0, append [1]@1, trim0 | []/lag=true. |
| `makeWorld(schema,3)`, Motion then Health, removal and despawn separately | Four IDs are actually allocated, not fabricated: raw1,2,3,4. Full schema Main seed values are checked; four deletions share actual tick3. Before trim, every removal is present; despawn also reports all four despawns. |
| Two `World.advanceFrame()` calls with lifecycle reader lastRun0 held | Retain raw2,3,4 despite the holder. Removed lag=true; despawn lane also has despawn lag=true. Repeating boundary0 sees exactly the same records. Boundary3 sees []/not lagged; registeredAt3 at boundary0 sees retained records without historical lag. Holder remains at0. |

Motion Main is Position with all four coordinates and frame7; Health Main is
Vitals with all four levels, reserve9 and class2. These diagnostics use internal
world allocation/spawn/removal/destruction directly, internal raw records for
seed inspection, and internal `removedSince/despawnedSince/*Lagged` methods.
Their provenance is recorded alongside every operation/read in
[internal-retention-evidence.json](internal-retention-evidence.json).
All actual small sequences are stored fully and deeply compared in order.

A repeated internal cursor read is **not** an actual failed dispatched system
or proof of transaction rollback; the separate public E11 runner supplies those
real failure/retry controls. Internal lifecycle lag methods likewise do not create
a public system `lagged()` API. This diagnostic establishes only pinned internal
batch-versus-record trimming behavior at C3/C0; it selects no production capacity,
retention policy, layout or universal runtime law.
