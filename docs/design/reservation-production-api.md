# GH87 typed integration proposal

Base: 82a747d7fdbcb1e7e707168383abd4f9f13544c8. New modules only;
existing Program/Owner/scheduler files remain untouched pending coordination.

Implemented source:
- execution-reservation-task: generic affine Task/Issuer, native fork advance,
  serial issuer service. No prototype schemas, fuel or driver.
- execution-reservation-frame: one consuming framework_step and terminal frame.
- execution-reservation-administration: take/put between actual Administration
  and its one Issuer plus affine Remainder. No namespace or allocator creation.
- execution-reservation-bundle: layout-indexed unlike payload tree; each family
  is Maybe<&1,P>, pair nodes retain both affine children. Typed Spawn entry,
  queue, admission result and publication result. Actual spawn/stage return the
  original bundle on reservation refusal and enqueue it before returning its
  handle on success. No materializer implemented.

Proposed coordinated signatures (schematic binders):

    Commands<Q,S,layout>.spawn:
      Q -> Bundle.Payload(layout) -> Task<S,Q & Bundle.Spawned<S,layout>>
    Body.run:
      H -> Q -> User -> Task<S,H & (Q & (User & Completion<Error,Out>))>
    Publication.spawn_at:
      World<S,Layout.columns(S,layout),R,E> -> Handle<S> ->
      Bundle.Payload(layout) -> Tick -> Bundle.Publication<...>

Program must provision this closed operation alongside existing abstract Q
capabilities. Existing command Owner captures the resulting Task and retains
Local/cursor/tick/error owners until peer completion. Existing registry and
scheduler lift invocation and join; ordinary nonrequest bodies lift into Done.
No second executor is proposed. The coordinator must assign these existing
file changes before this lane edits them.

Publication rules: reject wrong namespace, generation or non-Pending phase
before any bundle write. Validate every selected family's permissions, route,
physical slot and persistence admission before extracting/modifying any family.
Invalid publication returns actual input bundle, handle and reason, with World
unchanged; no implicit cancellation. A valid branch installs all typed families
then transitions Pending to Live at the existing publication barrier, with its
captured tick and lifecycle journal. Explicit cancellation uses the existing
canonical pending cancellation policy. Authored queue survives author body
error and peer join completes before error policy. Current live-only insert
publication and metadata-only World.activate do not implement this protocol.

The closed bundle Payload traverses component layout only; permission/schema
admission must reject unsupported persistence families before acceptance.
Bundle all-or-nothing validation and materialization are still missing source,
not inferred from typechecking. Queue integration, taskful Body/Owner/scheduler
and the ordinary IO boundary are also not implemented. No production delivery,
proof, physical scheduling or runtime acceptance claim is made.
