# Actual handle reader host join

`reader-host.bend` implements the agreed dispatcher join without changing R/S:

- `Logs<Schema,P>` owns one nominal Ping log and separate Main removal/despawn
  logs of actual `Storage.Handle<Schema>`.
- `append_changes` consumes the actual ordered output of `commands.apply`.
  Removed and Despawned are routed independently in original order. Added and
  Changed remain storage marks and create no removal record.
- `frame` consumes an actual `R.Frame`; it obtains message, Main(0), and despawn
  holders independently from `R.holders`, then returns owners and the exact frame
  clock. None means no lifecycle trimming, including capacity trimming.
- `read` projects the actual Run once, returns its actual boundary and all values,
  and passes the same affine Run through all R/S operations. Message lag comes
  from the Ping read; lifecycle lag comes from the corresponding missed hook.
  The dispatcher consumes that returned Run at success/failure completion.

The dispatcher owns clock changes. This adapter never advances a clock or
completes a reader. The caller supplies actual barrier/publication ticks; a
successful nonempty publication and an explicit barrier follow their respective
host clock rules. Main ordinal 0 is a trusted schema declaration, not an entity
ID or constructor authority. Concrete records remain trusted adapter internals;
callback confinement depends on abstract declared operations, not module secrecy.

Run `python3 experiments/s-integrate/reader-host-run.py`. The controls create
worlds through `identity.create(identity.factory())`, reserve real handles with
full affine Motion/Health bundles, apply spawns, then actually queue/apply removal
of a and despawn of b. Lifecycle inputs are those commands' notifications. No
lifecycle ID is synthesized for publication. The first snapshot verifies that
Added/Changed did not become removal records.

At capacities 1 and 3, both schemas execute an initial frame, a publication,
a frame with no lifecycle boundary, a subsequent capacity/holder trim, failed
read, same-instance retry, late registration and successful completion. Output
contains actual boundaries, full handle namespace/ID sequences, full nominal Ping
codes, and three actual lag flags. Expected fixture factory ordinals only compare
observations; they never construct authority. Native/JS must match exactly.
The small capacities isolate adapter joins; the separate actual R/S C65536 tests
and the eventual full dispatcher retention trace remain distinct evidence.

Six adapter mutants must check, build and execute on both backends, then differ
at an actual checkpoint: dropped despawn, Added routed as Removed, suppressed
removal lag, wrong Main holder kind, lifecycle trimming despite None, and dropped
Ping publication. The last runs at C3 so later capacity loss cannot mask it.
A paired checker control accepts Motion handles and rejects Health handles in the
Motion lifecycle route. Checker and execution limits remain five seconds; code generation/clang use the
existing separate build limits. Evidence records source hashes and exact output.

This driver does not dispatch systems. It isolates the concrete factory/commands/
reader-host ownership join needed by the real dispatcher worker. Real system base
identity, nested/gated dispatch, query snapshots, transaction publication stamps,
access negatives, surviving storage marks and full E0–E11 parity remain integrated
obligations. Neither this file nor the operation draft approves new universal laws,
production APIs, performance thresholds, or global factory authority.
