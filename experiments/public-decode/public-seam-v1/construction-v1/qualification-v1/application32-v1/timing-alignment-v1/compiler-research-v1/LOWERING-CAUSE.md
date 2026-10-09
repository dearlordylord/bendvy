# What the actual lowering diagnostic does and does not localize

Source-only follow-up to the retained498ddab8 diagnostic. No compiler edit/child, new ABI, threshold or workload variant. LOWERING-PAIR-JOINS.json binds the complete retained3158-row cost artifact, initial layouts and exact compiler/fixture source; it records the actual pair comparison, not an inferred generic width.

## Concrete representation mismatch

`owner-carrier.CheckOwner` is recursive, hence BOX. Its stored constructor node contains a Frame24; `check_unpack~0` returns instantiated Frame34. The **only differing nested field** is World field7: stored R is BOX1, actual runtime-owners.Resource is flat11. World.store is structurally equal on both sides: Store12, containing the same four four-arm Column layouts.

The compiler path is precise: boxed match (`emit_mat`,2677–2680) calls `node_fields`,1561–1596, obtaining the constructor's stored Frame24. Returning that frame through `emit_put`,2115–2123, invokes `val_to(Frame24,Frame34)`,1645–1649. Reshape descends through single-arm Frame and World; structurally equal Store immediately exits through lay_eq. Only Resource BOX→flat is unboxed. Resource has one constructor, with Array BOX, single-arm Extra2 and single-arm Diagnostic8. Its two Bool fields do not imply a branch expansion merely because their layouts have two arms: equality/primitive-layout exits still apply.

Packing reverses this boundary: `check_packed` constructs CheckOwner, so `emit_ctr`,2276–2289, chooses generic `lay_node` when the target is BOX and converts its actual Frame34 field to Frame24. This boxes Resource while leaving the equal Store unchanged.

Therefore **this recorded pair does not produce Cartesian Column conversions**. A real generic-versus-instantiated mismatch is not enough to explain 210,795 val_to calls or a million emitted lines. Changing constructor storage to instantiated layouts would additionally alter global constructor/node agreement and ownership ABI; it is neither justified nor a narrow cache fix.

## Where repetition is actually evidenced

Nested `check_target~32` and `~12` each attribute20,076 body calls,210,795 val_to calls and1,107,511 file_push calls (~28.8m UTF16 characters). The cache already has almost no misses there. Root `query.grant~16` / `lookup_valid~6` intervals around2.1s CPU and nested fl.def counters refer to different scopes: do not attribute nested generated-text volume exclusively to the tiny grant body or sum these attribution fields as independent timed work.

`check_target` applies its retained operation between recursive-owner unpack and pack. `emit_fuse`'s non-flat path recursively emits that callee body with `def:k` (2125–2140); `emit_body` may choose it for optional once-use tail inlining (2498–2514). `emit_mat` emits each arm's body under a copied local binding/spare state (2681–2690). If an inlined callee matches a Column and its continuation then matches another, the continuation's code can be reproduced inside each first-arm body. That is a concrete **continuation duplication mechanism**, distinct from additive field conversion in val_arms.

However the retained cost rows contain no callsite, mismatched conversion pair, branch ancestry or instantiated operation body. The initial layout report contains signatures, not that body. They do not establish which exact operation/arm repeated the continuation, whether the optional once heuristic triggered there, or whether flat native specialization/body generation dominates. `flat_call` also selects native/spin paths independently; disabling one optional inline condition does not suppress those.

## Bounded corrective direction, not an adopted fix

The existing non-flat call fallback already performs `emit_args`→`emit_jump` with segments and return-layout checks. An experimental **outline boundary at the optional once-use non-flat fusion decision** could reuse that existing ABI, avoiding source/API/carrier changes, new width thresholds or generic node-layout changes. It would address body duplication only if those repeated sites actually use this decision. No evidence currently proves that premise, so no further emission is recommended solely from these counts.

Risks/required reached controls: borrowed-root ownership/lend fixed point, affine transfer/sink once, recursive unpack, fork continuation results, static/runtime closure paths, unchanged complete Inspector query order/authority/error/rollback and whole JS/Native oracle. Existing small full-C equality controls for the layout cache do not qualify an outlining change. A focused source-backed branch/callsite attribution should establish the responsible expansion before modifying this heuristic; another unchanged deadline probe would not answer it.

Result: exact node mismatch is localized, and its alleged Column Cartesian cause is ruled out for this pair. The full3158 counters support excessive generated-text work, but are insufficient to select a95%-confidence correction. Preserve all arbitrary Type source APIs and the complete subject while investigating the actual continuation duplication boundary.
