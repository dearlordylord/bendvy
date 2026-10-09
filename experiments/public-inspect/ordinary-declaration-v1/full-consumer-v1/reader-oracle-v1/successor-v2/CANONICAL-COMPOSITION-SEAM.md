# Full23 canonical query composition — smallest compatible seam

Source-only proposal; root owns core integration. No compiler/runtime checks, new contracts, laws or policy. Basis: existing canonical inspector-query/projection and check modules versus frozen full-consumer-v1/stage query, selection, traversal, families and owner-carrier. Reference commits: Rust Bevy ad678262, Bend a950fd68, TS3040a3b2 (inventory third).

## Preserve existing callers

Canonical `ReadQuery<H,S,V>` returns `Q.Row{entity,value:I.Value<V>}` and has one-family Required/Optional/Added/Changed mode. Stage `ReadQuery` instead returns `Row{entity,data:V}`, where V may be a nested Product of Access values or arbitrary detached Data. Its Selection is a pair of match/project operations over H. These nominal/result shapes cannot be fixed by import relocation or wrapping a Product in invented shared Added/Changed flags.

Keep current ReadQuery/Row/Selection/grant/each/get/single/single_optional definitions/signatures compatible. Add the following types in existing owning modules (names provisional, shapes exact; Selection below abbreviates DeclaredSelection); do not export owner-carrier types:

```text
inspector-query-projection:
  DeclaredSelection<H:Type,S:Data,V:Data>{matches:H→Handle<S>→H&Bool,
                                       project:H→Handle<S>→H&V}
  Predicate<H:Type,S:Data>{matches:H→Handle<S>→H&Bool}
  Product<A:Data,B:Data>{left:A,right:B}
  empty<H,S>() → DeclaredSelection<H,S,Unit>
  pair(left:Selection<H,S,A>,right:Selection<H,S,B>) → Selection<H,S,Product<A,B>>
  constrain(source:Selection<H,S,V>,predicate:Predicate<H,S>) → Selection<H,S,V>
  both(left:Predicate<H,S>,right:Predicate<H,S>) → Predicate<H,S>
  map(source:Selection<H,S,A>,name:A→B) → Selection<H,S,B>

inspector-query:
  ProjectedRow<S:Data,V:Data>{entity:Handle<S>,data:V}
  ComposedReadQuery<H:Type,S:Data,V:Data>{each:H→H&List<ProjectedRow<S,V>>,
      get:H→Handle<S>→H&Result<LookupError,ProjectedRow<S,V>>}
  grant_composed(selection, trustedWorldRead) → ComposedReadQuery<H,S,V>
  each_composed/get_composed/single_composed/single_optional_composed
```

All effects return H once; lists/results/products are detached Data. Store/Rest/Payload remain arbitrary Type. `map` changes the detached display result, never the stored payload owner. H is abstract in the actual gameplay callback; only trusted lowering constructs these grants. No new user-authored raw World/provider or metadata catalogue.

## Concrete lowering and compatibility

| Existing stage route | Canonical addition/dataflow |
|---|---|
| families.inspect_slot | family→Required/Optional membership via C.get_allowed/Col.present; successful projection via C.get. Produces Selection<Inspector.Frame,S,C.Access<V>>. |
| inspect_with/without | family→presence Predicate (Present/Absent). No payload projector invocation for membership; affine payload take/put still returns the owner. |
| inspect_filter | presence predicate AND existing C.lifecycle→compose.lifecycle_selected against Inspector.Frame.cursor. Added/Changed remain per-family predicates, not synthetic composite flags. |
| check_slot/with/without | same generic selection algebra bound to Check.Frame; no lifecycle factory or artificial cursor in Check. |
| traversal.inspect_world/check_world | trusted handles+valid operations returning the respective existing Frame. Enumerate via canonical W.handles; lookup uses W.valid. |
| query.grant/scan/get | generic matched projection behind ComposedReadQuery; recursive scan result/carrier stays private and unwraps to existing Frame at the boundary. |
| ordinary-selections | derive these operations from the same nominal Binding.family/identity; declaration diagnostics follow the composed clause tree. Keys/names are not runtime authority. |

Pair matching/projecting is left-to-right; match short-circuits before right, projection only follows whole match. Constrain tests source then predicate and preserves original projection; map preserves original membership. `each` preserves W.handles order (current tail scanner is ascending live IDs), reversing only the private accumulation. Zero-field empty selection includes every live entity; target get still validates namespace/liveness first. `get` returns existing MissingEntity before membership, then QueryMismatch on mismatch; optional family absence is a successful C.ComponentAbsent, not a missing-entity success. Single retains exact NoEntities/MultipleEntities(count), optional-single retains None/Some/MultipleEntities. No TS numeric-handle or Rust traversal-order override.

The internal owner-carrier can be rebound to canonical nominal Selection/Predicate/ProjectedRow/ComposedReadQuery and reused privately for Inspector and Check. It must not become an application-visible owner hierarchy, and migrating its imports alone is insufficient. A generic H kernel shared by Check and Inspector avoids duplicating their composition algorithm; trusted family/world factories stay in their respective existing modules. Existing single-family APIs need no adapter and retain lifecycle metadata; optional leaf conversion to composed results must explicitly choose `I.Value<V>` or `C.Access<V>`, never silently discard old flags.

## Authority and acceptance

Rust query/fetch.rs tuple QueryData and query/filter.rs With(158), Without(273), Added(809), Changed(1068) support the composition/filter distinction; system/query.rs get(1723)/single(2243) supplies structural error concepts. Rust read projections borrow owners; Bend cannot copy arbitrary Type and instead threads owner-returning take/project/put (pinned guide quantity rules). Existing native same-world handle, cursor and error contracts govern. TS System.ts QueryHandle530–557 supplies inventory for each/get/single/singleOptional, not ownership or identity policy.

Implement this one source delta with the existing full23 consumer as migration subject, retaining all observation fields and current leaf callers. Needed affected controls: old leaf compatibility, both-schema/token confinement, read-through-write refusal, owner duplication, reached get/selector/lifecycle error paths, complete full23 canonical JS/Native and reached reader/clause models. Reuse unchanged artifacts only where byte/source applicability holds. This is the missing generic source seam, not backend feasibility proof, debug-enable completion, full #54/#56 acceptance, or an alternative plan.
