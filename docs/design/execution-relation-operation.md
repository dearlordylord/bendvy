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

The canonical leaf now retains that policy. Basic and General resource writers
require `Layout.resource_write_valid`, which rejects protected generic writes.
A relation selector additionally requires exact payload, view, full origin, key,
and route binding; the policy tag alone never identifies a payload type.

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

## Retained canonical resource context

`execution-relation-context.from_schema` consumes the actual result of
`Schema.create` or `Schema.trusted_create_seeded`. On SchemaCreated it retains the
actual Factory and World and obtains its namespace through World.namespace. The
returned Context carries the forward resource equality in its type:

```text
Context<S,WR,resources,same: WR == Layout.resources(S,resources)> {
  namespace: U32
}
Bound<S,WR,resources,same,Application> {
  context: Context<S,WR,resources,same>,
  application: Application
}
```

Schema and namespace refusals retain the incoming resource owner and Factory.
The Context is framework setup metadata. It is not a gameplay grant or a
replacement description of World ownership.

A relation Binding additionally carries exact route, descriptor, payload, view,
and protected policy proofs in its type. Its resource key and full origin follow
from the same complete resource layout and route. The payload equality explicitly
relates Layout.payload to Store<S,descriptor>. The view equality explicitly relates
Layout.view to View<S,descriptor>. Neither is inferred from a key string or a
ProtectedRelation policy tag.

`execution-relation-resource-publication.apply` takes the actual allocator and
resource owner through that forward equality. It selects the canonical slot,
invokes the existing slot publication helper, and structurally restores the full
resource owner. `execution-relation-world-publication.apply` preserves the actual
World fields around that operation. A context namespace mismatch returns the
original World, Binding, operation, and typed refusal before resource extraction.
The operation remains complete in every receipt and published failure message,
including foreign namespaces and all reorder children.

The Binding now requires `Layout.policy(resources,route)` to equal the exact
protected descriptor family. There is no independently chosen policy argument.
The dedicated provider retains the full-resource equality and separate exact
payload and view equalities, while generic writers use the canonical policy gate.

### Proposed Root and command threading

The executor owner is changing Root's scheduled state to retain the actual World,
owners, guards, handler, plan, bindings, rules, and deferred settings. The following
changes target that same ordinary executor and existing command queue.

1. Ordinary setup wraps the scheduled application in Bound with the original
   Context returned from SchemaCreated. Setup does not recreate this context from
   a later World during execution.
2. Root adds bound native and serial entry adapters. Each adapter checks the
   original Context against the actual scheduled World before any preparation,
   body, barrier, or clock advancement. Refusal returns the entire Bound value and
   RunReport.ContextRefused. Success calls the existing executor and wraps its
   report in RunReport.RunReported.
3. The Root entry retains the static full resource layout and forward equality.
   Thread those templates through RootPublication.pending and apply_deferred,
   Tree.compile's publication adapter, CommandScope.publish, and Cmd.publish.
   Pending applicability still runs before clock advancement.
4. Cmd.publish uses the actual namespace already retained by Sys.Owner after the
   existing Task.verify check. This supplies the per-barrier Context namespace.
   Only static schema proofs reach erased executor callbacks. A runtime Context
   is not captured inside an erased callback, and Cmd.Owner need not gain a new
   unrelated World resource parameter.
5. The same closed command declaration lowers relation grants into typed Bindings
   and derived access metadata. A runtime resource route selects an already typed
   binding. Route or key equality never manufactures its payload or policy proof.
6. The existing Buffer's Relation variant invokes WorldPublication.apply with the
   selected binding and captured barrier tick. Insert, remove, despawn, and spawn
   retain their existing ownership and queue order. No new World callback or
   parallel command queue is introduced.

Root and Tree remain executor-owned. Buffer, command permissions, and publication
remain command-owner work. Layout, Builder, and resource admission remain the
resource owner's work. This checkpoint changes none of those shared files.

The context-law draft quantifies an actual affine World. Its only observations
are the actual World namespace and its mismatch with the retained Context.
The statement preserves that World, Binding, and operation on refusal. Its checker
reports one TODO and no type or affinity errors. It is unapproved and unproved.
The new helpers compile normally with Bend 2.0.35. Ordinary Root wiring and the
scoped-scene command application remain incomplete.

### Namespace-bound schema provisioning

`execution-relation-schema-setup.create` consumes the actual unique Factory and
passes its next namespace to a closed resource builder with an affine seed. It
reconstructs the same Factory for exactly one `Schema.create`, then derives the
Context from its actual SchemaCreated World. Both rejection variants retain the
Factory and constructed resource owners; no placeholder namespace is involved.

`examples/parallel-relations/setup.bend` consumes that helper to provision the
protected scene hierarchy beside arbitrary affine application state. Its binding
uses the actual full layout and route with reflexive payload, view and policy
equalities. This is schema provisioning, not an executed command scene. The same
ordinary Buffer relation variant and its declaration-closed typed dispatcher
remain required; no alternate queue or unsupported-operation branch was added.
