# Basic snapshot readiness v1 — source investigation

Read-only Bend source findings for #58. This section selects no wire format, ownership policy, new laws or dependency. No checker, proof, backend or reference execution was performed. The unchanged [snapshot contract](../parity/snapshot-export.md:9) requires an independent save while preserving live owners and rejecting unvalidated descriptors; source inspection alone does not satisfy its delivery gates.

## Bend ownership and reusable primitives

The bound inspected source snapshot is root commit `c9458fb5a79969c96b4b71baf1966cc32356430b`; the companion inventory records its exact source bytes. The actual Bend checkout is `/workspace/formal-proofs/bendvy/.references/bend2` at `a950fd683c0d76f09794078e6174fe98a1492876`, matching `.references/sources.json`.

- [restored-row.bend:7](../../src/ecs/restored-row.bend:7) stores an affine `Cell<S,C>` with `C:Type`, optional owner, stamp, dirty flag and captured `Slot<C> -> Column<S,C>` restoration closure. `detach` delegates to capture; `attach` consumes the cell and restores that same captured target (lines 14–23). `project` requires an explicit `C -> C & V` with `V:Data`, retains the returned owner and yields an optional view (lines 24–31). Unavailable extraction is `Deferred`, not component absence. These are reusable source definitions, not a serializer or snapshot type.
- [captured-column.bend:19](../../src/ecs/captured-column.bend:19) restores actual affine owners through `Array.set`; closures capture column/index/metadata (lines 19–48, 71–80). Capture validates IDs before extraction; prepared routes can return `Unavailable` with the intact owned column on exhaustion (lines 55–68). `dirty=False` avoids metadata changes (lines 15–18). The closure belongs to transient live ownership machinery; placing it in a purported independent saved descriptor would retain live restoration authority.
- [column.bend:32](../../src/ecs/column.bend:32) retains arbitrary `C:Type` in `Array<Maybe<&1,C>>`, including ordinary/indexed/prepared variants. `view` dispatches all four variants (lines 452–457); extraction, explicit projection and restoration are visible at lines 346–364 and 92–111. Recovery restores evacuated owners (lines 152–184). These paths offer owner threading without imposing `Data` on component payloads.
- [component.bend:9](../../src/ecs/component.bend:9) binds caller-authored trusted schema lenses `take`, `put` and `project` into `Family`; its runtime field is only a name. `get_store` reconstructs the store after `Col.view` (lines 37–48), and public `get` checks namespace, positive/in-range ID and live presence (lines 56–74). This validates live handles, not arbitrary saved descriptors. Internal owner/stamp rollback routines at lines 150–177 and 200–215 are restoration machinery, not descriptor validation.
- [capabilities.bend:6](../../src/ecs/capabilities.bend:6) already exposes `H -> H & Access<V>` and `H -> H & V`; universal `invoke` keeps `H` abstract (line 77). Additive owned requests and `invoke_owned` accept arbitrary `Type` input/output (lines 81–90). [world.bend:16](../../src/ecs/world.bend:16) owns affine store/resource/arrays and pending function closures, while handles/registration metadata/events have explicit `Data` types. A world value cannot simply be copied into a save.

## Why implicit arbitrary serialization is unsupported

The pinned [guide:55](../../.references/bend2/guide/GUIDE.md:55) distinguishes copyable `Data` from affine `Type`; closures remain affine even with only Data captures (line 83). Arrays are owned and reads return the array (lines 185–195). Dropping affine values is legal, so affine typing alone does not prove that a supplied projection preserves all owners or leaves observable state unchanged (lines 219–225). `Type=Kind(&1)`, `Data=Kind(&2)` (line 247).

These rules have concrete checker implementation: [bend.ts:3467](../../.references/bend2/bend2/bend.ts:3467) checks binder kinds and gives the Data-required diagnostic for reusable binders; `uses_close` rejects excess consumption (lines 3478–3487). Function types infer `Type` (line 3378). [comp.ts:820](../../.references/bend2/bend2/comp.ts:820) distinguishes erased quantities from live quantities. The compiler/checker theory comment explicitly requires that compiler passes never introduce ownership copies (bend.ts lines 163–195); this is source authority, not a proof or runtime observation obtained here.

Pinned [Base:2284](../../.references/bend2/bend2/base.bend:2284) offers `Array.swap` for `T:Type`, returning the array plus extracted owner; `Array.get` requires `T:Data` (line 2400). Index operations mask/wrap indices (lines 2279–2282, 2395–2398), so checked domain boundaries matter. `Maybe.show`/`List.show` require an explicit `A -> String` (lines 2218–2235) and consume their input; they neither reflect arbitrary types nor return an affine payload owner. The inspected definitions supply no general implicit `C:Type -> C & saved-data` codec. Serialization of a known Data view is separate from observing arbitrary Type owners.

## Smallest candidate seam, without a selected contract

