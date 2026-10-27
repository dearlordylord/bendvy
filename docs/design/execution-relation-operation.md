# Relation operations at the shared command barrier

GH89 remains incomplete. This checkpoint adds an internal operation algebra and
interpreter. It adds no queue, gameplay grant, graph storage, or scheduler adapter.

`Operation<S>` carries complete `World.Handle<S>` values for relate, unrelate,
and reorder. Reparenting uses relate's established source-replacement behavior.
`Outcome<S>` retains the original operation in both outcomes. Refusal also retains
the original graph and a typed reason.

The internal call is:

```text
apply(
  ~S, ~descriptor,
  actualNamespace, actualAllocator, graph, operation
) -> actualAllocator & Outcome<S>
```

The barrier obtains namespace and allocator from the same actual Administration.
The interpreter checks namespace, generation, and Live phase itself. Callers
cannot supply Boolean liveness observations. Relate and reorder delegate to the
existing pure graph algorithms. Unrelate checks the source before changing the
graph. An ordinary descriptor refuses reorder with `HierarchyRequired`.

The interpreter is trusted framework code. It does not establish that an input
graph came from canonical storage or that a caller has a declaration-bound grant.
Those checks belong to the shared command and resource integration below.

## Proposed shared integration

The following signatures describe work still requiring coordinated ownership.
They are not implemented by this checkpoint.

Each descriptor needs a separate canonical resource route. The resource owner is
an opaque affine `RelationStore<S,descriptor>` containing the existing Graph.
One global graph resource would serialize otherwise independent descriptors.
The graph remains the source of truth for both forward and inverse observations.
Gameplay receives no raw graph replacement or inverse mutation capability.

The full resource layout must distinguish this protected relation family from an
ordinary mutable resource. A plain LayoutLeaf with a general ResourceWrite grant
would let a gameplay transform replace its inverse list. Proposed layout support
is a dedicated relation leaf carrying schema and descriptor identity. The normal
resource-write provider refuses that leaf. A relation selector admits it through
its exact full origin and route. This must be implemented by the existing layout
and Builder owner, rather than by a parallel access catalog.

Extend the existing command sum after the GH87 Spawn extension:

```text
Entry<S,P,D> += Relation {
  resourceRoute: Layout.Route,
  operation: Operation<S>
}
Receipt<S,P,D> += RelationApplied { operation: Operation<S> }
Receipt<S,P,D> += RelationRefused {
  operation: Operation<S>, reason: Reason
}
```

The route is installed by the closed declaration. The request has no descriptor
setter or arbitrary callback. Admission binds the selected route to the actual
full resource layout, schema, namespace, descriptor, and declared access before
running a body. A bad route returns the original queue and request unchanged.

The same command declaration supplies these abstract operations:

```text
RelationCommands<Q,S> {
  relate: Q -> Handle<S> -> Handle<S> -> Q,
  unrelate: Q -> Handle<S> -> Q,
  reorder: Q -> Handle<S> -> List<Handle<S>> -> Q
}
```

Only a hierarchy selector supplies reorder. It derives one descriptor's resource
route and graph-write access in the same closed Program. Read selection exposes
source and inverse snapshots without granting a graph payload transform. A
relation writer and reader of the same descriptor conflict. Different descriptor
routes can occupy disjoint resource partitions and execute independent systems.
Structural cleanup declares every graph route that it can modify.

At the existing barrier, the publication interpreter validates route and grant,
takes the selected store from canonical resources, and takes the actual allocator
from Administration. It invokes `apply` once, restores the allocator, installs the
returned graph, and refreshes the resource cache and stamp at the captured tick.
Refusal leaves the graph's stamp unchanged and emits the existing typed relation
failure where applicable. It retains the command receipt through the existing
Buffer owner. No second command queue or transaction rollback is introduced.

GH87 owns the shared Entry and Body migration. GH82 owns the full resource layout,
Builder, and partition providers. This checkpoint changes none of those files.
The relation reader, linked deletion, scoped membership, scene consumer, and
ordinary scheduler integration remain required GH89 work.

## Compilation and law scope

Normal Bend 2.0.35 compilation of the interpreter and all imports succeeds.
`test-fixtures/execution-relation-laws/LAWS.bend` contains two unapproved, unproved
subjects. Its checker reports exactly two TODOs and no type or affinity errors.
The subjects cover foreign-source unrelate and ordinary-descriptor reorder
refusal with the actual affine allocator. They do not establish whole-World
preservation, public authority, successful graph changes, or ordinary execution.

The existing source-of-truth architecture follows pinned Bevy
[`relationship/mod.rs`, lines 28-41](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/relationship/mod.rs#L28-L41).
Bend's World namespace and hierarchy admission rules remain explicit local
contracts. No host-language semantic tests or models were added or run.
