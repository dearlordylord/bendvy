# Conversion caching: pure structure versus emitted ownership

Source-only proposal; no compiler edits, probes or performance measurements. Authority is the pinned `comp.ts` and SHA in RETURN-ABI.md.

## Repeated work below WIDE

The 247-word cutoff measures `Lay.ks.length`; it does not bound the nested `Lay.arms` graph or the number of conversion sites. `lay_eq` (992–994) serializes both complete nested layouts whenever object identity differs. Repeated structurally equal but distinct `lay_pack` results can therefore repeatedly expand shared nested sublayouts into JSON trees.

`val_to` (1645–1649) invokes that comparison at every conversion. When flat layouts differ, `val_arms` (1651–1675) generates every destination constructor arm and recursively converts its fields. BOX conversion generates every source arm in `val_box` (1678–1696), or every target arm and its constructor field reads in `val_unbox` (1699–1706). `emit_chain` invokes every branch body while generating C (2693–2706), even though runtime executes one branch. Nested sums can multiply generated branches independently of flat word width. A single-arm affine record alone does not establish this multiplicative case; its nested sums and repeated call/continuation conversions must be identified.

`emit_put`, `emit_args`, native calls and fork bindings repeat these operations at different sites. The entire definition emission is repeated whenever ownership/hot/static facts grow (2757–2793). This is a concrete regeneration mechanism, not proof it caused the retained deadlines. No expensive site count or elapsed-time attribution has been measured.

## Narrow semantically valid cache

A compile-local layout-pair equality cache is the lowest-risk candidate: ordered `(source Lay identity, destination Lay identity)` → exact current `lay_eq` Boolean. Use nested WeakMaps, retain the existing JSON comparison on a miss, and reset at `file_book` alongside layout caches (1323–1326). This preserves current structural equality, including constructor/field order; it must not equate layouts merely by widths or kinds.

Prerequisite: only publish completed layouts as keys. `lay_node` mutates its fresh `ks` while padding (981–989); recursive `lay_of` initially installs BOX before publishing its completed layout (940–951). Do not cache comparison against a layout still being constructed or later mutated. A documented immutability invariant or freezing completed layouts would make the requirement explicit; no such change is implemented here. Ownership/hot/static growth does not itself mutate layout structure, so equality results need no per-fixed-point invalidation once that invariant holds.

A pure conversion-plan cache could similarly retain only ordered arm names, field offsets, child layout pairs and conversion kind (`identity`, `box`, `unbox`, `reshape`). Its key must include both full layouts and the current book/constructor namespace; `lay_node` constructor layouts are book-dependent. Reset per `file_book`. Preserve existing ordered matching semantics and fail identically for unsupported pairs. Execute the plan afresh against each actual value and File state. Memoizing pure plan construction cannot remove required runtime branches or emitted instructions.

## Unsafe cache: generated Val/C or side effects

Caching generated conversion output by layout pair is incorrect, even within one fixed-point pass:

- `val_own` records borrowed-root ownership/lending depending on the actual word, destination and held status (1618–1633).
- `val_arms` accumulates per-arm roots and updates `brwl`/`own` (1660–1675).
- `node_fields` chooses peek versus take from actual `brwl`, constructor hot/static facts, tail position and spare handling (1561–1596).
- `ctr_build` depends on static images, constructor hot facts and available spare nodes, and consumes a spare (1047–1066).
- Fresh generated identifiers, emitted segment lines, uses, borrowed roots and allocation state are site-specific. Fixed-point iterations intentionally clear regenerated segments/images/literals/borrow analysis (2761–2767).

A fact-epoch number alone is insufficient: those local states change inside an epoch. Reusing emitted C would have to replay every effect with renamed words and current ownership facts, essentially performing emission again. Keep that separate from the safe structural cache.

## Actionable direction

First establish repeated *distinct-object* layout comparisons or nested conversion-plan construction at the actual continuation sites from the independent instantiated-width report. A compile-local equality cache and effect-free plan cache can preserve arbitrary Type payloads and source APIs. They offer no established speedup and do not solve intrinsic generated branch multiplicity. Changing output representation or suppressing required ownership conversions is outside this proposal.

## Current static result and exact duplication condition

The independent selected initial cohort reports maximum argument sum 37 and return width 48; no selected function triggers WIDE argument fallback. These figures rule out that fallback as an explanation for these selected sites, not all compiler sites. `inspect_unpack` returns Frame35 containing nested World/schemaStore/Column layouts.

A nested layout graph alone does not prove Cartesian emitted code. In `val_to`, structurally equal layouts stop immediately; boxing a field already BOX stops through `val_box`'s `arms === null` path. For one mismatched flat destination sum, `val_arms.ws(k)` converts each field inside that constructor's branch. If a field conversion itself expands a sum, that child branch generator is executed separately **inside each parent arm that contains it**. A repeated shared child across m parent arms with n emitted child arms creates m×n branch bodies; differing independent fields are additive, not multiplied unless their conversion is nested under another branch. Boxing has the analogous parent-arm→field→val_to→child-box expansion. Unboxing reads every destination arm through `node_fields` and then converts the fields through the same `val_arms` mechanism.

Consequently the needed diagnostic is an actual mismatched layout pair and per-arm recursive conversion path, recording equality/BOX early exits and repeated child pairs. Merely counting nested Column constructors or Frame35 words cannot establish duplicated continuations. An equality/plan cache can remove repeated structural planning; it cannot merge these site-specific branch bodies safely. No selected concrete Cartesian pair has been established by this note.