The existing type-compatible starting point is a schema-provisioned explicit projection `C:Type -> C & V` for each selected family, `V:Data`, composed through the existing checked world/capability reads so the result has the shape `World -> World & SaveData`. Resource export needs the analogous explicit owner-returning projection. Any encoding of `V` must have an explicit codec; metadata/allocator coverage and transient selection must be supplied by the governing contract. This is an inferred seam shape, not implemented or approved snapshot behavior. Data views may share immutable Data internally without sharing affine live owner authority; post-save live mutation and save lifetime still require #58 observations.

A descriptor-bearing entry point must reject descriptors until the advertised validation succeeds. Existing `Family{name}` and live-handle validation do not establish saved version/name/codec/schema validation. A typed validated input or explicit checked result could enforce that boundary, but the choice and exact descriptor checks await contract findings. Do not expose raw family/restoration closures as saved descriptors or treat a supplied name as validation. No new restore/import behavior is implied by this export seam.

## Evidence limits and inspected file hashes

The functions above are actual source definitions. This investigation checked no proof theorem covering snapshot independence, preservation by arbitrary projection, codec roundtrip or descriptor validity, and claims none. No existing finite receipt was promoted to source-current #58 runtime evidence. Required JS/Native/Node comparisons, negative controls, reached mutants and proof approvals remain outside this bounded source investigation.

SHA-256 hashes of inspected authorities (root-relative paths; references are the absolute pinned checkout noted above):

| Source | SHA-256 |
| --- | --- |
| `src/ecs/restored-row.bend` | `9a1e25359a7775e230ad1b720180db622c12c2e9757cba98acef9c89e8d0f2d5` |
| `src/ecs/captured-column.bend` | `340efc234a5681adb2ccd35da22a1cbe3fbde4d15f0e6a3f8a75e76c4852df0a` |
| `src/ecs/column.bend` | `3fec368b85fd1d43e53de3838ec32486c5d74b628a7069a82a83e60922b29f2a` |
| `src/ecs/capabilities.bend` | `bc25cd83326709700de1f8ecc1fa53623883a4c3e423db67aa64eaffc3f1d6fe` |
| `src/ecs/component.bend` | `0e41557cc6b8101490eaa7f4bf5fbdf896a2646e9b2359d7daf41db6de45988c` |
| `src/ecs/world.bend` | `a20b0f2363dab12b73109354ebddf5c9126d3e786031cf9232a0c68c5ffc3b5c` |
| `.references/bend2/guide/GUIDE.md` | `9001a4ac112e92dc0c069c8b9d5812e114c2557427d9f962cddeef1ef6c292b6` |
| `.references/bend2/bend2/base.bend` | `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661` |
| `.references/bend2/bend2/bend.ts` | `1d133151652b597a1a035c77c172475e6de096da37f3b9e3adc23c2f75bdfe49` |
| `.references/bend2/bend2/comp.ts` | `32fb66e09f608ce9e4b173384bcfeec453db8c5bc96650e26ad861bef815a8d9` |
| `docs/parity/snapshot-export.md` | `c38e92f7bc1c51da3bd8179ca6a44e6a1a835354e5f4f8ba6ac5a7c6b8053f2f` |

## Pinned TypeScript behavior and the unchanged ticket boundary

The comparator is bevy-ts `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`. [Snapshot.ts:49](../../.references/bevy-ts/packages/core/src/Snapshot.ts:49) gates both public methods on every component/resource being transient, decodable, or constructed by a result accepting unknown input. The gate is static; [Runtime.ts:1723](../../.references/bevy-ts/packages/core/src/Runtime.ts:1723) does not run validators when exporting. Forced unchecked calls must not be confused with the advertised typed entry point.

[WorldSnapshot:83](../../.references/bevy-ts/packages/core/src/Snapshot.ts:83) contains version `1`, `nextEntity`, entity IDs/component values keyed by descriptor names, ordered relation target/source groups, resources by name and committed machine values. It contains no services, registered system/capture/Local state or pending runtime queues. [World.ts:719](../../.references/bevy-ts/packages/core/src/internal/World.ts:719) sorts entities by numeric ID, builds fresh envelopes and retains payload references; relation groups retain recorded order and clone their source lists. Runtime skips transient resources and only saves resources actually present; undefined committed machine values are omitted.

**Pinned TS intentionally shares component/resource payload values.** [Runtime.ts:600](../../.references/bevy-ts/packages/core/src/Runtime.ts:600) says to serialize to detach. The unchanged #58 contract instead requires an independent save through explicit projections/codecs preserving arbitrary affine payload owners. This is already documented in #37/#58, not a newly selected divergence. A TS comparator must observe both raw aliasing and explicitly detached values; it must not manufacture a deep-copy guarantee for upstream `snapshot()`.

