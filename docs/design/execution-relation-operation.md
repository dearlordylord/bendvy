# Relation operations at the shared command barrier

GH89 remains incomplete. This checkpoint adds the operation algebra, interpreter,
descriptor-bound store, read interface, and canonical-slot publication helper.
The ordinary declaration, shared queue, and scheduler are not connected yet.

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

The following shared-core changes still require coordinated ownership.

Each descriptor needs a separate canonical resource route. The resource owner is
an affine `execution-relation-store.Store<S,descriptor>` containing the existing
Graph and its actual World namespace. This owner is implemented. Its constructors
are trusted setup and barrier code. The gameplay reader exposes only methods over
an abstract H and detached handles, never the Store or a payload transform.
One global graph resource would serialize otherwise independent descriptors.
The graph remains the source of truth for both forward and inverse observations.
Gameplay receives no raw graph replacement or inverse mutation capability.

The full resource layout must distinguish this protected relation family from an
ordinary mutable resource. A plain LayoutLeaf with a general ResourceWrite grant
would let a gameplay transform replace its inverse list. The coordinator selected
an independent AccessPolicy, orthogonal to persistence, on the canonical leaf.
`execution-resource-policy.Policy` implements `Ordinary` and
`ProtectedRelation{S,descriptor}`. The latter includes nominal schema and complete
descriptor identity. `generic_write` returns False for this policy.

The layout and Builder owner still needs to add the policy to the canonical leaf
and reject protected generic writes in both Basic and General providers, before
clock advancement or owner extraction. A relation selector must require exact
policy, payload, view, full origin, key, and route binding. The helper alone does
not enforce those provider boundaries.

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
Commands<Q,S> {
  relate: Q -> Handle<S> -> Handle<S> -> Q,
  unrelate: Q -> Handle<S> -> Q
}
HierarchyCommands<Q,S> {
  relations: Commands<Q,S>,
  reorder: Q -> Handle<S> -> List<Handle<S>> -> Q
}
```

`execution-relation-command` implements these adapters over one bound
`enqueue: Q -> Route -> Operation<S> -> Q`. The actual Buffer implementation still
needs its Relation variant and canonical enqueue function. The adapter creates no
queue and accepts no World callback.

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
`execution-relation-publication.apply` implements this operation on an actual
canonical ResourceSlot. Refusal preserves its prior cache and stamp. The shared
barrier still needs to emit typed relation failures and retain receipts through
the existing Buffer owner. No second queue or transaction rollback is introduced.

GH87 owns the shared Entry and Body migration. GH82 owns the full resource layout,
Builder, and partition providers. This checkpoint changes none of those files.
The relation reader, linked deletion, scoped membership, scene consumer, and
ordinary scheduler integration remain required GH89 work.

## Compilation and law scope

Normal Bend 2.0.35 compilation of the interpreter, policy, store, access,
command adapter, and canonical-slot publication helpers succeeds.
`test-fixtures/execution-relation-laws/LAWS.bend` contains seven unapproved,
unproved subjects. Its checker reports exactly seven TODOs and no type or affinity
errors. They cover foreign-source unrelate, ordinary-descriptor reorder refusal,
the protected-write policy helper, foreign store refusal, and preservation of the
actual slot, cache, stamp, and allocator on foreign publication. They do not
establish whole-World preservation, public authority, successful graph changes,
or ordinary execution.

The existing source-of-truth architecture follows pinned Bevy
[`relationship/mod.rs`, lines 28-41](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/relationship/mod.rs#L28-L41).
Bend's World namespace and hierarchy admission rules remain explicit local
contracts. No host-language semantic tests or models were added or run.

## Failure channel and retained readers

The current Store constructor is:

```text
Store {
  namespace: U32,
  graph: Graph<S>,
  failures: execution-stream-channel.Store<Message<S,descriptor>>,
  sequence: Nat,
  nextReader: U32
}
```

`fresh` starts an empty graph and failure channel, sequence 0, and reader ID 1.
`register` allocates an actual affine reader branded by schema, descriptor, full
resource origin, and route. It increments `nextReader`, independently of system
registration IDs. Exhaustion returns the actual Store unchanged.

The shared `execution-stream-channel` uses the existing generic
`machine-stream-queue` algorithms. The machine stream delegates to this same
channel while retaining its existing Store and Reader constructors and public
signatures. Messages use their own monotone sequence. Repeated updates at one
World tick still rotate two generations on every completed update.

An actual same-namespace interpreted relation error publishes a failure and
increments sequence at command application. The original established Failure
record is reused for relate and reorder. `UnrelateFailed` names unrelate explicitly
because the old Failure operation enum has no unrelate variant. Namespace refusal
and the internal HierarchyRequired admission refusal publish no graph failure.
A refused graph mutation retains the graph, cached graph view, and graph stamp,
while the owned failure channel records its message. Successful graph application
still refreshes the cache and stamp at the captured tick.

The failure-access helper consumes a typed canonical slot lens. It checks the
actual Scope namespace before extraction, then checks the Store namespace through
the shared channel. Refusal returns the actual Scope and Reader unchanged.
Successful reading returns messages, missed count, tick, and the advanced Reader.
The returned reader belongs in `execution-relation-failure-local.Local`.
Its body adapter keeps that reader through every completion, including BodyError.
The ordinary condition must run before this body adapter. A false condition never
calls it, so it cannot advance the cursor.

`execution-relation-failure-maintenance.completed` rotates retention only for the
outer App.Finished report. App.Stopped and App.Invalid retain the entire scheduled
application. The wrapper preserves the canonical graph stamp. It does not flush
commands and introduces no direct-pair maintenance call. Connecting this wrapper
to the ordinary application's selected maintenance path remains shared integration
work.

The source-bound law file now contains seven unapproved, unproved subjects.
The two added subjects cover exact foreign Reader retention and the body-error
completion adapter's actual Reader, Scope, and user owner. They do not prove all
reader bodies or the ordinary false-condition branch. The checker reports seven
TODOs and no type or affinity errors. No proof or ordinary GH89 completion is
claimed.
