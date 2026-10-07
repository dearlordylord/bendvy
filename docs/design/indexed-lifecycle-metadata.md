# Indexed lifecycle metadata — reviewed experimental boundary

Design for discussion and implementation review, not approval of a layout, laws, dependencies or numerical criteria. Complements [source investigation](../research/indexed-lifecycle-metadata.md). No executable edits, builds or measurements were made for this design.

## Boundary: keep raw list clients intact

Keep existing `Col.Column{values,stamps:List<Entry>}`, `Col.State{values,stamps,...}`, `Carrier.Owned/Wrapped` and their legacy functions unchanged in shape and behavior. An arbitrary list can contain duplicate IDs, explicit zero entries and meaningful raw order. `L.get` uses the first matching entry; `L.clear` removes all matching entries; `L.set` prepends one entry after clearing all matches. Two arrays cannot preserve that raw representation. Do not implicitly normalize, discard duplicates or claim a list round-trip.

Add explicit indexed ordinary/prepared variants to Column, backed by separate indexed state/carrier types. Suggested schematic constructors:

```text
Column existing: Column{values,stamps} | Prepared{legacyCarrier}
Column additive: Indexed{indexedCarrier} | PreparedIndexed{indexedCarrier}
IndexedCarrier: IndexedOwned{state:IndexedState} | IndexedWrapped{inner}
IndexedState: values, metadata, capacity, current, owner, remaining, past
Metadata (Type): added:Array<U32>, changed:Array<U32>, depth, capacity,
                 exceptional:List<Entry>
```

This is a design sketch, not checked Bend syntax. The owning recursive carrier avoids assuming an enlarged native union transports all indexed fields cheaply. `current=0` with empty remaining/past represents an ordinary indexed column; ordinary and prepared dispatch still have distinct constructors. No authoritative tick list exists for normal IDs in indexed mode.

Add `empty_indexed` and `prepare_indexed`/an explicitly named opt-in adapter. Existing `empty`, `prepare`, `recover`, legacy constructor fixtures and frozen clients retain their original route. Only the selected candidate schema overlay opts in; gameplay, driver, normative checkpoints and reference application remain unchanged. An adapter may convert a legacy **empty stamp list** safely. A legacy nonempty stamp list stays legacy by default, including singleton, duplicate and zero entries. Indexed columns populated from the beginning need no later conversion. If converting nonempty metadata is necessary, expose a distinct explicit operation with stamp-observation equivalence and no raw-list identity promise; it is not the initial implementation.

The source compatibility canary **fails** for unchanged external exhaustive matches when variants are added. This is an explicit raw-sum API change: external exhaustive Column matches must cover the indexed cases. Universal raw-pattern source compatibility is withdrawn; old constructor argument shapes and legacy behavior remain preserved. Independent architecture review accepts this bounded experimental provisioning change under #30. Root inspected the actual archived Workshop and retained user-api/query-composition consumers: they do not exhaustively match Column/Prepared; archived Accepted/Rejected outcome matches are unchanged. All actual retained consumers and byte-frozen workload must still compile/run without input edits. `SwapOutcome` remains unchanged. A separate concrete provider type would require a broader Family/Component/command abstraction redesign and is not selected for this slice. No production layout or universal refinement is approved.

## Indexed operations and arbitrary IDs

Normal IDs are `1..131072`, indexed at `id-1`. Exceptional IDs are exactly zero or greater than131072. Their metadata remains in `exceptional`, using the existing list get/set/clear semantics. These are disjoint domains: each ID has **one** authority. Do not put a normal-ID cache and matching list entry in both places. On the measured valid-entity hot path, exceptional lookup/set/clear is not executed.

An indexed read checks the domain first, then capacity. A normal ID above current metadata capacity returns `Stamp{0,0}` without wrapping or allocating. Normal write/restore grows both tick arrays together to cover its ID, even when payload capacity is smaller; zero-fill the new region. Exceptional write/restore delegates to `L.set`, exceptional clear to `L.clear`, exceptional get to `L.get`. This preserves the currently unrestricted raw `Col.restore_stamp(id:U32)` lookup behavior without allocating arrays of size U32.max or silently dropping restoration. Normal and metadata capacities need not initially match: existing raw restoration allows metadata independent of payload bounds.

