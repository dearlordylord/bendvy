# Source-only owning-definition followup

Smallest candidate: change only `inspector-query-projection.constrain` construction so its membership closure captures the source matches function, rather than the entire `DeclaredSelection<H,S,V>` (which also carries its project callback). Reuse existing `predicate_both` and `Predicate`; do not remove or scalarize H. Proposed body, unimplemented and unchecked:

```bend
  DeclaredSelection{predicate_both(~H,~S,~Predicate{matches_field(~H,~S,~V,source)},~predicate),project_field(~H,~S,~V,source)}
```

The existing body stores `constrained(~H,~S,~V,~source,~predicate)` as matches and the same project function separately. `constrained_target` invokes source.matches, then `predicate_right`; `predicate_both_target` invokes left.matches, then that identical `predicate_right`. False returns the identical owner immediately; True invokes the identical predicate with the returned owner and target. Projection remains separate and unchanged. Setup only extracts existing function fields; no new read, validity check, projection or callback execution. Runtime membership still consumes/returns arbitrary affine H exactly once and preserves left-first short circuit, nominal S, V output, authority boundary and physical work. Full47 declaration calls in `family-witness.bend` lines90/96 and `runtime-declarations.bend` lines15/21 exercise this construction, including nested Access products and recursive InspectOwner/CheckOwner.

Expected generated effect is narrower matching closure and no V/unused project callback in the `constrained` specialization; existing `predicate_both` still carries H. It may reduce type term/key and function layout material in the diagnosed constrained family. This is a source-backed hypothesis, not measured improvement; exact compiler closure lowering may erase equivalent fields already, and generic H/World layouts remain. The dominant composed_lookup_matched and other owners are not claimed fixed. No prototype/backend/check was run while Native build93926 owns the queue.

Do not remove owner-carrier's recursive Link merely because it is never constructed in the finite fixture: the copied CLI `lay_of` checks self-recursive constructor domains and returns BOX. Removing the Link can expose the entire affine Frame/World representation instead of narrowing it. `inspect_predicate` itself needs to unpack, execute the existing frame predicate, and repack the same owner. Predicate/selection abstractions must remain Type; Data conversion or duplicating H would weaken the accepted contract. Pair.project genuinely needs both projected values, while pair.matches can be narrowed independently later; no broad multi-function package is proposed. `check_matches`' nominal-family parameters retain setup provenance, even though its presence helper uses built-in Col.present; do not bypass public family binding to chase layout size.

Diagnostic measurements are partial copied compiler inclusive observations, not stock timings or proof of causality. #54 remains open until a separately reviewed candidate actually preserves full47 source/runtime/authority and fits unchanged native budgets. Query authority remains governed by the existing query/debug tickets, not a new contract.

Current public/stage bindings:

- `inspector-query.bend` current SHA `7a4c90e0f1e63d6a89aea256bd96c874758db73865dad02481a32c1dded8b58d`; diagnostic stage byte-equal: `False`.
- `inspector-query-projection.bend` current SHA `422efbb7c19e8091a77f7e90e7f4e3d95474ae41d46e934b270b89638cd5f561`; diagnostic stage byte-equal: `False`.
- `inspector-query-families.bend` current SHA `020a8de48df12369c8709d10d15f0c3d22dcf8a9fb76f3af238ea4a4304edeb8`; diagnostic stage byte-equal: `True`.
