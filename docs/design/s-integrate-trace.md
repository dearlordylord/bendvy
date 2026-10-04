# S-INTEGRATE: concrete trace draft

Prerequisite for [#19](https://github.com/dearlordylord/bendvy/issues/19), governed
by [SPEC](../SPEC.md) and the [ticket](../tickets/18-integrated-runtime.md).
Drafted against `23ef716`; no integrated Bend runtime is implemented here.
Review this trace before implementation; the current work order also requires
#18 completion before that runtime work. This document approves no new law,
dependency, production policy, storage layout or numerical performance threshold.

## Evidence boundary and source contracts

The **E** tables below were drafted as source-derived expectations. Their newly
executed TS reference portions are recorded in the ledger below; no integrated
Bend result is inferred. **X** is the separately executed
[allocation checkpoint](../../experiments/s-integrate-trace/allocation-README.md)
and [raw evidence](../../experiments/s-integrate-trace/allocation-evidence.json),
integrated at `7208946`: seed1, A2, failed B3, subsequent4; A's value11 survives,
spawn3 is discarded, handle3 remains missing, and barriers expose spawns2/4.
That scalar, one-world execution does not establish the integrated E checkpoints.
Prior [R-A](../../experiments/ra-provider/README.md),
[R-C1](../../experiments/rc1-query/README.md),
[T05](../../experiments/t05/README.md), [T07](../../experiments/t07/README.md),
[T08](../../experiments/t08/README.md), [T09](../../experiments/t09/README.md),
[S-LAYOUT](../../experiments/s-layout/README.md) and
[S-CAPTURE](../../experiments/s-capture/README.md) supply seams, not #19 passes.

Pinned TS: `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`. Primary-source anchors:

| Contract | Pinned source |
|---|---|
| Reservation consumes a number immediately; transaction writes journal values; only commit stamps changed marks | [world.ts:316–424](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/internal/world.ts#L316) |
| Component removal/despawn append independent logs; frame trimming honors registered readers | [world.ts:475–710](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/internal/world.ts#L475) |
| Commit publishes events after the run tick; failure restores resource/component journals and drops staged events | [Runtime.ts:1010–1064](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/Runtime.ts#L1010) |
| Base-instance reader registration, skip, failure and success positions | [Runtime.ts:1344–1438](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/Runtime.ts#L1344) |
| Explicit deferred/state-transition markers and sequential failure propagation | [Runtime.ts:1517–1666](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/Runtime.ts#L1517) |
| Whole-batch message retention/capacity and registration-aware lag | [streams.ts](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/internal/streams.ts) |

## Fixture, observations and ownership

Run the complete trace twice, with distinct nominal schemas, not token aliases
over one declared composition. `Main/Aux/Flag/Ledger/Ping` below are notation for
the concrete descriptors in this table, never interchangeable runtime tokens.

| Schema | Main: affine Type | Aux: affine Type | Data metadata and declarations |
|---|---|---|---|
| Motion | `Position{coordinates:Array<U32>, frame:U32}` | `Velocity{rates:Array<U32>, moving:Bool}` | `Selected{group:U32}`; `MotionLedger{totals:Array<U32>, epoch:U32}` resource; `MotionPing{code:U32}` event |
| Health | `Vitals{levels:Array<U32>, reserve:U32, class:U32}` | `Armor{layers:Array<U32>, grade:U32}` | `Tracked{group:U32}`; `HealthLedger{totals:Array<U32>, epoch:U32}` resource; `HealthPing{code:U32}` event |

All arrays have four elements; the containing records and actual stored payloads
are Type. Main metadata is `frame=7` or `reserve=9,class=2`; Aux metadata is
`moving=true` or `grade=3`. Ledger starts `[100,101,102,103],epoch=4`. Each schema binds its own
`Mode` state machine with states On/Off, initially On, and an Audit service
with a declared `log(String)` operation; both are actually provisioned.
`V(x)` means the complete schema-specific Main with `[x,x+1,x+2,x+3]` and those
metadata fields. Aux is `[1,2,3,4]` with its metadata. Flag has `group=8`.
Every read/checkpoint compares all array fields and metadata, including unchanged
fields. Observation vectors are Data projections obtained while returning the
owner; they are not replacement payloads or rollback snapshots.

Thread one real trusted factory owner through creation of `Motion α`, `Motion β`,
`Health α`, `Health β`; these are **two runtime worlds per schema**. Two worlds of
different schemas alone would not test same-schema runtime isolation. Reserve
through each returned world owner, never assign a namespace/ID as authority.
For each schema, α receives `a:Main V(10)+Aux+Flag`, `b:Main V(20)`,
`c:Aux+Flag` in that reservation order; β receives `z:Main V(90)+Flag`.
The first α/β local IDs collide in the TS fixture. Keep β alive and unchanged
through every α checkpoint. Record real handle values and factory provenance.

Four public queries, each in ascending **logical entity** order:

- `Q`: required Main; `Q+`: required Main, present Flag.
- `Q−`: required Main, absent Flag; `Q?`: required Main, optional Aux.

`Snapshot` reports complete Q/Q+/Q−/Q? rows, Ledger, selected lookups and prior
dispatcher result. It is a separate ordinary read-only system with no stream or
change filters; it cannot advance either test reader. `Read` reports complete Q
plus `added(Main)`, `changed(Main)`, `removed(Main)`, despawned, Ping values and
each available lag result. Added/changed rows carry current full payloads;
removal/despawn records carry handles, not payloads recovered from deleted rows.
Tables abbreviate these outputs as `(added,changed,removed,despawned; messages)`.
Empty entries mean exact empty sequences, not omitted assertions.
Event lag uses the public event view `lagged()`. Removed/despawned system views
have no equivalent method: observe their actual public `runtime.debug.observe`
`system.missed` entries for the selected system (`removed`/`despawned` kinds;
Runtime.ts:1250–1265). This passive trace listener does not run or complete a
reader. Record its diagnostic provenance separately from callback read values;
ignore nondeterministic timing fields when comparing normalized observations.

Only the real dispatched `Fast` and `B` base instances are the two registered
readers. B has a state condition `Mode=On`; copies/nesting reuse the same base
instance. Prime both by successful runs before publication. A, B and Fast each
own independent `Local{count:Array<U32>}`, initially `[0,0,0,0]`; increment
slot0 on every actual invocation, preserving the other three fields,
including failed invocations, never on skip. Replay the entire trace with (1)
explicit returned owners and (2) a fresh once-only closure regenerated from that
owner each invocation. This reproduces lexical TS captures, not an approved Local
lifetime/rollback policy. No module-global substitute or reset-on-retry is allowed.

The trusted provider owns World/Schedule/transaction state. User callbacks are
checked for arbitrary affine, schema-specific handles and receive only declared
operations. Reads return handle plus projection; each read/write capability is
fresh. B's two setters are distinct supplied values. Main writes replace only
slot0, returning the owner and an inverse/retained prior owner; Ledger has the
same obligation. TS uses public cell `set` with fresh complete values, not
in-place mutation of an aliased array. No callback receives a writable concrete
World or substitutes a fabricated cell for its abstract handle. Public
constructors/imports are not hidden to manufacture these guarantees.

## E0–E5: reservation, rollback, retry and barriers

`tick(...)` means actual public schedule dispatch; brackets denote an actual
nested schedule. `D` is `Schedule.applyDeferred()`, `T` is
`Schedule.applyStateTransitions()`. T also flushes commands, so it is always
listed explicitly. Empty `tick()` never implies D. All results below are E.

| Step | Exact dispatched operations | Required checkpoint |
|---|---|---|
| E0 | Empty tick; `tick(Fast,B-observe)` while both worlds empty. Seed α and β by their own spawn systems, without D. | Empty tick invokes nobody. After priming, Fast=1, B=1, A=0, Tail=0; both read tuples empty. Reservations a/b/c/z are missing; queries empty. |
| E1 | Empty tick; then D in each world; `tick(Fast)` in α; Snapshot both. | Before D still empty. After D: α Q=[a,b], Q+=[a], Q−=[b], Q?=[a:Some Aux,b:None]; c gives QueryMismatch for Q, a gives Found. Fast reads ([a,b],[a,b],[],[];[]), count2. β Q=[z], unchanged Ledger. |
| E2 | `tick(A,Fast,[B-fail,TailInner],TailOuter)`. | A increments count1; a.slot0 10→11, Ledger.slot0 100→101; emits code1; queues `spawn p:V(50)+Flag`, then `remove(a,Flag)`. A's own reads see complete updated values; p remains missing. Fast count3 reads ([],[a],[],[];[1]). B details below. Both tails remain0; returned failure is B/code7 through the nested schedule. |
| E3 | Snapshot; empty tick; Snapshot; `tick(Fast)`. | Q remains [a,b], Q+=[a], Q−=[b]. a=[11,11,12,13], b=V(20); Ledger=[101,101,102,103]. p and failed q missing. Fast count4 reads all empty: B must not publish a changed mark on b, a removal/despawn, or code9. A=1, B=2; B's reader boundary is still its E0 success. |
| E4 | `tick([B-retry,TailInner],TailOuter)`; Snapshot; empty tick; Snapshot; `tick(Fast,B-observe)`. | Retry reads the same prior tuple/message as failed B, succeeds once; B count3. Both tails now1. b=[50,21,22,23], a unchanged; Ledger=[201,101,102,103]. Q/membership still E3; p/q/r missing. Fast count5 reads ([],[b],[],[];[2]); B-observe count4 reads ([],[],[],[];[2]). B sees its own post-run event, not its same-run changed stamp. |
| E5 | `tick(D,Fast,B-observe)`; Snapshot α/β; another empty D then Snapshot. | FIFO applies A's p spawn/removal then retry's r spawn/insertion. Q=[a,b,p,r], Q+=[b,p], Q−=[a,r]; optional Aux only a. p=V(50), r=V(60). q stays missing; c remains Q mismatch. Both readers see ([p,r],[p,r],[],[];[]); Fast=6, B=5. Empty D changes no public membership/value. β still only z=V(90). |

B-fail and B-retry are modes of the **same B instance**, not new systems:

1. Increment B capture; read tuple `([a,b],[a,b],[],[];[1])` before writing.
   This includes seed additions still unread by B, A's latest a and original b.
2. Set b.slot0 `20→30`; read `[30,21,22,23]`. Set it `30→50`; read
   `[50,21,22,23]`. Write Ledger.slot0 `101→201`; read all Ledger fields.
3. Reserve `V(60)` with no Aux/Flag as q on failure, r on retry; record actual
   returned durable handle in host capture. Public lookup is MissingEntity.
   Queue that spawn then `insert(b,Flag)`. Emit code9 on failure, code2 on retry.
4. Call declared Audit service with `B:attempt:2` or `B:attempt:3`; return
   `Fx.fail({code:7})` or success. A also calls Audit with `A:attempt:1`.
   If host-effect parity is claimed, perform the real service effect on Native,
   JS and TS before failure; post-hoc printed diagnostic strings do not establish it.

Failure restores b's two writes in reverse mutation order (50→30→20) and Ledger
201→101; A's earlier owner/value and queued work survive. Discard q's payload,
spawn/insert publications and code9, but **consume q's reservation**. Do not rewind
the allocator or reissue its escaped handle. Record raw reservation sequence and
assert r follows q and differs from all previous reservations, alongside normalized
labels. X established this distinction for its scalar subject; E must establish it
again for these Type owners. No raw transaction-generation/tick rewind is required:
observable failed marks/read positions are the contract. A touches a and B touches
b specifically so Fast's E3 empty changed set detects a leaked B mark.

## E6–E9: skipped reader, retained lifecycle, order and disposal

Continue the same owners, base systems and captures. B-observe modes perform no
writes/publications. Every state toggle is an actual next-state system followed
by T; its command queue is empty unless explicitly stated otherwise.

| Step | Exact operations | Required checkpoint |
|---|---|---|
| E6a | `tick(SetOff,T)`; `tick(Cleanup,Snapshot)`. Cleanup writes p.slot0 50→51, queues `remove(a,Main)` then `despawn(b)`, emits code3. | Before D: Q=[a,b,p,r], b live, a Main present; p=[51,51,52,53]. No structural change at end of tick. |
| E6b | `tick(D,Fast)`; three empty ticks; `tick(B)` while Off. | Fast count7 reads ([],[p],[a,b],[b];[3]); Q=[p,r]. B is skipped, count stays5. Its message boundary advances through code3, while its change/removal/despawn boundary remains E5. β unaffected. |
| E7 | `tick(SetOn,T,[B-observe-fail,TailInner],TailOuter)`; then `tick([B-observe,TailInner],TailOuter,Fast)`. | Failed B count6 and retry count7 both read ([],[p],[a,b],[b];[]), including retained logs after empty frames. Failure returns B/code7 and no tails; successful retry increments both tails to2. Fast count8 reads all empty. A=1. Neither B failure nor retry routes through Fast's cursor/capture. |
| E8 | Queue `insert(p,Main V(71))`, `insert(a,Main V(80))`, `insert(c,Main V(30))`, `insert(a,Main V(81))`, `insert(b,Main V(90))`; Snapshot; `tick(D,Fast,B-observe)`. | Before D Q=[p,r]. After D Q=[a,c,p,r], full values [V(81),V(30),V(71),V(60)], Q+=[c,p], Q−=[a,r], optional Aux at a/c only. b stays MissingEntity; c now Found. Both read ([a,c],[a,c,p],[],[];[]); Fast=9, B=8. Existing p overwrite is changed, not added; reinsertion a is both. FIFO makes a81, not80. |
| E9 | Queue `remove(c,Main)`, `despawn(a)`, `despawn(p)`, `despawn(r)`, `despawn(c)`; Snapshot; `tick(D,Fast,B-observe)`; empty D and a new successful spawn s:V(70), then D. | Before D owners/values still E8. After D α is empty; each reader sees ([],[],[c,a,p,r],[a,p,r,c];[]), in command/log order; all old handles stale except q already missing. Fast=10, B=9. Successful disposal consumes each removed Type owner once, including Aux. New s has a fresh ID after r/q, Q=[s], never revives old handles. β z and all its fields still intact. |

For indexed candidates, interpose trusted storage moves after E5: move b to a
vacant slot, then p to b's old slot; validate the actual ID→slot map through the
same queries/lookups, then execute E6–E9 on the moved owners. Repeat E8 with c
placed physically before a. Public order stays a,c,p,r. Record occupied-target
and out-of-range relocation rejections with unchanged owners as adapter checks;
do not invent a public TS relocation operation. List-backed runs execute identical
public commands. Timed churn later includes relocation/map costs, not only head
insertion/removal. Successful disposal is a structural path, not a promise that an
arbitrary irreversible callback can be rolled back.

## E10: identity, declaration and recovery controls

- With α.a and β.z live at E1, use α.a's actual same-schema handle in β lookup:
  Bend must return MissingEntity while β.z remains90. Record TS's actual foreign
  collision separately (source/prior T05 expects local z); never normalize it to
  parity. Test the reverse direction. Cross-schema Motion→Health misuse belongs
  to a compiler negative, not this runtime namespace check.
- Foreign structural commands return `MissingEntity` and leave the receiver
  queue unchanged, including when the numeric entity ID collides with a local ID.
  The user explicitly selected this result on 2026-10-04. Test both namespace
  directions and unchanged rows/metadata as well as pending commands. This is
  an approved Bend-specific comparison lane, not assumed TS parity; it adds no
  implicit exception, transaction abort or allocator policy.
- At the actual integrated provider, pair valid controls with undeclared getter,
  write-through-read, wrong nominal schema, reconstruction from observed fields,
  detached fabricated cell/world return, foreign concrete substitution and missing
  returned-owner attempts. Require each intended checker diagnostic, not any error.
  Pair a closure invoked once with the identical affine closure invoked twice.
- Destructive-recovery pair: success/control retains and returns the real payload
  owner with inverse evidence; negative transfers it to an irreversible consumer,
  then tries to return its consumed alias or claim recovery from only the observed
  numbers. The former must fail affine checking; a Data snapshot of the Type
  payload must fail the kind boundary. Affine discard itself is legal. These
  rejections do not prove arbitrary recovery impossible or exclude destructive
  payloads from the full target. If the proposed transaction seam still admits a
  consumed owner without recoverability, report that capability failed and require
  an explicit retained-owner/rejection/contract redesign before acceptance.
- Provisioning uses declared Ledger and Audit. On fresh owners use public `runtime.tryTick` for the real nested
  E2 schedule with Ledger missing, then Audit missing: assert the exact
  MissingRuntimeRequirements entry and no A/Fast/B/Tail invocation or side effect.
  Keep Mode=On and every other requirement provisioned. Missing Ledger yields
  `{ok:false,error:{kind:"MissingRuntimeRequirements",requirements:[{kind:"resource",name:"MotionLedger"}]}}`
  (Health uses `HealthLedger`); missing Audit yields the same outer result with
  `requirements:[{kind:"service",name:"Audit"}]`. Both present gives E2's
  `{ok:false,error:{kind:"SystemFailure",system:"B",error:{code:7}}}`. Do not replace dispatcher failure
  with a hand-authored diagnostic or an unrelated toy schedule.

## E11: retention, capacity and lag boundaries

E6/E7 already test held records beyond the two-frame window and skip/failure.
Also replay from fresh owners through these exact additional boundaries:

| Lane | Operations and expected observations |
|---|---|
| Unheld expiration | Before any reader registration, spawn a:V(10),b:V(20); D; remove(a,Main),despawn(b); D; three empty ticks; first Fast run: Q/added/changed/removal/despawn/messages all empty, no historical lag attributed before registration. |
| Old surviving marks | Prime Fast only; spawn a:V(10); D; Fast; write a.slot0=11; three empty ticks; first B run: added=[a],changed=[a], both carry [11,11,12,13]. Sparse change-log expiry must not hide surviving marks. |
| Public message overflow | Fresh registered Fast/B, `C=65536` (pinned runtime capacity). Publish one batch codes [0..C−1]; Fast reads all, B waits. Publish [C]; next empty tick trims. B's first post-drop read is B-observe-fail: [C], lagged=true; it fails, then B-observe retry succeeds with the identical sequence/lag. Fast reads [C], lagged=false. Publish oversized batch [C+1..2C+1]; next empty tick: both unread=[] and lagged=true. A newly registered reader after that drop sees [] with lagged=false. |
| Public lifecycle overflow | Fresh registered Fast/B; reserve C+1 Main entities e0..eC, D; both read to advance past addition. Queue removal of every Main in ascending ID order; D; Fast reads all removals before trimming. Next empty tick: B's first post-drop read is B-observe-fail: [e1..eC], removal lagged=true; it fails, then B-observe retry succeeds with the identical sequence/lag. Fast sees [] and no lag. Repeat on fresh owners with despawn in place of removal and assert both removed and despawned retained sequences. A new reader registered after dropping e0 is not lagged by that drop. |
| Small-capacity diagnostic | Supplement with pinned internal Streams.make(3): batches [1,2]@1 and [3,4]@3, trim(0), old cursor0 sees [3,4]/lagged; cursor2 sees [3,4]/not lagged. Oversized [5,6,7,8]@5 then trim drops all. Capacity0 drops [1]@1. Lifecycle makeWorld(schema,3), four same-tick removals/despawns, two frame advances retains only last three. These are explicitly internal reference checks, not public capacity configurability or a replacement for the integrated public lanes. |

Message capacity drops whole batches; lifecycle capacity drops individual records,
including part of a same-tick group. `lagged` compares dropped-through against both
saved boundary and registration time. Save raw reference tick/debug evidence where
available, but compare actual reads and lag results; never equate a retained-list
index to all clocks. Large ranges above denote exact sequences: compare every
element and full payload where present, not only counts/endpoints/checksums.
If the five-second runtime budget prevents a public overflow lane, report it
unresolved; the small-capacity diagnostic cannot silently satisfy that capability.

## Execution and review gates

Prototype parameters: width4; main fixture capacity64, no reuse; separate overflow
fixtures sized at least C+1; actual factory provenance; U32 arithmetic guarded
before overflow and every physical access checked after identity/membership.
These finite domains are experimental, not root authority, production allocator
reuse/exhaustion or clock-wrap policy. They are compatible with the separately
prepared measurement fixture n=64/256/1024 and width4; correctness overflow fixtures
are additional, not benchmark sizes.

For each schema/owner-style/storage candidate, persist ordered canonical public
observations, raw reservations, attempted reads, service effects, dispatcher
results and invocation counts. Label public parity, approved foreign divergence,
internal adapter checks and ownership/compiler controls separately. Execute the
same frozen inputs freshly in pinned TS, Native and JS; failures remain failures,
not corrected expected constants. No frame-end auto-flush, field-dropping digest,
physical sorting or fabricated ID mapping may conceal differences.

Required compiling semantic mutants and intended witnesses: wrong namespace E10;
stale map/physical query order E5/E8; suppressed setter E2 own-write read; wrong
inverse order E3; rewound/reissued reservation E4/raw IDs; failed changed stamp E3;
failed command/event leakage E3/E5; global/other reader routing E2–E7; failed cursor
advancement E4/E7; wrong skip cursor E7; reset/shared capture E2–E7; reversed FIFO
E8; implicit flush E0/E3/E4/E6; dropped holder/capacity/registration E7/E11. Require
each mutant to compile and differ on both Bend backends at the intended checkpoint;
parse/type errors and timeouts do not kill semantic mutants.

Before implementation, inventory the actual reused provider, factory/resolver,
query, command/flush, reversible transaction, reader/log and dispatcher functions;
freeze their interface obligations against this trace. Draft/falsify new exact
integration laws before their subjects, and obtain specific approval before any
general proof. Existing Nat model endpoints cannot discharge Type ownership or
runtime refinement. Run version/guide, pin compiler/Base/reference/source hashes,
keep each checker/kernel ≤5s and distinct build/runtime limits explicit; use
existing Node/direct imports, no new dependencies, only task-owned process cleanup.

Follow the separate measurement plan for equivalent dense/sparse/update/churn/
reader/rollback workloads, setup outside steady state, exact final observations,
per-workload ratios/variability and memory-method limits. Do not adopt a layout
from isolated kernel wins or hide Native/JS regressions. Threshold approval remains
pending. Capability ledger and two-axis review must distinguish passed, failed
and unresolved for every lane above; none is passed merely by this specification.

Open dependent decisions remain: production root authority,
allocation reuse/exhaustion and any divergence from observed consumption; general
Local lifecycle/rollback; arbitrary destructive Type recovery/noncopyable message
fan-out; storage choice and performance thresholds; new exact laws/dependencies.
Generic schemas/resources, dynamic registration/provisioning/conditions/phases,
relations/scopes/state failure ordering, restoration/tooling and parallel compute
remain full-core follow-ups, not removed scope. The console application follows
verified capabilities; Tower Defense uses a separate source copy, never edits the
original repository or read-only references.

## Fresh reference execution ledger — 2026-10-04

| Artifact | Executed evidence | Remaining boundary |
|---|---|---|
| [Scalar allocation X](../../experiments/s-integrate-trace/allocation-README.md) | Actual public dispatcher reservations 1/2/3/4; failed spawn discarded without counter rewind | One scalar schema, not Type ownership or global allocator policy |
| [Main public reference](../../experiments/s-integrate-trace/main-README.md) | Four Motion/Health × capture-style lanes; complete E0–E10 public read/write/dispatch portions, 34 full α/β snapshots per lane, 76 selected-reader public diagnostics including eight failed B invocations; exact expected values and empty missed sequences | E10 Bend compiler/recovery controls, foreign-command Bend result/queue controls, trusted factory authority and indexed relocation are not TS results |
| [Public E11 retention](../../experiments/s-integrate-trace/retention-README.md) | Ten Motion/Health case runs; real C65536 message/lifecycle overflow, first failed read and same-instance retry, independent Fast/Late, unheld expiration and surviving marks; every element/full field checked before lossless encoding | No Native/JS retention implementation or arbitrary Type message fan-out |
| [Internal E11 supplement](../../experiments/s-integrate-trace/internal-retention-README.md) | Five separate C3/C0 source-API diagnostics with exact batches/individual record trim and registration-aware lag | Explicitly internal APIs; not public capacity configuration or dispatcher acceptance |

The coordinator replayed these artifacts; independent Spec/Standards review and
focused diagnostic-fix review are in the [Spec](../reviews/integrate-trace-spec.md)
and [Standards](../reviews/integrate-trace-standards.md) reports. Recorded source,
adapter and trace hashes identify each executed revision; timing fields are
execution-limit evidence only. Full E0–E11 acceptance still requires the integrated
Bend owner/provider/transaction/reader/dispatcher, actual negative checker pairs,
Native/JS equality, compiling mutants and equivalent measurements. #18's owned
endpoint and its pending exact approvals remain a separate prerequisite to that
Bend implementation under the active #18 → #19 order.