Metadata absence and explicit zero have the same **stamp observation**, so no normal-ID presence bit is needed. This does not invent a raw-list membership API for indexed columns. `wasPresent` continues to come from the actual previous payload owner. If an indexed raw metadata enumerator is later required, define its ordering/membership contract separately; do not export reconstructed zeros as if they were the original list.

All scalar Array operations thread the actual returned owner. Metadata is affine `Type`, not reusable `+Metadata`; reusable `+Stamp`/U32 results are fine. Never infer an owner's presence from a prepared evacuated array hole. Raw owner swap/project is metadata-neutral, and user projection can return a modified owner that must be reinstalled.

Base get/swap mask indexes modulo capacity ([source](../../.references/bend2/bend2/base.bend:2279)). Check nonzero ID and capacity before subtraction/indexing; use explicit bounds checks even on paths that currently receive valid handles. Growth doubles with a bounded decreasing fuel and must reject neither an otherwise valid restore nor overwrite any unrelated tick. Query order, World validation and clock exhaustion rules do not change.

## State transitions that must preserve the indexed route

| Transition | Required result |
| --- | --- |
| prepare indexed ordinary | Evacuate only actual component owners; retain the exact Metadata owner in indexed prepared state. |
| ensure within payload capacity | Return the same indexed mode and owners; no materialization or metadata reset. |
| ensure beyond payload capacity | Recover all prepared owners first, grow payload and metadata as needed, retain indexed mode. |
| view/has/project | Return the actual projection-returned component owner; metadata is neutral. |
| forward seek | Preserve existing Inspect/Choice/fuel and Nil-before-fuel precedence; carry Metadata exactly once. |
| backward seek | Recover all current/remaining/past owners, then use indexed ordinary route; retain every tick and exceptional entry. |
| refusal | Return all incoming/existing owners and Metadata unchanged, with the original refusal/outcome. |
| capture/restore | Snapshot one Stamp using returned Metadata; closure owns the full returned Metadata and cold owner state. Clean restoration is neutral; dirty restoration sets exactly the saved/current row stamp. |
| full-World fallback | Reattach every component owner and Metadata before old World operations; re-enter from the actual returned World. No fake World with holes. |
| rollback | Existing journal restores payload then saved Stamp in inverse order; retain already-advanced World clock, prior commits and unrelated metadata. |
| removal/despawn/reinsert | Preserve zero/clear semantics, removal observations and new added/changed ticks on actual reinsertion. |

Do not implement a helper that converts back to legacy lists at every prepare/recover or lifecycle call: that would retain list work in the timed route. Legacy and indexed dispatch are separate, explicit cases. `captured-column` needs indexed capture/restore cases and indexed seek state; `restored-row` can retain its individual Stamp-based contract. `row-column` and every direct Column/State matcher require source-current review and replay; old raw control inputs stay untouched.

## Minimal staged implementation

1. Freeze current closure and before CPU/allocation profiles. Implement only owned Metadata get/set/clear/grow with normal/exceptional domains; compare with legacy stamp observations for exhaustive small traces plus raw exceptional IDs. Do not use these controls as full core acceptance.
2. Add indexed ordinary Column owner route, preserving all old constructors/functions. Implement lifecycle/mark/restore/clear, view/swap/ensure and exact affine payload recovery. Replay all frozen old consumers without editing their inputs. Do not enable prepared queries yet.
3. Add indexed prepared carrier, forward/backward/recovery and captured restorers. Preserve existing fuel/phase semantics and reached owner-restoration mutation. Run both schema ownership/access controls and complete Workshop observations before measuring.
4. Opt in via the selected candidate schema's **initial empty column provisioning**, once per application. Avoid converting raw nonempty lists and avoid repeated adaptation during rows/systems. Keep main/gameplay/observer/benchmark contract bytes frozen and archive exact candidate provider/core hashes.
5. Run matched after CPU/collected-object allocation profiles separately from timing, then unchanged default and prepared-provider paired gates. Keep failed receipts. Measure source-bound equal-work scaling diagnostics before selecting the mechanism; no assumed speedup from reduced list operations.

