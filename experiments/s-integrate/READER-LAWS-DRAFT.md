# Reader operations — subject-bound law draft and signature canary

Unapproved integration law draft for [#19](../../docs/tickets/18-integrated-runtime.md),
[E6–E11](../../docs/design/s-integrate-trace.md), and the
[implementation contract](../../docs/design/s-integrate-reader-implementation.md).
No `readers.bend`/`streams.bend` subject body or general ECS proof is introduced.
`reader-contracts.bend` checks abstract owner-return signatures and evaluates finite
observation predicates. It does not establish registry authority, concrete base-key
routing, dispatcher behavior or integrated retention. Exact declarations/proofs
remain subject to their separate approval gate after implementation falsification.

## Proposed operation freeze

Use shared `types.ReaderState{registeredAt,lastRun,streamLastRun}` and
`types.ReadBoundary{since,streamSince,thisRun}`. `Readers`, `Run` and logs are
private affine Type owners; Clock, actual base keys, declared interests, durable
schema-specific lifecycle handles H and schema-specific Ping values are Data.
`Run` wraps private invocation metadata and is consumed once by completion;
`RunInfo` returns that owner with the shared metadata projections. No opaque owner
is constructed by the signature canary. Gated/nested copies keep the real base key;
reader positions reside in a per-world dynamic registry, not fixed Fast/B slots.

The proposed aliases R=`readers.bend`, S=`streams.bend` bind the following actual
operations. `R.observe`, `R.project`, and `S.observe` must return their actual owners
plus complete Data observations; the equations below concern those observations,
not reconstructed owners or caller-supplied truth flags. `others` means every
registry entry except the selected base, including its interests and registration.
Valid-domain conditions are explicit: unique registered base keys; nondecreasing
log stamps; matching schema/world/declared-key routing; nonoverflowing U32 clocks,
counts and additions; actual Run from begin and used once. Bounds violations must
be detected before mutation, not silently wrapped. Production exhaustion is open.

| ID / exact proposed subject | Required observation equation |
| --- | --- |
| R-BEGIN: `R.begin(readers,base,interests,clock)` | Let n=old clock.tick. Existing slot s stays s; absent slot becomes `{registeredAt=n,lastRun=0,streamLastRun=0}` and registers holders only for its actual declared keys. Output clock.tick=n+1; other clock fields unchanged. Run boundary=`{s.lastRun,s.streamLastRun,n+1}`; Run registration=s.registeredAt. Other slots unchanged. |
| R-COMPLETE: `R.complete(readers,run,outcome)` | For Success, only selected saved lastRun/streamLastRun become run.thisRun; registration/interests/others unchanged. For Failure(code), all registry entries remain exactly as **after begin**, including first-invocation registration. Clock/capture/transactions are separate returned owners, not rolled back by this hook. |
| R-SKIP: `R.skip(readers,base,now)` | Registered selected slot changes only streamLastRun=now; absent stays absent. No callback, capture increment, registration or system clock advance. Other slots unchanged. |
| S-APPEND: `S.append(log,published,values)` | Empty values: entire log unchanged. Otherwise append exactly one immutable batch `(published,values)` in FIFO order; cached size increases by actual value count; droppedThrough unchanged. No capacity trim or partial batch rejection on append. |
| S-APPEND-LIFE: `S.append_lifecycle(log,applied,handles)` | Append one `(applied,handle)` record per actual applied handle in order; cached size increases by that count and droppedThrough is unchanged. No eager trim, deduplication or sorting. |
| S-FRAME: `S.frame(logs,clock,holds)` | For old clock `(n,f,r,k)`, output clock `(n,n,(f>0 ? f : r),k+1)`. If f>0, trim lifecycle logs at f; otherwise leave them unchanged. Always trim message logs at returned retainedAfter, including0. The frame does not advance n. Sparse change-index expiry cannot erase live added/changed marks. |
| S-TRIM-PING: `S.trim(log,window,holders)` | b=min(window, registered streamLastRun values), or window without holders. Drop batches with tick<=b, then whole oldest batches until total remaining **values**<=capacity. Result retains exact batch/value order; droppedThrough=max(old drop, ticks actually removed). |
| S-TRIM-LIFE: `S.trim_lifecycle(log,window,holders)` | Same window rule using lastRun; then remove exactly max(remaining size−capacity,0) oldest **individual records**, even within one same-tick group. Preserve identity order and duplicates; update droppedThrough by actual removed ticks. |
| S-READ: `S.read_ping(log,run)` / `S.read_lifecycle(log,run)` | Return same log/Run owners and all actual retained values/handles with tick strictly greater than run.streamSince / run.since. Preserve order; do not complete any reader. Ping lag=`droppedThrough > max(streamSince,registeredAt)`. |
| S-MISSED: `S.missed(log,run)` | Lifecycle diagnostic lag=`droppedThrough > max(since,registeredAt)` with selected actual declaration. It is passive `system.missed` provenance, not a new callback lifecycle `lagged()` method. Registration does not filter old retained read values. |

S-APPEND applies separately to nominal MotionPing/HealthPing. Lifecycle append
uses actual successfully applied removal/despawn handles, not deleted payloads.
Marks are storage metadata: insertion stamps added+changed; overwrite changes
changed only; failed transactional setters publish neither. D/T and transaction
commit supply their actual ticks. Commit stamps changed before publishing events
at one fresh post-run tick; R-COMPLETE saves thisRun, not publication tick. Failure
leaves prior publications and saved boundaries; a newly registered failed reader
remains a holder. Retry repeats retained values/lag when no intervening capacity
loss/publication changes the log. Neither another reader nor Snapshot can complete B.

Primary source: pinned bevy-ts `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`,
[registration/run/skip](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/Runtime.ts#L1344),
[publication](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/Runtime.ts#L1023),
[message retention](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/internal/streams.ts),
[lifecycle retention](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/internal/world.ts#L119).

## Finite falsification before bodies

All 32 `checks()` values evaluate True on installed Bend2.0.34: 16 positive
observation checks and rejection of 16 deliberately perturbed observations. These
are finite oracle sensitivity checks, **not mutations of an existing subject**.
The full subject must later produce these observations through actual dispatched
operations, including independent other-reader preservation, then survive its own
compiling decision-path mutation suite.

| Pair indices (1-based) | Positive / deliberately rejected observation |
| --- | --- |
| 1–2 | First begin at8 produces registration8, positions0, boundary0/0/9 / prematurely complete or register at9 |
| 3–4 | First failure retains newly registered state8/0/0 / remove registration entirely |
| 5–6 | Retry at9 keeps registration8 and produces boundary0/0/10 / reset registration9 |
| 7–8 | Success saves10/10 / save later publication tick11/11 |
| 9–10 | Existing failure keeps positions2/3 / advance both4/4 |
| 11–12 | Registered skip preserves change2, advances stream7 / advance change7 |
| 13–14 | Unregistered skip stays absent / fabricate registration |
| 15–16 | C3 message batches [1,2]@1,[3,4]@3 retain [3,4], dropThrough1 / retain tail [2,3,4] |
| 17–18 | Oversized [5,6,7,8]@5 drops whole / retain [6,7,8] |
| 19–20 | C3 lifecycle [1,2,3,4]@3 retains [2,3,4], dropThrough3 / drop whole same-tick group |
| 21–22 | Drop5, saved0, registration5 is not lagged / report old loss |
| 23–24 | Drop5, saved0, registration0 is lagged / suppress loss |
| 25–26 | Append second batch preserves both batches before trim / eager trim |
| 27–28 | Empty append leaves log unchanged / append empty batch |
| 29–30 | Frame(8,3,1,4) becomes(8,8,3,5), trim boundary3 / advance change tick9 |
| 31–32 | Initial frame preserves tick0 and has no lifecycle trim / trim lifecycle at0 |

Reproduce the checked signatures and all finite results, each under five seconds:

```sh
experiments/t01/bend-check experiments/s-integrate/reader-contracts.bend --check-only
experiments/t01/bend-check experiments/s-integrate/reader-contracts.bend
```

Observed: `ALL PROOFS CHECK` in checker-only mode, and exactly 32 `True{}` values
in evaluation mode. No equality theorem, law filling, `--verdict` ECS proof,
unsafe definition or source-checker repair is used here. `bend version` and
`bend guide` were read before this work. The checked source pins are:

| Artifact | SHA256 |
| --- | --- |
| shared `types.bend` at f2eec8d | `4dcaa0998c00f4a02e6a971ba5b95a98e7e0e6f13c5bc2a816bd68383a328eda` |
| `reader-contracts.bend` | `5e753cfa376de31483ff7ea34d7dcd24bb4e135ea136eb7b2b42ed7b849b0147` |
| installed Bend2.0.34 executable | `d4821d04932218216c9dc906223ed0e23dd86726d4357a567fb76ee6c976db4e` |
| installed Base | `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661` |

Fresh Node24.20.0 execution of pinned `Streams.make(3)` also checked actual pre-trim
[1,2,3,4], post-trim[3,4], old-reader lag, boundary2 no lag, oversized-batch empty,
and registration5 no historical lag. No new dependency/reference edit. Reproduce:

```sh
timeout --signal=KILL 5 node --input-type=module <<'JS'
import assert from 'node:assert/strict'
import {make} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/internal/streams.ts'
const key=Symbol('Ping'), s=make(3), old={streamLastRun:0}; s.register(key,old)
s.append(key,1,[1,2]); s.append(key,3,[3,4]); assert.deepEqual(s.since(key,0),[1,2,3,4])
s.trim(0); assert.deepEqual(s.since(key,0),[3,4]); assert.equal(s.lagged(key,0,0),true); assert.equal(s.lagged(key,2,0),false)
s.append(key,5,[5,6,7,8]); s.trim(0); assert.deepEqual(s.since(key,0),[]); assert.equal(s.lagged(key,0,5),false)
console.log('PASS')
JS
```

Temporary signature controls appended to an exact copy of this canary (before its
`main`) with shared types beside it passed or failed at the intended boundary:

```bend
# Positive: arbitrary affine invocation owner can be returned.
def positive(-Run: Type,run: Run) -> Run:
  run
# Negative: expected EventResult<Log,Run,T.HealthPing>, observed MotionPing.
def nominal(-Log: Type,-Run: Type,hook: Log -> Run -> EventResult<Log,Run,T.MotionPing>,log: Log,run: Run) -> EventResult<Log,Run,T.HealthPing>:
  event_join(Log,Run,T.MotionPing,hook,log,run)
# Negative: run consumed more than once.
def duplicate(-Run: Type,run: Run) -> Run & Run:
  (run,run)
```

Each definition is checked in a separate temporary file under the same wrapper;
positive exits0, nominal and duplicate exit1 at their named definition. These
abstract controls do not establish integrated undeclared-read or write-through-read
rejection; the actual provider closures must supply those checks after freeze.

## Capacity and remaining gates

Runtime implementation must use cached U32 batch/value/record counts and amortized
FIFO front/rear lists (or an equivalent reviewed linear-cost structure). No repeated
remaining-list length traversal, unary capacity65536 counter, eager append trim,
fixed fixture cursor, manufactured observed sequence or schema-erasing Ping adapter.
Public C65536 and transient C+1/C+2 content must execute before acceptance; no fixed
array of capacity C may truncate pending-before-frame values. Preserve complete
Motion/Health E6–E11, first failed read and same-instance retry, independent Fast
and genuinely newly registered Late, live old marks, successful disposal, actual
public diagnostic provenance, and every-element/full-payload comparison. C3/C0
and the 32 oracle checks cannot replace those public/integrated runs.

Coordinator freezes hooks with shared/storage/transaction/dispatcher owners before
`readers.bend`/`streams.bend` implementation. General laws, production allocator or
clock exhaustion, reader destruction, noncopyable Type message fan-out, numerical
performance thresholds and new dependencies retain their separate gates.
