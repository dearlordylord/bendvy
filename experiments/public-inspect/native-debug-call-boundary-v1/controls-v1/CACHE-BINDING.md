# Checked cache versus source binding

controls07 remains INCOMPLETE and immutable. Its baseline physical Book changed only cached checked `Def.e` strings; no build/runtime occurred.

Pinned `comp.ts:1184` converts `tld.e` with `term_higher`; `bend.ts:693–697` retains negative-index shared Var objects. `comp.ts:853–854` forces type cells through `term_wnf`; `bend.ts:2919–2921` fills their value and marks index -2. The comment at `bend.ts:2780–2790` documents this cache behavior. Thus complete checked-term byte equality is not an appropriate source-binding invariant.

The repaired gate retains full before/post checked-term artifacts and hashes. A separate binding SHA excludes only the cached `e` serialization. It enforces all source bodies `v`, types `T`, flags, arities, constructor tables, order, source bytes and exact specialization maps. Actual runtime verification also enforces every original TLD object and its original `e` root identity. This establishes stable source/mapping binding, not semantic equality of arbitrary cache mutations; compiler semantics are unchanged.

Portable controls use actual controls07 before/post artifacts to accept the documented cache delta and reject body/type/map/arity changes. Separate runtime-object controls reject replacing a checked root or TLD, and witness controls reject unrelated similar names. No original artifact is rewritten or normalized. Five consuming controls still need fresh reviewed execution; the full71 consumer has no execution admission.
