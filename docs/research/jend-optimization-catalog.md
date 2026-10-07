# Jend optimization catalog — actionable source patterns

Research only. Read the actual [catalog](https://jend.leeeet.dev/llms.txt), searched its definition endpoint and followed implementation links. No installs, executable edits, checks, builds, timing or performance claim. The catalog describes a definition search service rather than a compatibility guarantee. Its search results include versioned packages, content-addressed package aliases and a Base snapshot; search summaries alone are not evidence of implementation behavior.

## Additional candidates

| Actual source | Mechanism seen in implementation | Bendvy application and limit |
|---|---|---|
| [DynamicArray.update_owned](https://jend.leeeet.dev/src/bend-collections-laws-containers@1.0.0.0/src/containers/dynamic_array.bend?def=update_owned), `update_checked_owned`, `update_found_owned`, `update_put_owned` | Bounds check precedes `Array.swap(Maybe<&1,T>,…,None{})`; the callback consumes actual Type owner and returns `T & R`; the returned T is reinstalled before returning the array/result. Invalid index never calls the callback. | Concrete model for scoped component projection/update and guaranteed restoration without Data-only narrowing or escaped holes. Existing Bendvy captured/restored-row already follows this principle; compare generated transports rather than blindly introducing another wrapper. It does not supply ECS transactional rollback: previous owner/stamp must still enter the inverse journal. |
| [DynamicArray.swap_owned](https://jend.leeeet.dev/src/bend-collections-laws-containers@1.0.0.0/src/containers/dynamic_array.bend?def=swap_owned), `swap_checked_owned` | Replacement returns previous optional owner; refused replacement preserves incoming owner in `Rejected<T>`. `set_owned` intentionally releases the old value. | Use swap-style operation for ECS inverse capture, never set-style disposal when rollback requires original owner. Test full affine payload and repeated replacement/failure. |
| [Intrusive list API](https://jend.leeeet.dev/src/bend-collections-laws-containers@1.0.0.0/src/containers/intrusive_doubly_linked_list.bend), `next`, `remove`, `fold_left` | Algorithms quantify over `~S:Type` and bind static storage accessors, e.g. `S -> N -> S & Maybe<N>` and setters returning S. [Implementation](https://jend.leeeet.dev/src/bend-collections-laws-containers@1.0.0.0/src/containers/internal/intrusive_list.bend) threads the actual owner through these accessors and callbacks without inspecting S. | Strong pattern for representation-independent metadata/storage operations: compile-time storage adapter selects layout, while generic caller does not pattern-match representation constructors. This avoids adding variants to the caller-visible abstract type. It is not private exported constructors, an existential package, or a retrofit that makes current raw World constructors compatible automatically. Static templates still need specialization/checker/generated-code assessment. |
| [IntrusiveLinks.Links](https://jend.leeeet.dev/src/bend-collections-laws-containers@1.0.0.0/src/containers/intrusive_links.bend) and its accessors | Separate U32 arrays for next/prev/head, owner-returning indexed reads/writes and zero sentinel. | Additional SoA example for metadata. Do not adopt its node membership order as ECS query order, replace real namespaces by a sentinel, or claim its adapter proofs establish Bendvy laws. Its IDs/capacity differ from Bendvy max entity ID. |
| [DynamicArray reserve/to_list](https://jend.leeeet.dev/src/bend-collections-laws-containers@1.0.0.0/src/containers/dynamic_array.bend) | Maintains capacity alongside depth; checks cached capacity before computing maximum power-of-two capacity. Data enumeration reads by index, threads array and constructs list, avoiding structural Array destructuring. Growth uses `ANode{old,empty}`. | Maintain allocation capacity as representation metadata, distinct from cached validity; inspect elimination of Nat/depth recomputation in lifecycle/packed storage. Avoid structural traversal in hot paths because pinned JS array-node destructuring slices halves and joining concatenates them. Growth itself may still copy; measure it separately. Enumeration is Data-only and cannot be copied as an owning Type component read. |

The previously identified [NodeStore](https://jend.leeeet.dev/src/bend-collections-laws-containers@1.0.0.0/src/containers/balanced_search_tree.bend?def=NodeStore) and [Bitlist](https://jend.leeeet.dev/src/bend-collections-laws-containers@1.0.0.0/src/containers/bitlist.bend) remain first candidates; [packed migration note](packed-live-tag-flags.md) records their relevant limits. Generic tag queries must still invoke the legal `C -> C & V` projection; presence masks cannot silently remove its effects.

## Representation abstraction finding

The catalog did not establish a package-supported private datatype/export mechanism that solves current World/Column raw-constructor compatibility. Actual DynArray and Links source declares ordinary public datatypes. The useful abstraction is **generic code parameterized by the owning storage type and static accessors**, not hiding a concrete constructor merely by putting it in another module. Base opaque File/Socket search results are kernel/effect laws, not permission to introduce opaque runtime laws for ECS or evidence that arbitrary user modules can construct such values safely.

For future migrations, retain legacy concrete APIs; add an adapter-oriented core seam whose gameplay boundary remains abstract/rank2. Choose packed/indexed storage in provider construction, thread its actual owner, and avoid full conversions at each getter. This requires the existing confinement negatives, actual closure execution and owner/rollback controls; catalog examples cannot approve a production representation or waive old consumers. Exposed raw constructor users still require an explicit compatibility contract.

## Pinned language/runtime comparison

Source syntax uses familiar `~T:Type`, `Maybe<&1,T>`, `Result<&1,…>`, `Array.swap`, owner-returning tuples and static template callbacks. These forms are present in Bendvy and [pinned Base](../../.references/bend2/bend2/base.bend), but **package compatibility remains untested**. DynamicArray comments name Bend2.0.16, while our pinned compiler is `a950fd683c0d76f09794078e6174fe98a1492876`; catalog Base search results name `Base@0ad47fc04464`, a different source identifier. Use our pinned compiler/Base as authority, not catalog snippets.

Pinned [compiler](../../.references/bend2/bend2/comp.ts) `arr_op` lowers native indexed operations to flattened block reads/writes. JS operations223–227 use direct ordinary-array indexed mutation with modulo wrapping; array-node elimination281–282 slices halves, and runtime `array_node`6007 concatenates arrays. Therefore bounds checks must precede Base accesses, and logical tree shape is not a reliable runtime cost model. No source comment about constant native access implies that whole ECS owner transport is free or that JS/native achieve accepted speed targets.

## Retrieval receipt

Direct `curl -L --fail --max-time 12` fetched actual bytes; web-tool open of catalog failed. Search queries covered ownership indexed updates, SoA storage, abstract storage, intrusive adapters and opaque constructors. Package documentation paths `docs/DYNAMIC_ARRAY_OWNERSHIP.md` and `docs/INTRUSIVE_LIST.md` returned curl22 and were not used as evidence. SHA256 values below identify complete fetched files, not authenticated repository/compiler commits.

```text
llms.txt                         9d79cfd9d2a7172113a89bdf020524cb89de8622fd5049d57f73c127a616a98e
containers/dynamic_array.bend     343cc708622ab49a0feb50fd0ac18293dd1f345c12326e37ee5b4e0cee94f1c3
containers/intrusive_doubly_linked_list.bend
                                 62574fcc1e0ccfc6dddf016ddf95c50905933e7e18b74ba2c87e1f5071a733e8
containers/internal/intrusive_list.bend
                                 96b7825ec9f9ca496b71151c75a749f04f50d47c34f9548898d3c005d09a2cf2
containers/intrusive_links.bend   e5e7ae9db3b9975594d5a14d5847f9f5674fcaaf641ec3eb8df36acf33e5b8e7
```

All container paths above use `bend-collections-laws-containers@1.0.0.0`. Freeze proposed equivalent workloads and source before profiling; measure CPU/self+inclusive allocation/GC before and after, separately from unchanged paired default/prepared gates. Retain full-output controls and larger-world scaling; no imported proof, benchmark assertion or package score establishes Bendvy acceptance.
