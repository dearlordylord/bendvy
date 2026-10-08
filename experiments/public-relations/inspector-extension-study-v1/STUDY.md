# #55 Inspector extension — source study

Source-only proposal for coordinator review, not a second implementation plan or policy approval. Actual source hashes and pinned reference commits are in source-joins.json. No backend, checker, reference execution or performance run occurred.

## Pinned surface

Inspector.ts:34–42 permits queries, resources, events, services, machines, transitionEvents, removed, despawned and relationFailures. Relations have no standalone Inspector category: outgoing/incoming projections and relation-presence filters belong to queries. No nextMachines or active transition view is granted. System.ts:363 gives machine get/is; :388 and :508 give transition/failure all/lagged. Runtime.ts:1130 reads committed machine values only; :1091/:1118 reads separate keyed streams. Runtime.inspect (:1695) advances only the inspector's successful-evaluation cursor/tick; Machine.check (:1167) reads without advancing either. Ordinary system reader positions and retention must remain unchanged. These are distinct obligations; “inspection never changes any clock/cursor” would contradict the reference.

## Current delivery and gaps

| Category | Existing seam | #55 gap / dependency |
|---|---|---|
| Machine current get/is | machine.CurrentView/current_view/is_current; machine-world.take closed resource lens | Safe independent read adapter into Inspector.Frame; no cursor/stream or marker operation needed. |
| Relation query/inverse | relation-query.Spec supports required/optional outgoing/incoming and four presence filters; relation-providers.ReadOnly returns detached handles | Current traversal takes Tx, not Inspector.Frame. Needs dedicated read projection/traversal preserving Inspector each/get/single/size errors/order and nominal authority; not permission to expose transaction write capabilities. |
| Transition events | machine-stream uses retained readers/positions and observe(id,tick) | Inspector cursor is not a system reader ID. Need non-retaining since/lagged projection and exact cutoff integration; no activate/complete/dispose call allowed from inspector. |
| Relation failures | Notice.RelationFailed in World Data event log | Adopted transport explicitly lacks keyed retention. Filtering append-only events is not keyed bounded all/lagged parity. Requires #43 stream integration/actual dependency qualification. |
| Requirement metadata | inspector-metadata.Resource only; tokens/names omit every other provision category | Machine declarations need named machine requirements and missing-requirement behavior through existing provision contract. Resource-shaped metadata must not silently stand in for a machine category. |

## Recommended next safe slice

Prefer a typed **committed machine-current read adapter** over a stream adapter. Closed schema provisioning binds the nominal machine token and trusted resource lens to a Cap.ValueRead<Inspector.Frame<…>, CurrentView<S,M,V>>. Adapter threads Frame/World/resources once, projects machine.current_view, and returns only detached Data; machine get/is wrappers expose no Slot/pending/previous/changed debug metadata. The same rank-two Inspector body can inspect repeatedly and participate in cursor-free check evaluation. This is an interface proposal, not Bend code or a numerical confidence claim.

Reuse machine-world.take's resource-owner-preserving lens semantics, never machine.next/queue/reset, structural_flush or run_marker. Machine values in the adopted family are Data; retain arbitrary affine component/resource owners unchanged. Missing machine provisioning follows the existing machine requirement contract before invocation; do not invent a new Unavailable-to-error mapping. The current-view type's Unavailable case is internal, not evidence that TS accepts missing requirements.

Acceptance for this finite slice: actual TS reference with two declared machines/two schemas; complete get/is observations before/after queued writes, structural barrier, actual machine marker, failed system rollback and repeated inspections; requirement refusals before invoking body; conditions both true/false without tick/cursor advance. Compare all machine pending/current metadata and world ownership/ticks/scheduled reader positions independently outside the public return value. Retain affine owner negative, cross-schema/undeclared/writable-category negatives and a reached wrong-current/pending-leak or inspection-mutates-state compiling mutant. Existing Inspector consumers stay source-current. Freeze full source closure/independent complete oracle before checker/backend plans. No production adapter or executable plan is authorized by this study.

## Boundaries not selected here

#48 later-key pending deletion/marker retention does not need choosing to read committed state; fixture observes the currently approved marker path and keeps that dispute explicit. #50 captured affine owners and #53 owned event fan-out are not needed for a Data machine-value projection, but are not solved or restricted by it. Same-schema foreign Inspector association and held-view/alias ownership remain unresolved #54 policies: fresh declared instances, local worlds and detached projections avoid selecting them. Relation/failure/transition streams remain separate #55 work; no hidden downgrade to append-only/no-lag streams. Parent prerequisites #44/#49/#43 still require issue/source-qualified fulfillment; adopted module existence alone does not close them.

Rust Bevy QueryState::as_readonly (query/state.rs:124) and World typed shared resource/change-tick reads provide architecture guidance: observation authority excludes writes, and entity/world identity remains explicit. They do not specify TS Inspector stream cursor behavior. Bend GUIDE.md:55–59/:185–194 and Base distinguish reusable Data from affine Type/Array owners; no mutable reference escape or World copying is valid. Trusted closed schema lenses are the existing authoring boundary, not a proof of arbitrary caller assertions.

Coordinator owns all public interface/coverage edits. After review, fold accepted findings into existing #55 coverage; no shared table or issue edited by this worker.
