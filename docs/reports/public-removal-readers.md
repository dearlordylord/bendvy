# Public removal/despawn reader implementation (#32)

## Outcome

Additive observed Structural removal and Commands despawn entry points publish
records from actual successful barrier application. Removed affine owners are
released immediately; schema cleanup releases every declared component family
before publishing its real removal records and the final despawn record. Duplicate
queued despawn commands recheck current liveness and publish only once.

Public typed removal readers register in the actual World, bind their selector
in the reader's erased type index, preserve independent positions and advance
only after success. Failed readers and skipped runs preserve backlog. Actual
namespace/registration checks precede callbacks; disposal removes registration
and the last disposal clears the owned metadata log. Ordinary APIs are unchanged.

## Evidence

Run `python3 experiments/public-removal-readers/verify.py --output <fresh-directory>`
for correctness; add `--timing` for optional raw timing. Output is never overwritten.
The runner snapshots the full imported ECS source closure before executing any
checker/backend process; its retained receipt hashes that exact closure, verifier, oracle and fixtures.
It records tool versions, compares all three actual reference HEADs to the tracked
manifest, guards the TS source inventory and rechecks source/reference drift. This
prevents unrelated parallel edits from becoming accidental mixed-version evidence.

- Actual pinned TS public systems/commands/barriers and Bend JS/Native agree on
  all 12 ordered read outcomes and all four final component slots, including the
  surviving Array-backed B owner. Deferred insert/remove/despawn, failed queued
  removal while present, absence/repeat, duplicate queued despawn, independent
  slow readers, skip and failed-reader retry are exercised.
- Native-only exact disposal observations: four retained records remain after
  the first reader disposes, then zero after the last disposal. This separate
  observation is not described as a TS disposal checkpoint.
- Actual shared-factory worlds reject a reader from another runtime world on
  both execution backends, including disposal. Rejected disposal recovers the
  same affine reader owner, which then disposes successfully in its original
  world. A stale entity public lookup must
  return MissingEntity before the final cleanup observation can execute.
- Duplicate-reader ownership, wrong family, cross-schema records and component
  writes through metadata readers reject at their intended expressions.
- A compiling mutant advances the failed reader's cursor and loses the successful
  retry's three records; exact full observations detect it on both JS and Native.
- Equivalent feature timing excludes the native-only disposal/foreign controls;
  all five raw whole-child samples per TS/JS/Native role validate the same full
  workload output. Startup and printing are included, no outliers are discarded,
  and these samples do not qualify hot-path/product performance.

The pre-hardening timing cohort is retained separately under
`evidence/timing-before-verifier-hardening/`; the current primary receipt is a
fresh correctness-only run of the hardened verifier. Its raw timing medians were: TS 80.443 ms, JS 18.918 ms, Native 4.677 ms.
These are the feature workload's whole-process samples, not the #28 regression
gate or a qualified performance claim. The fresh primary receipt and command outputs are in
`experiments/public-removal-readers/evidence/`.

Commands use checker5, emission30, existing approved private Clang19 build120 and
runtime5. No new dependency, proof/law, compiler/kernel edit or canonical app
change is included. One earlier unfrozen verification was invalidated by an
unrelated concurrent column edit and failed an intended-negative diagnostic;
this did not count as a passing rejection. The fresh frozen replay replaces it.

## Limits and remaining delivery gates

Removal metadata is conservatively retained while any reader remains registered;
minimum-reader garbage collection and finite-capacity lag diagnostics remain
explicit full-core #1 follow-ups in the design policy. Removed component owners
are not retained. The ordinary event Runtime has a separate retention domain;
#35 must compose these policies explicitly rather than trim a mixed log.

Independent Spec/Standards review, root's final integrated replay and the unchanged
#28 paired Workshop regression gate are required before ticket delivery. This
worker report alone does not close #32 or establish full-core parity/universal
runtime refinement/full performance matrix acceptance.

## Independent integrated replay

Initial integrated root replay PASS is retained in `experiments/public-removal-readers/evidence/root/receipt.json`. This receipt binds its recorded source snapshot. Later storage/component changes require a fresh final-source replay; performance and final delivery remain separate.

## Root shared-live source replay

Fresh root verification passes complete reader/payload/cleanup observations, four intended negatives, foreign-disposal owner recovery and the reached cursor mutant on JS/Native. Source-bound receipt and full outputs: `experiments/public-removal-readers/evidence/root-current/receipt.json`. Five equivalent whole-process samples have medians TS82.756ms, JS19.719ms, Native4.188ms; these include startup/printing and do not qualify product performance. Common regression and delivery remain pending.


## Current shared-source replay — 2026-10-07

Fresh root replay passes on Column `3fec368b`, captured-column `340efc23` and indexed-lifecycle `e997f3b0`: removal/despawn checkpoints, affine payload cleanup, foreign retry, confinement controls and cursor mutation. Source-bound receipts, full observations and retention hashes are in `experiments/public-removal-readers/evidence/indexed-core-current/`. Five complete feature timing observations per backend are retained in `evidence/indexed-core-timing/`; they include process startup/output and do not qualify hot-path performance. Historical receipts remain historical.

Independent final Spec and Standards reviews identify no blocking bounded-feature functional defect. The unchanged default #28 gate passes on the current core; all recorded source hashes match. The additional prepared-provider gate remains failed for #30 and is not this ticket's shared regression requirement. Commit/push and governing issue reporting remain pending; this update does not close the issue or parent qualification tasks.


## Delivery

Delivered in [bfb4360d](https://github.com/dearlordylord/bendvy/commit/bfb4360d) on master and pushed to the project repository. The governing issue now has an English acceptance/evidence report and is closed. The bounded scope is complete; #30, full parity and product qualification remain open.
