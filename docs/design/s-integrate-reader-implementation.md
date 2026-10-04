# S-INTEGRATE reader module contract

Implementation proposal for [#19](../tickets/18-integrated-runtime.md), the
[shared contracts](s-integrate-contracts.md), and [E6–E11](s-integrate-trace.md).
No runtime code, new law, proof, dependency or performance acceptance is delivered.
Source inspection uses bevy-ts `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`, verified
against `.references/sources.json` and the actual checkout. Existing public
[E11 execution](../../experiments/s-integrate-trace/retention-README.md) supplies
reference observations; this note adds no fresh TS or Bend execution result.

## Shared records to freeze

These are concrete field/kind requirements; final Bend declarations and signatures
must pass their own interface checker before implementation. `Tick` and counts
use bounded U32 with checked increments/additions, not unary Nat. Instance keys
come from actual system construction; gated/nested copies retain the base key.
Each runtime world owns a separate registry and logs, including same-schema worlds.
Schema-specific entity handles below are durable Data identities issued by the
actual world/factory; they are distinct from affine provider/cell access handles.

| Record | Kind and exact fields |
| --- | --- |
| `Clock` | Data `{tick:U32, frameStart:U32, retainedAfter:U32, frameNo:U32}`, initially zero |
| `ReaderState` | Data `{registeredAt:U32, lastRun:U32, streamLastRun:U32}` |
| `ReadInterests` | Data: schema-specific Ping key(s), removed-component keys, despawn Bool; derived from actual declarations |
| `ReaderSlot` | Data `{base:BaseInstanceId, interests:ReadInterests, state:ReaderState}` |
| `Readers` | Type `{slots:List<&2,ReaderSlot>}`; dynamic registry, not Fast/B/Late constants |
| `ReadBoundary` | Shared Data `{since:U32, streamSince:U32, thisRun:U32}` |
| `RunRead` | Private Data `{base:BaseInstanceId, registeredAt:U32, boundary:ReadBoundary}` |
| `Marks` | Data `{addedAt:Maybe<&2,U32>, changedAt:Maybe<&2,U32>}` per live component; `None` means unmarked |
| `MotionBatch` | Data `{tick:U32, count:U32, values:List<&2,MotionPing>}`; count comes from actual emitted values |
| `MotionLifeEntry` | Data `{tick:U32, entity:MotionEntity}`; no removed payload owner |
| `MotionPingLog` | Type `{capacity:U32, size:U32, droppedThrough:U32, front:List<&2,MotionBatch>, rear:List<&2,MotionBatch>}` |
| `MotionLifeLog` | Type `{capacity:U32, size:U32, droppedThrough:U32, front:List<&2,MotionLifeEntry>, rear:List<&2,MotionLifeEntry>}` |

Health has separately nominal `HealthPing`, `HealthEntity`, batch and log records,
with the same algorithms. Maintain one removal log per actual component key and
one despawn log per world, independently of Ping. A trusted generic FIFO helper
may share code; it must not erase schema distinctions. Registry lookup is by the
real base key, not display name, current schedule nesting, capture count or a
caller-selected Fast/B flag. Snapshot has no stream/lifecycle interests and holds
none of these logs. [Source: reader identity/registration](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/Runtime.ts#L1344).

## Dispatcher and transaction hooks

The following are trusted adapter interfaces; callbacks receive declared views,
not these registry/log constructors. Every Type parameter returns its actual owner.
Boundary field names below refer to `RunRead.boundary`; retain the shared
`ReaderState`/`ReadBoundary` records already proposed by the interface worker.

| Hook shape | Required transition |
| --- | --- |
| `begin(Readers, base, interests, Clock) -> Readers & (Clock & RunRead)` | After conditions pass, create missing slot with `registeredAt=old tick`, saved positions0; attach holders only to declared keys. Snapshot `since=lastRun`, `streamSince=streamLastRun`. Advance tick once and save it as `thisRun`; begin transaction. Registration survives a failed first invocation. |
| `success(Readers, RunRead) -> Readers` | Update only this base slot: both saved positions become `thisRun`. Others and `registeredAt` remain unchanged. |
| `failure(Readers, RunRead) -> Readers` | Do not advance saved positions or remove registration. Retry uses the identical actual base instance. The clock and lexical capture are not rewound. |
| `skip(Readers, base, now) -> Readers` | If registered, set only `streamLastRun=now`; otherwise leave absent. No registration, callback, capture increment, transaction or system-tick increment. The enclosing frame already began. |
| `read_ping(Log, RunRead) -> Log & EventRead` | Return actual retained values with batch tick `> streamSince`, in publication order, and event-view lag. Reads do not complete or consume another reader. |
| `read_removed/despawned(Log, RunRead) -> Log & List<Entity>` | Return actual entries with tick `> since`, preserving append order and duplicates. Retain identities after row deletion. |
| `inspect_missed(Logs, interests, RunRead) -> Logs & MissedReads` | Derive removal/despawn lag for the selected invocation from actual logs. Passive diagnostic; no callback, registration or completion. |

On successful transaction finish: commit recoverable writes; stamp changed marks
at the current run tick; if any Ping values were staged, advance tick once and
append **one batch per key** at that publication tick; complete the reader at
`thisRun`, not the newer publication tick; then enqueue committed commands. Thus an emitter's
next run sees its own published event, but not its own same-run changed stamp.
On failure restore recoverable writes and discard staged commands/events; publish
no failed marks. Preserve A's earlier marks, B's previous reader positions and
both instances' actual captures. Diagnostic missed reads use the invocation's
saved boundaries, including failed invocations; they are recorded before reader
completion. [Source: transaction publication](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/Runtime.ts#L1010),
[dispatch completion](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/Runtime.ts#L1382),
[missed-read provenance](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/Runtime.ts#L1249).

Structural D/T apply hooks advance the real clock according to the dispatcher;
D advances once even when empty. FIFO insertion into an absent component stamps
both added/changed; overwrite stamps changed only. Removal appends only if present;
despawn appends removals for each still-present component, then its despawn record.
Repeated no-op deletion adds nothing. Dispose payload owners through storage;
logs keep only actual identity/tick. [Source: marks](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/internal/world.ts#L453),
[despawn](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/internal/world.ts#L630).

Added/changed queries scan current live membership and test the corresponding
persistent mark `> since`, returning current complete payload projections and their
owners in ascending logical ID order. A sparse candidate index is optional; when
its coverage no longer reaches `since`, fall back to that scan. Frame expiry must
not erase surviving component marks. Transaction setters defer changed publication
until success; failure cannot leave B-only false marks. [Source: mark commit](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/internal/world.ts#L365),
[query fallback contract](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/internal/world.ts#L830).

## Frame retention and capacity65536

At each real runtime tick, including an empty schedule, increment frameNo. Using
**old** frameStart: if it is positive, trim lifecycle logs and expire sparse change
candidates at that boundary, then set retainedAfter=old frameStart. Set
frameStart=current tick. Always trim message logs at returned retainedAfter, even
when that value is0. Do not advance the change tick merely for a frame. Therefore
capacity enforcement occurs at frame start, not append/commit: Fast can read all
C+1 same-tick removals in `Delete,D,Fast` before the next frame trims one.
[Source: world frame](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/internal/world.ts#L685),
[runtime frame](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/Runtime.ts#L1641).

For each key, derive holder positions from its registered ReaderSlots at trim time;
do not cache stale copies when success/skip updates the registry. Compute
`boundary=min(window, holder positions)`; use streamLastRun for Ping and lastRun
for removed/despawned. With no holders use window. Drop front entries at or before
boundary, then enforce capacity regardless of holders:

- Ping: drop whole oldest batches until cached total **value count** is <=C.
  An oversized single batch disappears whole; never keep its last C values.
- Lifecycle: drop exactly `size-C` oldest individual records. Same-tick groups may
  split; do not deduplicate IDs or sort command order.
- Every actual drop advances droppedThrough to the maximum removed tick.
  Lag is strictly `droppedThrough > max(saved boundary, registeredAt)`.
  Registration affects lag, **not** read filtering or the holder minimum: a late
  reader starts at0 and can see retained old records without historical lag.

These are the source's distinct [batch rule](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/internal/streams.ts#L106)
and [individual lifecycle rule](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/internal/world.ts#L119).
Failure preserves boundaries, not the entire log: retry equality requires no
intervening new publication/capacity loss. E7/E11 satisfy that condition. A failed
reader remains a holder; an independent successful Fast cannot complete B.

Use the two-list FIFO above: append by cons onto reverse rear; reverse rear once
when front empties. Cache entry/value counts, including each batch's actual count.
Trim processes each dropped batch/record once; capacity subtraction is O(1) per
unit dropped. Reads traverse retained front then reversed rear and accumulate
actual output linearly; avoid growing-prefix append and recomputing list length
or remaining size on every removal. Counts include transient over-capacity content;
capacity is not an insertion rejection or fixed allocation ceiling. Avoid T07's
`capacity_rows` repeated `size(tail)` and unary Nat counts at public scale.
For R registered slots, holder collection is O(R) per key; a read is O(retained
entries + emitted values), trim amortized O(dropped entries), excluding payload
release/refcount costs. Native/JS timings and memory remain measured obligations,
not performance guarantees. [T07 baseline and limits](../../experiments/t07/README.md).

## Required checks before claiming the module works

E6/E7 must produce skipped-message suppression with retained removal/despawn values,
failed B then identical retry, and independent empty Fast. E8 must report added
[a,c], changed[a,c,p] with full final payloads; E9 removal/despawn order and actual
owner disposal remain unchanged. E11 must execute real C65536 batches/records,
B's first failing read then same-instance retry, independent Fast, and genuine Late
registration. Also cover unheld expiration and old surviving marks. Preserve event
`lagged()` versus public lifecycle `system.missed` provenance; never manufacture
cursor/lag observations from expected fixture positions. Compare every actual
returned element and payload before compact encoding; C3/C0 is supplementary only.

Declare compiling negative/control pairs for cross-schema reader/log routing and
undeclared reads; semantic mutants should target global-reader completion, failed
completion, skip changing lastRun, ignored registration/holders, eager append trim,
whole-group lifecycle trim, partial-batch event trim and expired survivor marks.
No universal reader law is approved here. The queue is an experimental bounded
choice, not a production layout. U32 wrap/exhaustion, dynamic reader deregistration,
arbitrary Type message fan-out, general Local/state/transition/relation streams
and production retention configuration remain explicit follow-ups.