No law/proof files, compiler/kernel/reference changes, package installation or threshold/baseline amendments are included. New ECS laws remain subject to draft/falsify/approval before proof.

## Exact controls and source binding

- Legacy route: exact raw constructor/list observations on empty, first/last duplicate, zero stamps and interleaved unrelated entries; get/set/clear order, first-match lookup and raw zero/exceptional/max-U32 IDs. Old authored fixtures remain byte-identical. Adding variants must not introduce unrelated compile failures.
- Indexed stamp equivalence: independent normal IDs at zero/one/capacity/capacity+1/131072/131073/U32.max, normal growth while payload capacity stays small, exceptional duplicate/zero-entry fixtures, isolation between both domains. Include added=0/changed>0 and added>0/changed=0 rather than assuming a sentinel tick means absence.
- Owner path: actual affine Array payloads and mutation-returning projection; ordinary/prepared capture, shared aliases, malformed/refusal controls, forward/backward, Nil/fuel precedence, clean/dirty restoration and complete returned owners. Existing2430-pair capture matrix plus new indexed route coverage is required; old matrix alone does not cover new cases.
- Transaction path: repeated distinct writes, max-minus-one then rejection, full replacement rollback, remove/reinsert then failure, earlier commits, retained clock, World resource/queue/event/reader observations. Validate **full payloads and ticks**, not counts alone. Detect reached wrong-index and omitted-restoration mutants on both backends.
- Authority path: actual public undeclared-access, cross-schema and write-through-read negatives, matched positive controls and intended diagnostics; actual same-schema foreign Factory handles with colliding IDs remain invalid and leave queue unchanged.
- Profile path: identical frozen applications, CPU call stacks, allocation stacks including collected objects, GC events/time and method limits; record actual emitted JS/native closure and input/settings hashes. Profile wrapper allocation is distinct from ECS attribution, and process RSS is distinct from sampled allocated bytes.
- Scaling path: freeze dense reads/writes, sparse high-water and churn/rollback traces at several sizes before timing; validate every complete observation/backend. Include payload presence density, metadata-array capacity and exceptional-domain cases. Report runtime/cumulative allocation/peak memory separately, warmup and variability. Diagnostic sizes do not define new acceptance thresholds.
- Delivery: unchanged #28 default gate plus #30 selected-provider gate, final full consumer/negative replay, independent Spec/Standards review, commit/push and issue report. Full JS<=TS and Native<=0.5TS qualification remains with parent matrix; full-parity10% allowance does not weaken these bounded gates.

Source foundation is the SHA-bound investigation: Column `869091a8…`, Component `0e41557c…`, captured-column `e7257f7d…`, restored-row `9a1e2535…`, lifecycle `6585d64f…`. A receipt for that closure is historical once any reachable source changes; each candidate must hash its complete reachable sources and compare the same complete observations. The inspiration is a layout idea only, with no established package compatibility or measured improvement.


## Private fused read-seek prototype — pending evidence

Matched application profiling identifies `indexed_seek_view` as the largest remaining self-allocation site after scalar-array projection (49.598864 MB sampled over 200 complete applications). Generated JS reconstructs a HandoffCon and Choice on Inspect and an Inspect on Advance. No causal speedup is established.

The reviewed prototype preserves the public phase-based helper and redirects no live route yet. A private step fuses two Inspect/Choice transitions: Nil wins at any fuel; nonempty fuel 0/1 exhausts with all owners retained; fuel >= 2 finds the actual owner, retains the head for absence, or moves exactly one owner into history. A recursive decision carrier allows arbitrary affine payloads. The loop maintains `loop(fuel, step(fuel, ...))`; Advance recurs with fuel minus two and a newly computed step. Terminal cases precede fuel matching. Wrapped consumes its owner once with unchanged fuel. Forged low-fuel Advance defensively preserves complete tail/history and returns current zero; it is outside the intended entry invariant. No extra gas counter is required.

Independent source review approves an isolated prototype, subject to complete comparison against the unchanged helper, mutating projection and owner recovery controls, exact public-phase compatibility, bounds/current/backward routing, reached head/history/fuel mutations and emitted Native transport inspection. No new law, proof, universal refinement, live promotion or performance acceptance is implied.
