# Query layout key mutation audit

A conservative global mutation epoch is a possible invalidation mechanism, but this audit does **not** establish that a per-object cache is semantically exact. Covering only the two evaluator `Var.v` writes is insufficient: lowering reads aliased arrays and quantities, invokes higher-order bodies, depends on binder depth, and can itself encounter mutable cells. No cache, compiler edit, executable diagnostic, speedup, proof or adoption is proposed here.

This is one bounded source audit for the #54 Native emission blocker. Branch base is root `da7a915bf8da31871dad941cf61eea8b4c91ebf2`; the earlier two-file #61 commit remains preserved. Only this research record changes. Existing traces, receipts, archives and reference files are immutable.

## Exact authority and scope

Pinned Bend reference commit: `a950fd683c0d76f09794078e6174fe98a1492876`.

| Read-only file | SHA256 |
| --- | --- |
| `bend2/comp.ts` | `32fb66e09f608ce9e4b173384bcfeec453db8c5bc96650e26ad861bef815a8d9` |
| `bend2/bend.ts` | `1d133151652b597a1a035c77c172475e6de096da37f3b9e3adc23c2f75bdfe49` |

Line numbers below refer to those exact original files. The audit inspected term constructors, lowering/forcing, parser publication, normalization/comparison, definition/template publication, compiler layout construction and memo lifetime. Text searches covered property/index assignments, compound assignments, array edits, Map/Set edits, object construction/assignment and all explicit `.v =` sites in the pinned `bend2/*.ts`. Searches were followed by source reads to distinguish comparisons, fresh construction, mutable published values and emitted runtime strings. This is not a whole-JavaScript effect analysis or an exhaustive proof of arbitrary caller behavior.

## Three different candidate cache domains

`term_key(LTerm)` is `JSON.stringify(tm, (k,v) => k === "s" ? undefined : v)` (bend.ts1192–1194). It observes structural property/array order and every remaining enumerable field; it does not beta/delta normalize. A cache of its input object must cover every reachable mutation of that lowered graph.

`term_key(term_lower(HTerm,d))` additionally observes forcing and calls `Let.f`, `All.B` and `Lam.f` with newly constructed binder variables (782–835). Binder depth `d` is part of the result even without mutation. A cache keyed only by HTerm identity would be wrong across depths. `lay_of` uses the post-`ty_adt` term and the default depth (comp.ts853–873,938–953), but a generic exported lower/key cache cannot assume that narrower callsite.

`lay_eq` compares `a === b || JSON.stringify(a) === JSON.stringify(b)` (comp.ts992–994). Its Lay graph is distinct from either term graph. Covering term mutations does not automatically cover layout mutations or preserve ordered JSON equality.

## Source-backed mutation and alias routes

