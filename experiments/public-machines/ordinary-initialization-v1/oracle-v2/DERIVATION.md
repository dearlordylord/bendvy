# Source-only ordinary initialization oracle

This finite oracle derives `main.bend` at producer commit
`da557452cfd348f97417cb28c65fd997fc87e230`, before any candidate backend
execution. `source-freeze.json` binds the complete 33-file literal import closure;
its 31 core bodies exactly matched the initialization implementation worktree.
`source-pins.json` additionally pins Base serializers, both print effect bodies,
and the relevant pinned Rust Bevy sources. No prior backend output, generated
code, historical expected.json, or TS observation is an input.

Run `python3 model.py` in this directory to check all source hashes, derive the
complete wire, run substantive state invariants, and reproduce the raw/gzip
oracle and timeline. There is no compiler or backend invocation.

## Reached source and rendering

`main.start_scenario` supplies forty actual Action constructors; `run_actions`
executes left to right through `execute_action`. Each of seven user-reader
calls appends its callback result before appending the full snapshot, producing
47 trace entries per schema. `scenario_a` and `scenario_b` instantiate genuinely
separate nominal schema types. Each separately calls `W.factory()`, so both
concrete namespaces are 1; this is not a WorldIO provenance/foreign-world test.
The final `IO.print` argument is `SCHEMA=A`, LF, the first complete List.show,
LF, `SCHEMA=B`, LF, the second complete List.show. The argument has no trailing
LF. Base/print.js and print.c append exactly one LF. Base `List.show` uses
brackets and comma-space separators without quoting string elements.

`render.py` retains the complete executable Data projection of the physical
World: namespace, allocator/high-water/live array, capacity/depth, store array,
resource slot/pending/previous/changed/revision/default effects/callback log/
failure mode, all stream batches/values/positions/drop/frame fields, events,
pending count, registrations/access/order/next ID, and clock. Watcher snapshots
retain real system IDs/cursors and independently owned observed revisions.
User-reader snapshots retain both registry and stream identities and real
registry cursors. The Bend observers thread all affine owners; this Python model
represents only their returned observations and finite state, not copied owners.

## Operations and independent timeline

`Init.inserted` increments revision even for equal occupied insertion, preserves
pending and previous, and replaces only occupied-state message batches. Missing
reinitialization appends to the existing stream. Each publication advances the
actual World clock. Duplicate init calls neither the default closure nor clock
advance. `put_slot` changes revision only if current presence/value changes;
queue-only writes and changed-flag resets preserve revision. Missing-state
condition observations return false while committing their observed revision.

The marker's real schedule is barrier, apply, exit, transition, enter. Its
fixture frame advances the World clock; it does not call St.frame, hence actual
droppedThrough and frameStart remain zero. A queued transition commits and
publishes before Enter. Initial selection reads the real stream and commits its
selection cursor before InitialEnter. Therefore the failed InitialEnter preserves
that committed prefix; a quiet next marker does not replay it. New occupied
insertion publishes a fresh Initial and allows another attempt with the same
owners. All schedule steps and observations are retained, including ran:4 on the
failed Enter dispatch.

The queued B survives occupied insert C at clock3. The very next marker commits
C→B and publishes at clock5; the later action named
`queued-C-to-B-transition` is already quiet. No initial C callback runs ahead of
that effective transition. Repeated inserts A/C leave only Initial C at clock9.
Slow's failed read at clock10 preserves both registry cursor2 and stream cursor2;
its retry reads the same Initial C and commits cursor10. Fast then independently
reads it. Equal insert C at clock11 is a new observed revision. Removing the slot
increments revision7; reinitializing increments default count2/revision8 and
appends Initial A at clock12, preserving the prior Initial C batch. Both readers
subsequently see both unread initial publications and commit cursor13.

Final state per nominal schema: current C, pending none, previous none,
changed false, revision10/default effects2, clock18, engine stream cursor18,
fast/slow user cursors13; watchers independently observe revision10/cursor18.
The ordered successful World events contain initial A, normal C→B enter,
initial C, reinitialized A, and newly republished C. Failure adds no World event.

## Reference and bounded scope

Pinned Bevy `app.rs` init_state/insert_state publish Initial immediately;
occupied insertion clears messages and leaves NextState intact. Transition
sets run dependent application before exit/transition/enter, whose separate
last_transition readers select the latest unread event. Message clear retains
monotonic message_count and reader cursors. `state_changed` observes resource
change relative to each system's observation tick. These facts underpin the
finite Bend revision and fresh publication checks. The previously approved #49
committed-prefix failure behavior remains in force; no whole-marker rollback is
introduced.

The active false condition in this consumer is `Condition.run_if(false)` on the
changed watcher. It dispatches no reader callback; the actual user-reader owners
and unread positions remain unchanged. This is noninvocation preservation,
not a dedicated transition-reader run_if API claim. User-reader callback failure
and retry are separately reached through real SI.register/SI.run_tracked owners.
There is no capacity/retention-frame stress, disposal, foreign WorldIO, or
universal proof claimed by this finite oracle. No backend result is established
until the unchanged collector compares actual complete stdout against these bytes.

## Preserved formatting correction

The first oracle commit fc67e1ec3cf47ae2f78e33d6d195212f56a56f62 and its
expected bytes remain historical and unchanged. Its model omitted a serializer
literal from frozen main.bend:493: `skipped_fast_finish` passes the complete
fastResult string `run_if(false);active-transition-fast=not-invoked` to
`condition_finish`, which places that string verbatim before `;slow=`. The v1
model rendered only `run_if(false)`. This successor changes only that projection;
all operational transitions, source pins, snapshots and timeline are identical.
The omitted `;active-transition-fast=not-invoked` is 35 ASCII bytes and occurs
once per nominal schema, giving exactly 70 additional bytes. The runtime
mismatch report located the omission; the frozen source supplies the correction.
No runtime output bytes are copied into this oracle.
