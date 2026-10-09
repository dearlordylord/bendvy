# Wide C return ABI: source-only assessment

Status: investigation, no compiler modification or execution. This does not attribute the two retained 30-second C-generation deadlines to return layouts.

Authority: pinned `.references/bend2/bend2/comp.ts`, SHA256 `32fb66e09f608ce9e4b173384bcfeec453db8c5bc96650e26ad861bef815a8d9`. Line references below identify that source, not the installed successor compiler. Instantiated widths belong to the separate static-probe investigation.

## Actual distinction

`lay_of` already boxes any datatype layout wider than 247 words (940–951). `fun_of` additionally boxes each multiword argument when the **sum of argument widths** exceeds 247 (1174–1193), but keeps its nonempty return layout. Thus a return can be multiword/flat while the same call's arguments are boxed; this is not evidence that a return itself exceeds 247.

An explicit function-return ABI policy could potentially box such returns without changing Bend declarations or payload types. It must remain separate from datatype storage layout: changing `lay_of` globally also changes arrays, constructor fields, and output descriptors.

## Paths already designed for a distinct return ABI

- `emit_open` derives segment return and argument layouts from `fun_of` (2153–2168).
- `emit_put` converts the produced value to destination/segment layout with `val_to`, owns the converted words, then emits the exact return width (2115–2123).
- `val_to` boxes/unboxes mismatched layouts (1645–1649). `val_box` builds the actual constructor representation and transfers field ownership via `val_own`; `val_unbox` reads constructor fields, not an invented wrapper (1678–1706).
- Direct native/spin calls allocate output slots from the callee return layout, and publish through `emit_put` (2125–2151, 2170–2195).
- Tail calls with incompatible structured layouts are converted into a bound call instead of jumping with incompatible registers (2498–2514).
- Sequential/fork continuations use callee return width for task offsets and received-value layouts (2542, 2576–2581). `bind_uses` can unbox an owned boxed result before multiple uses; unused owned results are sunk (1791–1810).
- Dynamic closure application and foreign wrappers already use BOX returns (2227–2241, 2413–2415, 2774–2782, 2808–2810). A new ordinary-return policy must not override their existing conventions.
- Return register capacity is derived from all segment return layouts (`WL_RESW`, 2831–2843). Constructor arity remains derived from `lay_node`, independently (2812–2825).

These paths make an internal ABI adaptation plausible. They do not establish correctness of a one-line patch: boxing changes ownership/borrowing discovery, allocation, continuation liveness and fixed-point generation. Those need complete affine, skip/error/rollback and fork controls, not only a scalar output test.

## Concrete unsafe naive change

`show_main` builds `SHOW_DESC` from `lay_of(main.T)`, including flat field offsets and the boxed flag (1851–1915). It does **not** consult `fun_of(main).ret`. If a new return rule boxes a multiword pure `main` while leaving this descriptor flat, the root renderer receives a boxed constructor word but interprets it as flat fields. The descriptor and actual root return ABI must agree, or `main` must retain its old ABI. The current common String main is already BOX; that does not remove the general unsafe path for a multiword pure main.

Do not change stored constructor descriptors merely to fix this root mismatch. A targeted root adapter or descriptor built against the actual root return layout is the bounded direction to investigate.

## Existing primary-source regression examples

These are checked-in compiler regression fixtures with expected outputs, not tests rerun here:

- `tests/run/ctr_at_position.bend`: closure `Some` tail into BOX return, boxed Result/list positions; expected `189`.
- `tests/run/fork_leaf_result_loop.bend`: generic boxed Result return versus flat record loop, two frames per iteration and fork/bang interactions; expected `4000`.
- `tests/run/fork_held_family.bend` and `fork_shared_flat.bend`: an open-index family result is BOX while a closed type is flat; held/join conversion controls.

They provide relevant existing coverage to extend, not evidence for wide ordinary affine returns under a new policy.

## Next narrow evidence needed

Combine the separately derived instantiated widths with the above ABI paths. Determine whether large retained return values materially enlarge continuation parameters at the observed source sites. If so, an explicit internal `fun_of` return-layout policy plus root-layout agreement is a candidate compiler fix; no source carrier/API change is inherently required. The two current deadlines alone establish neither that cause nor a speedup. No compiler implementation, adoption, backend retry, dependency or public contract change is proposed by this note.