| Route / exact sites | What changes or aliases | Relevance and required epoch coverage |
| --- | --- | --- |
| Constructors: bend.ts364–455; `ADT`407–409, `Let`379–381, `All`399–401 | Fresh outer records retain supplied arrays, Quant objects and term references; no deep freeze. | Outer identity is not a snapshot. Any externally retained `x`, `r`, `k`, `i`, `q`, `v`, child or Quant alias can change serialized content. Module-local epoch increments cannot observe such writes automatically. |
| `term_force`678–683; `term_lower`782–835 | Follows `Var.v`; composite branches allocate new records/child arrays but reuse `k`, `q`, `r` and Quant values. Default branches return the original object. Lowering invokes higher-order callbacks. | Lowered results are not universally detached immutable snapshots. Cache validity must include all nested aliases, callback/environment behavior and depth. Skipping lowering can also skip callback effects. |
| Parser term edits: `base.s ??=`1747, `tail.s ??=`1854; `out.b = true`2031; `parse_term_ns` `f.k = ...`2137 | Span attachment, erased Ref flag and namespace resolution modify existing term records. | `s` alone is removed at every depth by the replacer and does not change the key; `b` and `k` do. A conservative epoch may invalidate on all three. Publication-phase-only reasoning needs an explicit cache-start boundary. |
| Parser/loader definitions: `book.tlds[k].b = true`1016; `def.n`2456, `def.u`2463, `def.i=[]`2469/`push`2480; **`def.v = ...`2484**; indexed `tlds`2461/2523/2581 and `ctrs`2537; `order.push`2486/2539/2582 | Definitions, foreign metadata and book tables are installed or extended. | The parser `.v` assignment is a Def body, not a Var-cell write. It does not directly alter a serialized Ref node, but it changes subsequent `term_wnf`/type lookup and bodies captured by evaluation. A broad epoch spanning normalization must cover publication, not just cells. |
| `term_wnf` VAR-frame completion2795–2922: **`fr.l.v = ...`2919–2920**, `fr.l.i = -2`2921 | Replaces a share cell's value with weak-head result, possibly preserving an Ann; changes its state index. Children can be newly wrapped by `term_cell`. | Both stores must invalidate before any later observation. The source comment2777–2791 says source input nodes are not rewritten, but cells live in evaluated output/frames; compiler consumers can reuse those outputs. It is not a deep-immutability guarantee for all HTerms. |
| `compare_go`3077–3083: **`rhs.v = lhs.v`3082** after successful EQ | Redirects an evaluated share cell to another value graph. | This third explicit `.v =` site in bend.ts (the other two are Def parsing and VAR completion) must be covered. Sharing redirection can alter identities without demonstrating byte inequality; conservative invalidation need not decide whether bytes changed. |
| Template/check publication: `gen.tlds[o]`3731; `book.tmps[tm.k] ??= new Map`3758; `is.set`3766; `book.tlds[o]`3768/3770; `inst.e`3769 | Creates template instance maps and transient/validated definitions around recursive checking. | Map/object writes affect later evaluation. Epoch coverage must include nested `def_check` effects and exceptions; treating only top-level calls as atomic mutations can leave reentrant observations unguarded. |
| `book_valid`: new `book.tlds`3810, indexed writes3813/3879, `tld.e`3875 | Replaces the definition environment and attaches checked syntax. | Resetting an epoch/cache at an admitted validation/compile boundary might bound scope, but shared term aliases must not survive with stale entries. No such cache boundary currently exists. |
| Persistent environment/usage helpers: `list_set`, `pmap_set`/join (bend.ts500–588), higher-order closures693–779 | Construct linked/persistent records rather than mutating their existing nodes; callbacks retain environments/source bodies. | Fresh construction itself does not invalidate existing snapshots. Their referenced items remain mutable. Parser local stacks, body arrays, binder/display arrays and evaluation frame pushes/pops are fresh working containers, not direct writes into a retained term graph; escaped aliases or callback capture would need separate coverage. |
| Compiler term helpers: `probe`611–615, `term_force`644–648, `term_open`655–665; caches506–542 | Creates Vars; stores opened bodies, literals and derived term facts. `memo_gc`1838–1840 clears OPENS/USES/FOLDS/SPINES/CONSTS/LITS; `file_book`1324–1327 clears other maps and resets PROBES. | Cache/Map changes are not automatically term-graph mutations, but closures can read compiler state. No compiler host-side `.v =` term store was found; `.v =` in generated runtime strings is not a host HTerm write. Epoch lifetime/reentrancy must be explicitly bounded. |
| Lay construction: comp.ts970–979 `ks[at++]`, `Object.fromEntries(arms)`; `lay_node`982–989 `lay.ks.push` before memo return; LAYS sentinel948; `memo`1830–1835 | Builds fresh ks/arms and pads fresh node layouts before publishing; recursive BOX sentinel is installed in the map before descent. | In the audited internal constructor path, ks writes precede publication and no later Lay-field/arm-array write was found. Constants127–131 and nested published layouts are read-only in this source. Map sentinel/replacement is not mutation of the BOX/Lay object itself. Generic arbitrary object callers, future constructors, getters or cycles are outside this bounded fact. |

