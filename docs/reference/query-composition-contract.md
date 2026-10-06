# Pinned query composition contract for #27

Sources are read-only pinned checkouts under
`/workspace/formal-proofs/bendvy/.references`. `sources.json` and actual Git HEADs
agree: bevy-ts `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`, Bevy
`ad678262ce53b5d142fe49ee5e08caff6f00ab60`, Bend
`a950fd683c0d76f09794078e6174fe98a1492876`. No reference edits, packages,
compiler changes, laws or proofs are introduced.

The governing [ticket](../tickets/25-query-composition.md), actual GitHub #27 and
[SPEC](../SPEC.md) require composition without sacrificing affine Type payloads,
rollback, confinement or mandatory eventual performance. The
[Workshop oracle](../../examples/query-composition/scenario.md) freezes actual
public bevy-ts execution before Bend implementation. Its finite observations
cannot prove universal runtime refinement.

## Structural selection and access

`packages/core/src/Query.ts` defines a named selection record of arbitrary length.
`read(D)` and `write(D)` both require presence; `optional(D)` is read-only and
never requires presence. Read cells expose get; write cells expose get/set/update
and result-returning variants. Empty selection is supported and enumerates live
entities. `with` and `without` are independent descriptor arrays; all required,
presence and absence requirements conjunctively match. A family can be required
by a filter without becoming selected or writable. Contradictory presence and
absence requirements produce zero results.

`internal/queries.ts` compiles named slots independently, deduplicates structural
requirements, conjunctively checks them and sorts query iteration by entity ID.
The public runtime accepts repeated family declarations under distinct names,
including two write cells and a read cell. Actual duplicate checkpoint shows
write A immediately visible through B, then B visible through read. Bend can preserve
these observations by threading one opaque affine context through repeated
read/write capability aliases: the aliases describe access and do not duplicate
the component owner. Repeated named writable/read aliases must therefore see
current shared storage as in TS. Duplicate actual affine contexts or component
owners remain prohibited at their intended public seams. Do not accidentally
reject repeated capability declarations or represent them as two owners.

Public Runtime transaction code journals writes and pending command publication.
Workshop observes full replacement rollback across Stock, Recipe and Queue,
repeatable retry and failed deferred insertion suppression. The test retains all
array elements. Insert/remove/despawn/spawn membership stays unchanged until
`Schedule.applyDeferred()`; schedule completion is not an implicit barrier.

## Advanced combinations retained as obligations

`Query.ts` exposes `filters:[added(D),changed(E),...]`; `internal/queries.ts` applies
all entries conjunctively, in addition to structural constraints. The cursor is
per reading system. Added requires actual addition after the cursor; changed
includes addition or write, including equal-value replacement. Failed-system
writes must roll back their stamps and failed reader execution must not advance
its cursor. Workshop observes first/repeated reader and existing-component
replacement for an added+changed conjunction; independent readers, equal writes,
failed cursor retry and combination mutations remain additional return gates.
There is no bevy-ts public OR or NOT lifecycle filter combinator in this pin;
absence is provided by explicit arrays rather than a general predicate DSL.

`Query.ts` also supports all four relation arrays: `withRelations` requires an
outgoing target, `withoutRelations` forbids it, `withRelated` requires a nonempty
reverse source collection, `withoutRelated` requires an empty collection.
`readRelation`/`readRelated` selections require their respective relation evidence;
optional relation/reverse selections do not. These can combine with each other,
component selections, structural filters and lifecycle filters. Matching uses
`world.relationTarget` and `world.relatedSourceIds`. Workshop does not execute
relations: these are source-established supported obligations, not observed
checkpoints or passed #27 gates. A general composition claim must implement and
exercise these combinations or explicitly leave the corresponding gate open;
existing separate relation reports are not this source's acceptance.

Pinned primary Bevy `crates/bevy_ecs/src/query/filter.rs` documents AND-composed
tuples (nesting beyond the finite flat tuple implementations) and `Or<...>`.
Its `fetch.rs` and filter access registration reject conflicting shared/exclusive
access. Thus Bevy's general query expression surface is broader than bevy-ts's
record-and-array surface; #27's required/optional and presence/absence minimum
must not be described as complete Bevy composition. Bend's arbitrary recursive
provider composition should not silently inherit a hard-coded three-slot limit.

## Boundaries and follow-ups

TS same-schema foreign runtime handles have no world nonce: Workshop's separate
foreign checkpoint observes local lookup for numeric ID1. The approved Bend
foreign-world rejection remains separate from ordinary TS equality. Read-only,
undeclared, cross-schema, reconstruction and duplicate-owner rejection require
fresh actual public Bend checks with compiling positives; TS oracle alone does
not establish any of them. Native/JS execution, source-bound negative controls,
performance cost and independent reviews remain integrator responsibilities.
No earlier optimization acceptance transfers, and no production/full-core
completion follows from this oracle.
