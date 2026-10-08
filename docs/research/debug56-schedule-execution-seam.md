# #56 — ordinary App schedule execution seam

Source-only proposal; not a selected refusal policy or delivery claim. Inspected
root `e34a264d`, fixture repair `1839b3c5`, oracle `28b0a232`. This extends the
existing #56 implementation; shared App/System/Sch remain with the integrator.

## Concrete consuming route

Keep the same ordinary query declarations, `System.define` and `App.add`.
`App.Owners` already retains a heterogeneous nested affine product H and derives
catalog IDs/Enabled entries from actual Registry owners. No additional access or
debug metadata should enter the application.

Add a closed dispatcher for that H: destructure its product, select the requested
**actual registered ID**, call the corresponding `System.schedule_dispatch`
with its existing typed query/body/args, and rebuild H from the returned owner
plus every untouched sibling. Successful/failed reached results retain body
outputs separately from the scheduler's Unit outcome. Keep these full outputs in
an application-owned typed run record; never discard them merely to satisfy
Sch's Unit result. A heterogeneous error sum may inject each existing body error
without changing its semantics. No runtime closure or cloned owner is needed.

Then exercise `App.run -> SP.run -> Sch.run -> dispatcher ->
System.schedule_dispatch -> System.run -> Sys.run_tracked -> Compose.each_since`
against the retained nonempty scenario Worlds. Return the resulting provisioned
schedule, debug entries, World, registry product and complete output record;
rebuild App from these returned fields for a second run/description. Execution
must use the same schedule steps that describe reports. Existing v4 only builds
and describes App; its direct System runs do not qualify this route.

## Existing contracts versus the blocking transport

- [System](../../src/ecs/system.bend), run_namespace_checked/run_tracked:
  namespace and registration metadata are checked; refusal returns Registry,
  World and args without invoking body. Success advances cursor to committed
  World clock; failure preserves it.
- [Sch](../../src/ecs/schedule.bend), execute/conditioned/after_outcome:
  false condition skips dispatch; barrier applies pending commands; body failure
  stops the remaining plan while retaining schedule owners/current World and
  prior observations. This is not whole-schedule rollback.
- [SP](../../src/ecs/schedule-provision.bend), run: missing provisions retain
  schedule/World. `App.run` preserves debug/entries around this existing result.
- Candidate `System.ScheduleDispatch` distinguishes Reached from
  RegistrationRefused and preserves args. Sch's callback currently accepts only
  `H & Sys.Outcome<World,Error,Unit>`: it cannot represent that refusal directly.

**Genuine unresolved boundary:** when a selected system's registration refuses,
should scheduling stop in a separate refusal result, or treat it as an explicitly
identified scheduling error? What happens to earlier work and observations must
be explicit. Do not silently manufacture a body error, claim the body ran, skip
it, replace a World, drop args or bypass Sys validation. `Sch.after_outcome`
appends Ran for both outcomes, so feeding a refusal as Failed would also change
observable attribution. Merely checking schedule namespace cannot exclude stale
or mismatched registration metadata; trusted raw construction remains possible.

Smallest implementation options for the integrator to review are a typed Sch
refusal transport propagated through SP/App, or an explicitly approved adapter
with a distinct scheduling-error variant and matching observation semantics.
This note selects neither. Existing simulation runtime-gameplay/gameplay-run
maps registration refusal to **application-specific** errors; those source
examples do not approve a generic ECS scheduling policy. Valid-case dispatcher
construction and independent expected traces can be prepared while this boundary
is resolved; a total publicly exposed adapter cannot omit its refusal branch.

## Exact checks to add to the existing scenario

Use Plain/Transient/Constructed affine Arrays and complete current observers.
Run one retained App twice with mixed query capability products, real registered
IDs, phase/barrier placements, true/false conditions, a write followed by body
failure and retry. Observe all outputs/errors, full Worlds, owner packs/cursors,
debug entries, schedule steps and terminal observations; Enabled and Disabled
must execute equivalent ECS work. Include missing provision, foreign schedule
World, stale/mismatched Registry and complete returned args under the selected
refusal transport. Keep remaining siblings unchanged and owners returned on every
branch. No capture/event ownership or new identity policy is needed.

Source negatives should reject duplicated App/registered owners and wrong schema
at this actual dispatcher. Reached mutants should swap dispatch target, lose one
returned sibling/cursor, or omit a barrier; the full oracle must detect each.
Freeze the expanded independent oracle before JS/Native children. Existing #28
regression and full equivalent-work feature gates remain required; no broad run
was performed for this note.

## Pinned architectural basis

Rust Bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60`:
[FunctionSystem](../../.references/bevy/crates/bevy_ecs/src/system/function_system.rs)
retains instance state; [single-threaded executor](../../.references/bevy/crates/bevy_ecs/src/schedule/executor/single_threaded.rs)
executes scheduled systems and conditions. Bend
`a950fd683c0d76f09794078e6174fe98a1492876`:
[guide](../../.references/bend2/guide/GUIDE.md) affine at-most-once and reusable
closed templates support H threading; they do not establish exactly-once cleanup.
bevy-ts `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`:
[Runtime.runScheduleUnsafe/runSteps](../../.references/bevy-ts/packages/core/src/Runtime.ts)
is the feature/reference route, not authority for an invented Bend refusal mapping.