The explicit host `.v =` census is therefore: **Def parser2484, normalization cell2919, equality cell3082**. No other direct `.v =` assignment was found in pinned `bend2/*.ts`; assignments through aliases, arbitrary callbacks and external clients are not excluded by that textual census. Array pushes/index writes in parser local containers, compiler emission segments/spares/uses, runtime source templates and fresh layout assembly were classified separately rather than being called term mutations indiscriminately.

## Concrete missing-coverage cases

These are source-level counterexamples to an epoch incremented only at the observed Var stores, not executed tests:

- `const xs=[Lit("U32",1)]; const t=ADT("D",xs);` retains `xs`. Replacing `xs[0]` after a cached lower/key changes bytes with the same `t` identity and no module-local Var store. Changing the supplied `r` array or a reused Quant object has the same problem.
- A lowered composite reuses `tm.r`/`tm.q`, and a default leaf is returned by reference. Thus caching the freshly returned LTerm object alone does not make its entire graph immutable.
- Lowering the same Lam/All object at `d=0` and `d=1` produces different binder indices without any mutation. A depth-free identity key is insufficient even under a perfect mutation epoch.
- Exported higher-order constructors accept callbacks. A callback can change a captured local value without using compiler mutation helpers, or have an effect every call. An epoch cache hit could return stale bytes or suppress that effect. The pinned internal `term_higher` closures use persistent environment substitution, but the public TypeScript type imposes no purity/immutability enforcement.

## Exact remaining equivalence obligations

A global epoch could conservatively invalidate a per-object entry **only within a closed, completely intercepted mutation domain**. Before considering even an isolated implementation, all of the following remain:

1. Fix the cached operation/domain: LTerm JSON, HTerm lowering at a particular depth, or post-ty_adt layout-key only. Preserve exact field/key/array order, `s` omission, primitive JSON behavior and original error/exception behavior; do not replace structural keys with semantic equality or hashes.
2. Cover all reachable scalar/array/object/cell stores and callback/environment dependencies. Module-wide epochs at the three `.v` sites alone are not sufficient. Either prove the internal admitted domain excludes external aliases/callback effects or introduce complete mutation mediation; this audit selects neither contract.
3. Specify mutation ordering and reentrancy. A mutation during key construction must not produce an entry marked valid at a later epoch for an earlier snapshot. Record an entry only if the relevant epoch is stable across computation; abort caching on changes/exceptions. Preserve the original computation's effects on misses and establish that suppressing it on hits is allowed.
4. Key depth and any other context dependencies; cover reset, concurrent/reentrant books and cache lifetime. A global epoch needs collision-free/version-overflow handling and entries from previous compile/book scopes must not silently survive resets.
5. Preserve recursion/share-cell termination and temporary publication. BOX/Var sentinels and partially validated definitions cannot be skipped or cached as completed results. Do not alter existing memo cleanup to manufacture cache validity.
6. Assess memory and failure tradeoffs independently. Retained key strings/entries may increase heap and GC; a WeakMap does not bound live-key retention. Historical counters/profile intervals establish repetition/attribution only, not a speedup or safe optimization.
7. Any later compiler candidate needs independently authored finite old/new equality and mutation controls, actual full unchanged two-schema query/owner outputs, and separately reviewed bounded execution plans. Source audit alone gives no installed-ELF equivalence, Native acceptance or compiler adoption.

**Conclusion:** the internal post-ty_adt path is a narrower candidate than a generic term_key cache, but stable nested contents and complete mutation coverage are still unestablished. Global epoch invalidation is conditionally plausible; no source-backed complete epoch instrumentation or semantically exact cache is justified by this one audit. The actionable result is the specific coverage and depth/callback obligations above, not another compiler retry.
