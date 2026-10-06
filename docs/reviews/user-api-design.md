# User API design review — #26

Independent pre-implementation review of [the design](../design/user-system-api.md), GitHub #26, [SPEC](../SPEC.md), R-A and R-C1. This review authorizes a bounded implementation route only after the registration correction below; it does not approve production authority, new laws/proofs, runtime refinement or performance acceptance.

## Finding: descriptor index does not establish registered identity

`Bound<W,-body>{id}` is a useful static binding when reusing an existing descriptor. Its public constructor allows a caller to manufacture a differently indexed descriptor with the same numeric ID. Runtime validation of only ID and access cannot distinguish the registered callback from that replacement.

Observed with Bend 2.0.35 after `bend version` and `bend guide`, under the unchanged five-second checker limit:

- `timeout 5 bend experiments/user-api/design-canaries/binding-forged.bend`: exit 0; fresh `Bound{7}` instantiated for `idle` produces `Edit{Position{[0, 0], 0}, []}`.
- The original `binding-negative.bend` tests reuse of a differently indexed existing descriptor; it does not test public reconstruction.

**Required correction:** maintain a body-indexed registration owner or closed typed schedule, not only a body-indexed descriptor over an untyped registry. A smallest feasible signature is:

```text
Registry<W: Type,-body: W -> W> is Type
run_registered(~W,~body,Registry<W,body>,Bound<W,body>,W)
  -> Registry<W,body> & W
```

The owner contains runtime registration ID, world-instance identity, declared access, order and retry metadata. Execution threads that same affine owner with the world and validates the runtime metadata before invoking the closed template. A heterogeneous static schedule can carry a product of differently indexed registration owners and invoke library combinators. Do not store or copy affine callback closures. Ordinary closed adapters choose the query/provider, while gameplay bodies remain universally quantified in abstract provider handles.

`typed-registry.bend` exercises this signature and executes the repeated callback: exit 0, `(Registry{7}, Edit{Position{[2, 2], 2}, [Position{[1, 1], 1}, Position{[0, 0], 0}]})`. `typed-registry-negative.bend` attempts an idle descriptor with the existing concrete-body registry and rejects with expected `Registry<...,idle>`, observed `Registry<...,concrete>`, at `forged`.

These are temporary feasibility canaries, not connected registration tests. Public constructors are still not secret authority. The root world owner and schema/registration declarations are trusted provisioning, as in R-A/R-C1; a caller can create detached concrete worlds/registries. The gameplay callback must never receive those concrete owners, and cannot replace its abstract live handle using detached storage. If the implementation claims stronger protection against a malicious root owner fabricating registry metadata, this signature alone does not provide it. Keep that distinction explicit.

## Ownership and schema assessment

Independent `Column<S,C>` membership with ordinary closed field lenses is a viable bounded alternative to hard-coded payload families. Position, Velocity and Health must each carry independently accessible affine Type owners; Armor/tag must exercise optional membership and Data remains supported. The owned Position Array must survive actual update, failure, query and structural operations, not merely appear in a constructor canary. Family witnesses must be nominal declared types; numeric family slots cannot establish cross-schema rejection. Lens declarations are trusted provisioning and must preserve the other columns and runtime world identity.

Full replacement with an affine journal is implementable: the provider retains the old component owner; commit drops superseded owners; rollback consumes the journal in reverse order. Read projection returns the same abstract handle with Data, without moving the component into gameplay code. A destructive arbitrary `C -> C` updater cannot promise generic rollback and must not be exposed as such. Repeated replacements and a failing callback after multiple writes need exact owner/order controls. Resources use the same replacement contract; event and command owners must commit/discard at the system boundary without retracting earlier systems' commits.

## Required connected return evidence

Before claiming #26 completion, independently authored movement/damage must register and run without BodyKind edits, engine dispatchers, manually built journals or copied gameplay bodies. Freeze checkpoints before implementation; execute pinned bevy-ts rather than citing a source-derived trace. Include independent family insertion/removal, despawn, all four selection forms, optional observation, resource replacement, publications/readers and explicit deferred barriers.

Registration controls must include repeated invocation of one registration owner, retry with stable ID, duplicate-ID rejection, metadata mismatch, a forged differently indexed descriptor against the existing typed registration owner, and a detached same-ID registration against the live schedule/world. Access controls need working positives and intended rejection of undeclared access, writes through read, cross-schema use, duplicate abstract owners and concrete reconstruction. Foreign same-schema handles must yield MissingEntity and leave the actual command queue unchanged. Transaction controls must check read-your-writes, reverse rollback, earlier committed systems, tentative queue/events and retry readers.

Finite canaries and traces are not universal parametricity or refinement. Fresh confinement/registration integration, a reviewed bounded regression check and a genuinely fresh blind consumer remain required. The full 5×3 qualified performance gate remains open; no timing claim follows from this review.
