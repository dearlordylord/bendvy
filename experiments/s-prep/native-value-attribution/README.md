# Native Main / cached-view construction attribution

Read-only follow-up to executed flat-journal v4 counters. `map.py` binds both original C hashes to the already executed site analysis and extracts original contexts. No C/runtime/compiler/source change, new measurement, timing acceptance or universal gate is claimed. Health is the independently recounted v4 source, not the joined ledger candidate.

| Actual escaping site | Motion | Health | Calls per measured phase |
|---|---|---|---:|
| Query owner restoration | spin_45, lines5552/5555/5561 | spin_45, lines5792/5796/5803 |1,048,576|
| Private fold row return | spin_65, lines7143/7146/7152 | spin_64, lines7453/7457/7464 |1,048,576|

Each site allocates Main, MainView and Cache. These two sites explain all2,097,152 Main and MainView constructors and2,097,152 of2,121,728 Cache constructors. Remaining24,576 Cache allocations wrap Ledger/LedgerView at dispatcher/frame boundaries; their complete static caller IDs and snippets are in `sites.json`. They are not another Main clone.

## Source and generated call edges

The query chain is `prototype_noaux_struct_idx_main` (query.bend:200) → actual `handle_client` → frozen continuation `prototype_noaux_done` (query.bend:197). Generated Motion spin_53 calls spin_45; its sole incoming spin call passes `id-1`, main column, owner raw array/frame and cached-view scalar fields. The continuation executes `Array.set(Maybe<M>, main,index,Some{owner})`. Here M is Cache<Position,PositionView> (Health: Cache<Vitals,VitalsView>). The handle-only measured callback does not invoke the supplied getter. Consequently this site's construction is restoration of an unchanged extracted owner, not raw-observer refresh. `sites.json` preserves static callers, which do not prove a dynamic stack.

The write chain's named emitted caller is `HELD_ADAPTER_PROTOTYPE_FLATFOLD_MOTION_STEP_0` → spin_65 (Health step→spin_64). Its source `prototype_flatfold_motion_returned` at held-adapter.bend:429–432 (Health:476–479) restores `Some{Cache{main_raw,main_cached}}` with Array.set. Main raw setters and cached patch callbacks produce updated flattened fields, but the escaping allocation occurs at this column restoration. Counting this as a setter allocation in addition to row return would double count. NativeFold/RowOwner constructors are absent from the executed allocator classifications: these transport records are already unboxed.

## Why Type raw and Data view both receive seals

`Cache<Raw:Type,View:Data>` itself is Type (cache.bend:3). Main owns an affine Array<U32>; cached views are Data. Cache.get explicitly duplicates only `+cached` (cache.bend:15), never Raw. At the two escaping sites, the generated C seals the newly constructed Main and MainView into Cache. Raw Array fields are also passed through rfc_seal; scalar cached fields pass through the same function but cannot create CTR redirects. The array term, Main term and view term must be distinguished.

The pinned compiler `bend2/comp.ts:1048–1065` emits heap allocation for escaping nonpacked constructors and invokes node_fill with `fl.hot.has(k)`. node_fill:1552–1557 seals every field of a hot constructor. facts_hot:1398–1440 propagates constructor-family hotness; an unresolved forced generic can mark `*`. Runtime rfc_seal:3875–3880 creates a one-count redirect for any unsealed CTR, without testing whether that object has actually been duplicated. A redirect therefore does not establish illegal affine sharing or a second raw owner. The existing separate zero-star experiment leaves the dominant per-row construction intact; removing the wildcard alone is not a solution to these allocations.

## Supported next seam

The first1,048,576 restoration triplets occur even though this concrete callback only selects handles. A source route that preserves the column owner in place for this declared read-only/no-get client could avoid extraction and reconstruction, provided it still preserves all generic callback/getter authority and arbitrary Type cases through a tested fallback. This is a distinct algorithmic route requiring fresh controls; it is not permission to assume arbitrary callbacks are identity. Flattening Main during the setter alone can relocate the same escaping constructor to row return and yield zero net constructor change.

No actual sharing-use path or RFC-data clone is inferred from static seals. This package attributes executed construction sites and explains the compiler/runtime mechanism; determining which redirects are later shared requires the separately instrumented keep/bump/drop origins, not this static map.
