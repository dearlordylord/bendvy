# Occupied-initialization idempotence counter oracle

This source-only countermodel binds the exact path-preserving 33-source mirror
in `source-freeze.json`, frozen under
`/tmp/bendvy48-ordinary-initialization-mutant-oracle-source01`. It preserves the
normal v1/v2 oracle and every historical result. No runtime or generated output
was consulted; the mutation is not accepted behavior.

The source selftest compares all 33 imported bodies against normal oracle-v2:
32 are byte-identical. The only difference is in
`src/ecs/ordinary-machine-initialization.bend`, `init_checked` occupied branch:
`case (world,_):world` becomes
`case (world,_):defaulted(~S,~K,~V,~R,~take,~put,~C,~E,~declaration,make(world))`.
The selftest checks this exact expression replacement only within init_checked;
the same normal-looking branch in inserted_world is unchanged. The baseline
module SHA is 621d39e55652438f3b302fb7a7e7f5dc2507bc35212957089487c704969a6f27;
mutant SHA is d7ca2c0df04ad4637d2b73c9a01207639cbb86605ce609ebb8b7857f67004b02.

The reached main still executes forty actions and seven reader callbacks per
nominal schema. Only the model's initialization operation differs: it now always
calls the actual default constructor, then the existing insert operation. All
other slot/stream/revision/marker/failure/condition/rendering semantics remain
identical to the normal oracle. `state.py` is unchanged and still selftests the
normal operation; the countermodel subclasses its initialization alone.

On duplicate occupied init after the warm reads, the normal default count stays
1 and clock2. The mutant instead increments defaults to2, advances clock3,
clears the occupied message storage, publishes Initial A at tick3, and increments
revision2 even though the current value remains A. Existing reader cursors stay2.
The next occupied insert C preserves pending B; the effective marker commits
C→B at clock6/revision4. Later occupied init changes C to default A, increments
defaults3 and republishes Initial A. Reinitializing after actual removal increments
defaults4. Reader failure/retry still uses the same owners and preserves the
failed user's old cursor. Marker selection still commits before InitialEnter
failure, so quiet retry does not replay; newly published Initial C retries with
those same owners. Final clock20/revision12/defaults4 are source-derived defects,
not golden updates to normal behavior.

The complete raw wire retains both nominal schemas, every physical World and
resource/stream snapshot, all metadata/cursors, successful and failed callback
views, schedule status/steps/observations, default side effects and sole terminal
IO.print LF. The shared rendering and source limitations described by normal
oracle-v2 remain: both fresh typed factories have namespace1; changed-condition
false is noninvocation preservation, not a dedicated reader run_if API; no
capacity, disposal or foreign-WorldIO coverage is claimed.

Run `python3 model.py` to verify all pins, exact mutation/inverse join, finite
state invariants, and complete source-derived counterwire. It explicitly rejects
equality with the normal oracle. The existing collector must independently show
that the normal oracle rejects the mutant and this complete counterwire matches
its actual result. No compiler/backend invocation is performed here.
