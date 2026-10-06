# User-authored ECS boundary — reviewed-design candidate

Issue #26; full-core #1 and #24 remain binding. This is a bounded design candidate for independent review, not a production representation or a new law/proof approval.

## Typed schema

Use `World<S: Data, Store: Type, Resource: Type, Event: Data>`. The caller declares an ordinary Bend `Store` containing independently typed `Column<S,C>` fields. Position, Velocity, Health and optional Armor are independent component families, each permitting an affine `Type` payload. Position contains an actual owned `Array<U32>`. Column membership uses `Maybe<&1,C>` independently for every entity. An ordinary caller-authored schema declaration supplies closed field lenses and read projections; the library owns iteration, identity, allocation, transactions and barriers. No gameplay variants, reflection or generator.

Family tokens are distinct declared Data types, not numeric slot guesses. Operations accept the schema/family witness and abstract handles. A callback is polymorphic in provider handles; it never receives concrete Store, Column, Cell or World. Read providers supply projections only; write providers additionally supply full replacement operations. Optional readers expose typed presence and a projection while retaining the owned component in the provider. Required/Present/Absent/Optional determine membership before callbacks execute. User schema lenses are trusted provisioning declarations, not executable gameplay callbacks.

## Registration without copying closures

Bend 2.0.35 accepts an erased function index on a Data descriptor:

```bend
type Bound<W: Type,-body: W -> W> is Data:
  Bound{id: U32}
def twice_bound(~W: Type,~body: W -> W,binding: Bound<W,body>,world: W) -> W:
  body(body(world))
```

`body` is closed syntax, erased from the descriptor and freshly instantiated by the executor. No affine runtime function is stored or copied. Descriptor indexing rejects changing the body of an existing descriptor, but does **not** establish registered identity: a fresh public `Bound{7}` can be instantiated for another body.

The independently reviewed correction is an affine body-indexed registration owner:

```text
Registry<W: Type,-body: W -> W> is Type
run_registered(~W,~body,Registry<W,body>,Bound<W,body>,W)
  -> Registry<W,body> & W
```

The same Registry owner moves through every invocation/retry. It carries runtime registration ID, world-instance identity, access, order and retry metadata; the executor validates those before invoking the closed body. A frozen heterogeneous static schedule carries a typed product of body-indexed owners and invokes library combinators. Passing an idle descriptor to the existing concrete-body Registry fails at the intended `Registry<...,idle>` / `Registry<...,concrete>` mismatch. A descriptor-only ID/access check over an untyped registry is not sufficient and is not the implementation route.

Root world ownership and schema/registration declarations are trusted provisioning, as in R-A/R-C1. Public constructors are not secret authority: a root caller can manufacture detached concrete registries/worlds. This design does not claim universal root-owner authority against fabricated matching metadata. Gameplay callbacks receive only universally quantified abstract provider handles and cannot replace their original live handle using detached storage. Connected tests must separately reject a detached same-ID registration against the live schedule/world.

The library executor binds the user rank2 callback to its declared schema/query provider. The caller writes movement/damage functions and ordinary static schedule composition using library combinators; no engine dispatcher or BodyKind extension. Closed callback templates receive resources through capabilities. Arbitrary captured affine closures and runtime-extensible heterogeneous schedules remain explicit follow-ups.

## Ownership and rollback

A read consumes and returns the same abstract handle plus a Data projection. It does not hand the component owner to user code. A replacement consumes a newly owned C, installs it, and moves the previous C into the library-owned undo list. Repeated replacement journals each previous owner; commit drops superseded owners, rollback restores them in reverse order. Arbitrary destructive `C -> C` callbacks cannot support generic rollback for Type and are not exposed under that claim. Read-your-writes reads the current owner, not the journal. An owned Array replacement is allowed; array reconstruction cost is not a performance acceptance result.

Each system transaction owns its journal, tentative commands and publications. Failure restores only its own edits and discards its tentative queue/events; earlier committed systems remain committed. Registration and its id survive same-instance retry. Commands move payload owners into a typed deferred queue; foreign world handles return MissingEntity before enqueue and preserve the queue. Explicit barriers consume commands and return the world. Structural edits are independent per-family operations. Resource edits require the same ownership-preserving replacement contract; events are Data in this bounded design (affine events remain a follow-up).

## Exact feasibility evidence

`experiments/user-api/design-canaries/contract.bend`: four independent affine component families; owned Position Array; generic World; rank2 handle/read/full-replacement callback; twice-repeated closed movement; library journal preserves both previous owners. `binding.bend` adds erased-body indexed registration. Both were executed with `timeout 5 bend FILE` on Bend 2.0.35; output:

```text
Edit{Position{[2, 2], 2}, [Position{[1, 1], 1}, Position{[0, 0], 0}]}
```

`typed-registry.bend` executes the same repeated callback while returning the Registry owner; `typed-registry-negative.bend` rejects an idle descriptor against the existing concrete-body Registry. `binding-forged.bend` passes for a freshly reconstructed differently indexed descriptor, proving the descriptor-only route insufficient. `binding-negative.bend` rejects substitution of idle for concrete body at `wrong`, with the intended Bound type mismatch. Preliminary command `bend check FILE` refused because this version takes FILE directly; no passing gate is inferred from that refusal.

These are signature/ownership canaries, not an implemented ECS. The actual allocator, typed lenses, queries, barriers, schedule metadata, registration rejection, resources/events, transaction recovery and external simulation still need connected implementation and tests. Public descriptor constructors are not secret authority; runtime identity/access validation must reject detached/forged registrations. Negative controls must exercise actual public providers, including undeclared/read-only/cross-schema/duplicate-owner/reconstruction attempts. Finite controls do not imply universal parametricity or refinement.

No laws, proofs, dependency, compiler/kernel or reference changes. Default checker limit remains five seconds. Full five-by-three qualified performance remains open. The fresh external consumer gate follows implementation and independent review; Tower Defense uses a separate copy only after prerequisites pass.
