# Independent complete-observer model

This adds observations to the existing source-derived two-schema fourteen-phase
model. It does not replace the spawn/move/damage/barrier/reader workload. No new
candidate runtime output was consulted. Removing the added metadata fields
reproduces the entire prior constructor model (expected JSON SHA256
`f821c68264eb25c33a674841d0f2abcf466a9d6372e888cfc40b7ae691ae071a`).

The prior model independently derives values, physical payload cells, event
batches/retention/positions, journals, failures, reservations and world clocks.
`metadata-model.py.source` independently walks the same fixed operations to
predict the additional stamps, physical live tree and registrations. All 28
phase clocks must agree between these two calculations.

- `World.create` starts capacity1/depth0, one false live leaf and nextSystem1.
  This fixture threads its actual Factory through Workshop then Garden, giving
  namespaces1 and2; it does not use WorldIO or claim process-global allocation.
  Reservations1–3 grow to capacity4/depth2 without activation. Barriers activate
  or despawn; slot0 stays false, and physical dead/reserved leaves remain observed.
- ReaderA registers first, runs, then ReaderB registers/runs. `W.register`
  prepends metadata, so initial World order is IDs2,1 and nextSystem3. Spawn
  registers ID3 at queue-spawn. Movement registers4 then Damage5 on first gameplay,
  producing order5,4,3,2,1 and nextSystem6. Names/access lists come verbatim from
  their authored register calls; this ordering is not alphabetized.
- `Sys.run_tracked` sets successful registry cursor to the returned World clock.
  Spawn queues without component writes, leaving cursor0. Movement/damage cursors
  are respectively12/13,15/17,18/19 after the three gameplay steps. Reader runners
  use `ER.run` and untracked `Sy.run`, leaving their registry cursors0. Their
  independent event positions/cursors remain in the prior runtime snapshot.
  Actual Reader owners contain namespace, reader ID and registry ID, not a cursor.
- Spawn's populate order is position, velocity, health per entity. Structural
  component insertion advances clock and creates stamps (1,1)/(2,2)/(3,3), then
  (4,4)/(5,5)/(6,6), then (7,7)/(8,8)/(9,9). Movement changes position once per
  live entity; damage changes health only after reaching the threshold. Existing
  added ticks survive writes; changed ticks use the newly advanced clock.
  Despawn cleanup calls Column.clear and resets each of the three stamps to0/0.
  No resource stamp is fabricated for the plain Array step resource.

Snapshots retain every old field and append the new records. Registry metadata
is detached Data, while observations must thread the actual affine registries,
reader owners and World/column payloads back unchanged. The complete observer
contains allocated IDs even before activation and after death. Finite model
agreement is not a universal owner-preservation proof or a new public contract.

The 19,258-byte executed TS logical comparison remains a separate shared scope;
Bend-specific physical metadata is not invented for TS. Compiler constructor
names are bound only from the frozen import closure and datatype declarations.

Completeness is scoped to the logical and ownership-bearing state affected by
these operations: every allocated payload/stamp, World live/registration state,
retained registries and event-reader cursors. Private Column prepared/indexed
carrier layouts and unused spare backing arrays are not serialized. Existing
ordinary queries observe index behavior where reached; this is not universal
representation equality. All fourteen phases remain present in both schemas.
