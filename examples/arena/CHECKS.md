# Current execution evidence

During the generalized Root migration, the actual JavaScript product API
passively observed 523 bodies at setup. After 180 movement frames, it reported
tick 180, health 5, 77 kills, 525 enemies, 14 projectile/effect rows and 550 total
bodies. All six original
Body kinds were present. Complete initial and final JSON observations were saved
for the migration delivery. This run preceded the final admission/report-handling
repair. The final migrated source was rebuilt and executed for setup and one
frame, observing 523 bodies initially and tick 1 with 512 enemies and two
projectile rows. The final source was not replayed for 180 frames.

This finite run demonstrates the reached application path. It does not establish
universal correctness, native parallel qualification or new approved laws.

The current `check.sh` runs `build.sh` to compile the browser module. This is
build coverage, not gameplay or browser-interaction verification. It does not
emit the fixture module or invoke the old host checks.

The preserved `test.mjs`, `host-smoke.mjs`, and `browser-smoke.mjs` use synchronous
Packet and old World API assumptions. Their pre-migration source snapshot is
`70b06af566abed373038d17463fbc5aaa89151a0`.
That binding reconstructs the original source contract; it does not claim a
qualified run at that commit. The existing Bend scenarios retain their combat
inputs and now return the actual application's compiled IO computations.
