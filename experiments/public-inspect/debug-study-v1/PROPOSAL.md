# #56 detached debug projection — source-only draft

For coordinator review, not a selected new contract, implementation, execution receipt, law or #56 completion. Governing issue56 remains blocked by55. No checker, reference application, backend or profiler was run.

## References and full surface

Pinned TS3040a3b2a3f28fa8554d856f9ccb6bf5433fa334, Rust Bevyad678262ce53b5d142fe49ee5e08caff6f00ab60, Benda950fd683c0d76f09794078e6174fe98a1492876; adopted coordinator core61e85364.

| Source | Contract and remaining coverage |
| --- | --- |
| TS packages/core/src/Debug.ts:54–217, internal/debug.ts:224–405 | Format1; component/resource constructed/transient/plain descriptions, resource presence, relation/hierarchy/order/linked-despawn descriptions, machine states/current, service presence, named schedule marker order, system placements/query/resource/event/machine/removal/failure/service/condition access; component/resource/event access indexes; five lint codes. Current Inspector does not implement this complete debug catalog. |
| TS Debug.ts:226–268; Runtime.ts:1883–1928 | Dump filter entity IDs, conjunctive component presence, limit; ascending live IDs; entityCount before filtering; component values including transient, relation targets, present resources, current/pending/previous machines, pending command tags/origins, frame/tick. Dump is not save/restore. Values are upstream aliases, not an affine cloning authority. |
| TS Runtime.ts:1970–2003; Debug.ts:270–291 | Schedule naming replaces the prior map; describe/population/frame/streams are runtime debug observations. Retained streams include unread/lagged/heldBy; neither retention policy nor runtime-internal system naming may be inferred from our World fields. Tracing/disposal is57. |
| TS Inspector.ts:33–66; adopted inspector/check and query modules | Inspector is declared read access, separate from debug handle. Current source/refusal/normal/query/check/retainer evidence qualifies its finite scopes, not Debug.Description or WorldDump. Machine/state, relation, stream and service categories still require their owning contracts. |
| Rust crates/bevy_ecs/src/world/entity_access/entity_ref.rs:84–154 | EntityRef exposes archetype/component membership, immutable typed references and ticks. Preserve read discipline; reflection and numeric IDs do not supply world authority or general cloning. |
| Bend guide/GUIDE.md:55–83; bend2/base.bend Array definitions; src/ecs/component.bend, world.bend:138–142/200/271 | Type payload and closure ownership are affine. Existing family projection C→C&V and resource projection R→R&V return owners. Handle enumeration and clock return World. Never clone arbitrary owned payload or reusable captured closure. |

`info`, entity `get`/`list`, world dump and machine `state` must be mapped by actual source category: debug describe/population/dump are not Inspector getters; machine current/pending/previous are runtime machine state, not guessed from component metadata. The full owning55/56 inventory must resolve any wider accessor formats before parity acceptance.

## Safe independent slice proposed

Detached closed declaration metadata plus filtered component/resource Data projections; no service value alias, captured provider, stream heldBy policy or machine/runtime-internal reconstruction. Names are display labels only: duplicate labels never manufacture descriptor/namespace authority. Typed family tokens and actual World.Handle validation determine access. Existing trusted canonical declarations remain trusted; arbitrary caller metadata truth is not claimed.

Suggested signature shape (notation only; uncompiled):

```text
projectComponent: C:Type -> C & V:Data
projectResource: R:Type -> R & RV:Data
dump: World<S,Store,R,E> -> Filter<S> -> World<S,Store,R,E> & Dump<V,RV>:Data
entityGet: World<S,Store,R,E> -> Handle<S> -> World<S,Store,R,E> & Result<MissingEntity,Row<V>>
```

The closed setup carries typed lenses and template projection functions; the gameplay caller sees opaque owner H and read capabilities. Output Data is fixed before H. Arbitrary independent Array/recursive Type families are preserved and fully returned, with no Data payload restriction. An independently owned list of Data rows may be serialized by the host; no component/resource owner escapes. Detached here means no mutable owned alias, not durable save data or stable entity authority.

Every admitted request returns the complete World, store/resource/queue owners and independent inspector instance unchanged; it must not use Inspector.run, which advances its own cursor/world clock on success. Compose owner-returning read getters directly under an opaque read-only frame. Repeated dumps do not register readers, advance clocks/cursors, retain/drop events, flush commands or activate machines. Filter tests precede row limit; absent component is distinct from projected value. Preserve ascending IDs and total live count before filters. Reject foreign handles with MissingEntity even same numeric ID; cross-schema/undeclared/write/duplication are static boundaries. No unrelated service capture or disposal semantics are introduced.

Declaration metadata covers only facts held by the actual closed setup. Runtime frame number, command origin, machine pending/previous, schedules/access indexes/lints and stream heldBy are explicitly unavailable in this first slice unless an approved source-backed provider owns those facts; never substitute World.clock for Runtime.frame or invent unknown names/identity. Full dump format/version publication awaits complete field parity or explicit approved divergence. This slice cannot be marketed as full WorldDump/Description.

Disabled operation dispatch returns owners without invoking projections or building descriptions; opt-in path alone computes rows. This is a proposed testable contract, not an established zero-overhead claim.

## Required qualification before implementation acceptance

Independent two-schema applications with arbitrary affine families/resources; actual independently created same-schema worlds; exact owner/queue/cursor/clock snapshots before and after repeated requests; empty/nonempty/conjunctive/limit/order/absent cases and transient/plain/constructed projection cases. Execute actual pinned Node TS reference and JS/Native complete observations once concrete scope is approved. Freeze independently authored literal full outputs before candidate runs; reached compiling filter-order and noninterference controls must preserve complete owner snapshots. Source negatives: foreign output typing, cross-schema, undeclared getter, write-through-read and affine owner duplication. No new laws/proofs without approved law workflow.

Full56 still needs description/system/schedule/lint/access-index/population/naming and machine/relation/transient values; broader55 categories, services50 and streams48/53 retain their owners. Existing61 full-core independent applications and unchanged28 plus fair feature timings/scaling remain required. No acceptance threshold, dependency, ownership policy or competing plan is proposed.
