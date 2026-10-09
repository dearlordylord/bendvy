# Ordinary native application32 candidate

Source-only development candidate; no semantic backend or performance qualification.

The reference is `adoption-v1/qualification-v1/reference-v1/reference.mjs`.
`main.bend` preserves its operation order: Workshop insert/spawn/resource across
array3, array128, array256, lateInvalid, struct64, nullableNull, nestedValid,
nestedMissing; Garden insert across the same eight cases.

Each invocation creates an actual World with an affine resource owner, seeded
Value owner, queued Marker, and registered Local instance. Resource creation
validates and constructs its seed through the retained resource Factory.
Insert performs two declared Value membership scans, requires exactly one row,
and passes the selected handle through constructor admission to canonical
`decode-owned-component` immediate transaction write. Spawn uses canonical
constructed requests and remains deferred until delivery. Resource writes use
canonical constructed-resource and validated-resource grants. Gameplay sees
opaque H and retained OwnedRequest capabilities; names are diagnostic metadata.

Owners retain two U32 array sentinels and two Bool array sentinels. Observations
include original input, full component/resource owner views, physical columns,
liveness, lifecycle stamps, queue counts, Local metadata/recovery/Pending, and
before/committed/barrier worlds. No Pending result is treated as completed.

Equivalent public observations require an independent mapping/model before any
timing. Bend Raw decoding replaces TS codec callback mechanics; representation
conversion cost must be stated separately. TS Standard Schema/JS host mechanisms
and selector-helper controls are outside this native workload. Foreign-world
numeric coincidence does not override Bendvy's approved handle authority.

## Current checks and remaining qualification

`application.bend` stock pinned Bend 2.0.35 source check: exit 0 under source5,
CPU5/shared lock; raw output in `source-checks/application-module.*`.
Full32 interpreted entry attempts reached the five-second deadline; these are
incomplete development attempts, not semantic acceptance or timing evidence.
Earlier source diagnostics remain under source-checks. No emit/build/runtime or
performance collector was launched for this candidate.

Before qualification: freeze transitive source inventory and full independent
observation mapping, add actual reached authority/refusal controls, author the
pre-output whole32 oracle, then review exact existing collector plans. Existing
92+22 canonical semantic cohorts remain unchanged and are not replayed here.