[Snapshot.parse:119](../../.references/bevy-ts/packages/core/src/Snapshot.ts:119) checks shape/version/positive integer IDs before Runtime validates names and values. Runtime stages validated component/resource values and graph/machine checks before mutation (1745–1814); then clears queued commands/events/transition/failure streams, advances the tick, despawns/spawns, restores allocator progress and supplied resource/machine entries (1816–1835). Omitted resources/machines retain current values; transient resources remain live. These are #59/#60 source obligations, not implemented save behavior or observed Bend runtime credit. TS positive integer IDs do not themselves establish Bend U32 bounds; existing #38/#59 owns the supported domain and freshness contract.

[Runtime.snapshot.test.ts:73](../../.references/bevy-ts/packages/core/test/Runtime.snapshot.test.ts:73) supplies upstream test definitions for JSON roundtrip, allocator progress, validation failure without mutation, added/despawned effects and transient omission. This investigation did not execute them. Upstream assertions are source references, not current project Node/JS/Native receipts.

## Rust architecture at the actual pin

Rust Bevy is `ad678262ce53b5d142fe49ee5e08caff6f00ab60`. [ReflectComponentFns:104](../../.references/bevy/crates/bevy_ecs/src/reflect/component.rs:104) supplies explicitly registered per-type read/insert/map/copy providers. [ReflectSerializer:57](../../.references/bevy/crates/bevy_reflect/src/serde/ser/serializer.rs:57) consumes a reflected value plus TypeRegistry; [custom_serialization.rs:13](../../.references/bevy/crates/bevy_reflect/src/serde/ser/custom_serialization.rs:13) requires registered type data for custom serialization. This supports declaration-bound providers, not implicit encoding of all Bend Type values.

At this pin [scene.rs:1](../../.references/bevy/crates/bevy_scene/src/scene.rs:1) exposes Scene/SceneList resolution and typed templates/patches. It is a scene construction architecture, not the pinned TS full Runtime save contract. No obsolete DynamicScene API is used as an authority here; Rust does not override TS error precedence or ticket save fields.

## Existing implementation versus delivery gaps

The bounded source inventory found no advertised basic-save facade or dedicated full #58 qualification receipt. `restored-row.bend` and column capture are live ownership restoration, not world save/restore. `experiments/s-capture/snapshot-control.bend` is a two-payload ownership control, not Snapshot export; similarly named optimization snapshots cannot count as #58 delivery. This is an inspected-path finding, not proof that no artifact exists anywhere.

| Contract | Reusable actual implementation/source authority | Still required / owning ticket |
| --- | --- | --- |
| Static validated-or-transient export boundary | TS Gate; nominal Bend Family/read capabilities | Declaration-derived persistence gate, matched legal/refusal applications; #58 with #46 prerequisite |
| Independent components/resources, same live owners | Explicit `C -> C & V` Data projection and captured owner-return machinery | Explicit per-family/resource saved representation and codec; actual save lifetime/post-mutation observations, no captured restoration closures in save; #58 |
| Basic names/version/IDs/allocator/transient omission | TS Snapshot/World export source; current World allocator/live metadata | Public basic exporter and complete independently authored two-schema Node/JS/Native observations, actual same-schema foreign Worlds; #58/#38 |
| Failure-free validation before restore mutation | TS parse+staging source; bundle-construction experimental reversible receipts | Full validation/error precedence and owner staging/cleanup, actual restore lifecycle/queue/allocator controls; #59 with #46/#38 |
| Ordered relation and committed machine extension | Adopted relation/machine owners and TS export/restore source | Explicit graph/machine save codecs, restore validation/order/cycles/clearing/omitted-entry behavior; #60 |
| Reached faults and quantitative delivery | Existing general runner/evidence infrastructure only | Included-transient/aliased-save reached mutant for #58; partial-restore/allocator for #59; graph-order/cycle/queue-clear for #60. No snapshot theorem or timing qualification obtained here |

The smallest next source seam is an exporter over one closed schema declaration: each persisted component/resource supplies an explicit owner-returning Data projection and validation-backed codec contract, while transient declarations supply omission metadata. The same declaration must determine the callable save/restore gate and stable name mapping. Compose these through actual checked world reads into `World -> World & SaveData`, leaving independent saved data and the same affine live owners. This is a source integration candidate under #58/#46, not a selected generic unknown algebra, wire format, reversible constructor policy or newly implemented API. `bundle-construction.bend` explicitly labels its undo receipts experimental; it cannot be promoted to universal descriptor validation.

Basic #58 may proceed before graph/machine save extension, but must label those fields unimplemented rather than claim the full TS Snapshot surface. No World reconstruction, generation/stale-handle policy, host serialization dependency or proof subject is selected by this research. Existing #58/#59/#60 own every listed gap; no extra ticket/plan or governing contract was created.

## Reproducibility

The companion `basic-snapshot-readiness-v1.json` records current root commit, exact inspected source hashes and pinned reference commits. Paths under `.references` refer to the primary-source checkouts in the root workspace and are not claimed to be tracked portable sources. Only these two research documents are delivered. Hash reads/document inspection are the only checks performed; no backend, checker, law, proof, timing or allocation experiment was run.
