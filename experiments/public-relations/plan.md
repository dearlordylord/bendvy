# #42 implementation plan — draft, no core edits

## Source authority and architecture

- TS `Relation.ts:279–340`: paired nominal descriptor metadata, default self rejection, ordinary/hierarchy flags; no edge payload/exclusive-incoming builder. `Descriptor.ts:573–582` exports aliases.
- TS `internal/world.ts:495–589`: authoritative source map, arrival-ordered unique inverse array, replacement/removal and validation. `:591–658`: hierarchy reorder and deletion integration.
- TS `Runtime.ts:769–830`: structural failure publication; `:1439–1467`: FIFO deferred drain, not a transactional all-or-nothing batch.
- TS `internal/queries.ts:252–276`: live derived relation cells, inverse arrays freshly projected; Runtime lookup maps IDs into a fresh inverse result array.
- Rust `relationship/mod.rs:27–57`: source component is authoritative, target collection is maintained by hooks and has a private relationship field. Its one-to-one collection option is not TS parity scope. `:285–303` also exposes explicitly risky collection mutation/construction helpers; Rust is architecture guidance, not proof of universal inverse authority.
- Bend installed Base `Array<T>:Type`, `List<a,A>:Kind(a)`, and pinned `bend2/comp.ts` govern the representation. Current `World<S,Store:Type,Resource:Type,E:Data>` already transports arbitrary affine owners. Current `transaction.bend:Tx` owns affine undo/command closures; commands are reversed once into FIFO and published only on success.

## Minimal proposed seam

1. Add schema-indexed typed relation descriptors and a Data-only **identity table**, alongside existing arbitrary Type component storage. Relation *identities/edges* contain handles and metadata, not cloned components or an invented edge-payload feature. Schema provisioning owns the real generic Store plus relation table; no two-family/demo arity in the library.
2. Provide a single authoritative mutation operation that validates source/target and changes source plus inverse together. Public inverse capability is read-only; callers never receive a setter for the maintained inverse collection. Keep exact inverse arrival order and logical duplicate behavior. Descriptor registry/name validation uses the public schema authoring contract.
3. Queue relate/unrelate as the existing affine World→World command transport. Resolve liveness at application time against each current intermediate World. Check foreign namespace under the existing approved MissingEntity/unchanged-queue frontend contract, with fresh actual tests; do not equate it with observed TS numerical aliasing. Initial production identity remains #38's decision.
4. Publish relation mutation failures as a distinct typed Data channel, preserving original Event families rather than replacing E with fixed-demo error strings. Per-descriptor failure streams and bounded reader/retention semantics must connect to the reader-domain work; do not silently append structural errors as SystemFailure.
5. Integrate cleanup through the actual accepted despawn/clear path. Relation metadata cleanup must run once per deleted entity and release the complete original component owner through existing schema clear adapters. Ordinary target deletion leaves incoming sources alive; hierarchy's linked recursion/order is a #43 dependency. Liveness-only `tx_despawn` is explicitly insufficient because it retains storage and has no relation cleanup.
6. Public gameplay callbacks receive rank2 abstract read/mutation capabilities, not the concrete World/table. Snapshot results can be Data lists of typed handles; arbitrary component Raw arrays remain Type and are threaded once. Retained snapshot and nonidentity returned-owner controls remain mandatory. A live TS cell does not justify capturing/duplicating a Bend affine World.

## Gates before core delivery

- Fresh two-schema equivalent TS/JS/Native traces: all recorded complete payload cells, every forward/inverse/access/error field, deferred pre/post visibility, FIFO future-ID behavior, cleanup and failure-versus-SystemFailure distinction.
- Real same-schema separate-world foreign source **and target** controls against the approved factory policy, preserving unchanged queue and both complete owner packs; the current research observes TS foreign source alias only.
- Actual registration/provider negatives for cross-schema relation/handle pairing, undeclared descriptor use, write-through-read/inverse mutation, affine owner duplication; current Node execution is not a typechecker negative.
- Compiling/reached stale-inverse, inverse-order, lost returned-owner and skipped failure-publication mutants. Independent literal oracles; not altered fixture output relabeled as core mutation coverage.
- Exact source/external/staged/artifact guards, five-second checker and bounded codegen/clang/runtime, independent Standards+Spec review, unchanged default #28 paired regression and feature-specific performance/scaling when contention permits.

## Decisions deliberately left open

- Exact production root/identity provisioning is #38, not settled by this research. Use only already approved foreign rejection behavior; do not invent namespace generations or global roots.
- Final generic Store/descriptor/provider header and failure-channel plumbing require source review with #35 reader-domain integration. No API/authority guarantee follows from exported constructors or trusted provisioning alone.
- Hierarchy ordering, scopes and recursive despawn/event ordering extend into #43; do not turn ordinary graphs into a DAG to simplify implementation.
- Formal statements/executable refinement and human approval are needed before any proof. The law draft is not an approved law file. New Data-only component scope, edge payloads, exclusive targets, new dependencies or thresholds are not authorized here.

Proceed first with the smallest opaque ordinary-relation source/inverse operation and complete affine-frame controls only after this plan's independent review. Research alone does not complete #42 or justify production adoption.

## Implemented finite experiment boundary

The experiment now supplies maintained graph/independent slow model, actual affine World/Commands, registered rank2 relation providers, entered-frame cleanup and nominal hierarchy reorder. Threaded Factory worlds supply actual foreign source/target refusal controls; independently rooted Factory collision remains a failed capability. Historical receipts are version-bound; the final common-freeze replay is tracked in `evidence/aggregate-prospective.json` until terminal joined receipts are available. Production failure-reader integration, hooks/exhaustion protocol, full public query refinement and default/performance gates remain separate.
