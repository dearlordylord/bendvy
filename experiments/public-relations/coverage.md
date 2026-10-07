# #42 public relation coverage

Initial research scope below; subsequent version-bound Bend experiments are listed separately. Sources are pinned by `run.py` against the tracked three-reference manifest and actual bytes. All reference operations use the public bound Game API; internal sources explain observations.

| Surface | Actual reference witness | Implementation obligation / limit |
|---|---|---|
| Descriptor.Hierarchy / Descriptor.Relation | Descriptor fields, pair object, Symbol.for keys; two roots | One authoritative source target per descriptor; many incoming sources. No public edge-payload constructor or exclusive-incoming option. |
| Relation read/optional/readRelated/optionalRelated (bound Query aliases) | Required/optional outgoing/incoming cells at every checkpoint | Empty inverse makes optional slot absent; `relatedSources` on live target instead returns success with []. |
| withRelations / withoutRelations / withRelated / withoutRelated | Complete matching ID vectors at every checkpoint | Predicate membership must agree with outgoing/incoming state. |
| commands.relate | Queued-before/barrier-after, repeat, replacement, general cycles | Same-source replacement removes old inverse, appends to new inverse; repeated same edge does not duplicate/move membership. |
| commands.unrelate | Repeated removal, absent edge, missing source999 | Benign, no relation failure; preserve unrelated component owners. |
| Command.relate draft builder | Single and repeated staged edges on spawned owners7/8 | Spawn then staged relations; repeated source relation replaces in declared order. |
| Deferred FIFO and reserved future targets | Relate7→9 before spawn9 fails; later relate7→9 succeeds | Do not validate all commands against only batch-start/batch-end liveness. |
| lookup.related / relatedSources | Full source/target results/errors for every allocated ID | MissingEntity versus MissingRelation; preserve inverse insertion order. |
| Source replacement/inverse order | Initial [3,2], replacement [2]/[3], re-add [2,3] | Never sort inverse IDs; source iteration order and inverse arrival order differ. |
| Protected inverse read/retention | No inverse cell `.set`; retained inverse [3,2] survives replacement | Rust derives a private target field but explicitly exposes `collection_mut_risky`/`from_collection_risky` escape hatches with invariant warnings; use ordinary hooks/readonly access as the architecture, not a universal Rust confinement claim. Bend planned read-only Data views have no writable inverse provider. This is not a universal JS-erasure authority proof. |
| General relation cycles/self | 1→2→1 succeeds; self1→1 fails | Ordinary graph need not be acyclic. Standard constructors always allowSelf=false. |
| Hierarchy relation/traversal | parent/root/ancestors, breadth/depth descendants, childMatches/descendantMatches skipping rows | Distinct hierarchy policy belongs with #43 integration; no ordinary-relation DAG restriction. |
| commands.reorderChildren | Ordered success [5,4], six hierarchy errors, later successful reorder [4,5] | Complete error records observed; no new hierarchy policy inferred. |
| Missing source/target + self failures | Ordered exact vectors after barrier; prior graph unchanged | Source missing precedes target missing, then self; failure is structural, not SystemFailure. |
| Failure publication | Per-descriptor complete records including operation/source/target/error | Streams are keyed per descriptor and bounded; no universal cross-descriptor arrival-order or unlimited retention claim. |
| Failed system | Fx.fail('boom'), then snapshot/barrier | Discard staged relation command; SystemFailure remains distinct from relation mutation failure. |
| Delete source/general target | Source3 removed; target2 removed; surviving components retain all cells | Remove outgoing and incoming links; ordinary incoming owners survive target deletion. |
| Delete hierarchy target | Root1 recursively removes4/5/6; independent7/8 survive, links cleared | Keep cleanup hooks/observations and component clearing; linked cleanup is not ordinary relation deletion. |
| Delete then relate | Delete9 then relate7→9 produces exact failure | Failed later operation does not resurrect target/edge. |
| Same-schema foreign runtime | Actual separate runtimes, colliding IDs, source from first used in second | TS numeric ID aliases second-world ID1; keep separately from approved Bend MissingEntity/unchanged-queue namespace policy. #38 production identity remains unresolved. |
| Schema/undeclared/write-through-read/affine clone negatives | Public TS type signatures inspected, not checked by an installed TS compiler | Required fresh Bend negatives at actual future relation/provider boundary; Node erasure is not a negative checker. |

The main trace has 38 observations per nominal root, complete current Payload cells (four per owner), ordinary forward/inverse state, selection vectors, every allocated-ID lookup, hierarchy traversal and exact structural failure objects. Five additional foreign observations per root retain both worlds' complete two-cell owners. At the initial research receipt, Bend execution was unobserved. Subsequent finite JS/Native traces, mutants and access controls are listed below; default regression, proofs and performance acceptance remain open.

## Experiment-only continuation (separate from the reference-only research)

The earlier **unexecuted** statement above describes the initial research receipt,
not the subsequent prototype receipts. None establishes production #42 completion.

| Slice | Exact receipt | Observed scope |
| --- | --- | --- |
| Independent slow graph / maintained inverse | `graph-1791355385681236770` | 92 literal checkpoints/backend, two schemas, two descriptors and three-node cycles; three reached mutants. |
| Actual arbitrary-Type World/Commands transport | `world-1791355908877103866` | 18 complete owner checkpoints/backend; depth0–3 Arrays; namespace-authored foreign rejection and missing apply-time refusal; three reached mutants. |
| Registered rank2 relation writer / inverse reader | `provider-1791357692291434776` | Ten complete owner/inverse/retained checkpoints/backend against actual TS; six type-refusal controls; three reached mutants. |
| Entered-frame ordinary/linked cleanup | `cleanup-1791358616869161568` | Historical24 complete owner/live/pending/edge/removal/despawn checkpoints/backend against actual TS and slow model; eight finite type refusals; three reached mutants. Accepted descriptor-cycle duplicate notice retained. |
| Hierarchy reorder | `reorder-1791359918644796394` | 52 complete records/backend, nominal hierarchy provisioning, error priority/target, registered FIFO/barriers; nine source-span refusals and three compiling mutants. |
| Expanded cleanup | `cleanup-1791360769882271632` | 30 complete records/backend, adds ordinary outgoing-source deletion; actual TS+independent model; eight finite refusals and three compiling mutants. |
| Actual two-world foreign | `foreign-1791360597067996399` | Threaded Factory worlds, six refusals/schema, seeded queue and both complete owners; independent-root collision remains a failed authority discovery. |

Receipts bind their exact frozen versions; historical passing snapshots are not
passing gates for later source versions. Additional source-current aggregate replay
is required after the experiment source stabilizes. No proofs, law approvals,
production authority, performance acceptance or retained keyed failure-stream API
follow. The diagnostic cleanup budget has an explicit incomplete result and no
production exhaustion/resumption claim. Raw stages remain locally available;
verified compressed archives and manifests are the proposed Git evidence selection.

## Source-current aggregate

`evidence/aggregate-current.json` joins fresh graph/world/provider/cleanup/reorder/foreign receipts. All six passed; their complete465-pin dictionaries equal the admitted prospective freeze and current bytes. Independent review confirmed receipt hashes and command counts31/31/38/40/41/46. The expanded cleanup has30 complete records/backend; actual threaded-world controls preserve both owners and seeded queue. Independent Factory-root collision remains failed authority, and no cleanup exhaustion, keyed retention, production/default/performance or proof gate is inferred.
