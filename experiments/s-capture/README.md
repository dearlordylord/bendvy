# S-CAPTURE — repeatable affine state and reversible restoration

Issue [#17](https://github.com/dearlordylord/bendvy/issues/17), parent
[#1](https://github.com/dearlordylord/bendvy/issues/1), [SPEC](../../docs/SPEC.md).
Baseline `484fb88`; investigated 2026-10-03 in an isolated worktree. Read the live
issue, ticket, checkpoint, Astra review, source-law decision and T04/T06/T09,
R-A/R-C1 reports. Applied implement, Bend and bend-ldd; used the TDD skill's
already approved public trace and paired checker seams. The first actual TS
slice preceded the owner prototype, then the scenario grew in small slices;
this research does not claim a complete recorded red/green history. Ran Bend
version/guide before Bend work.
The coordinator will perform the implement skill's two-axis code review after
integration; this report does not claim that review has already passed.

**Bounded research succeeds:** explicit owned per-instance state repeats and
remains isolated; regenerating a one-shot affine closure from its returned owner
also works. Actual owned-array inverse restoration preserves earlier commits,
publications and the failed reader's position at the recorded boundaries.
**General captured-state/Local and arbitrary destructive-payload restoration
remain unresolved capability gates.** Neither a production System interface nor
new Local semantics are approved by this result. No ECS proof was written.

## Owners and repeatable call boundary

`local.bend` defines `Local{counter:Array<U32>}` as **Type**. This is a proposed
experimental representation; the pinned TS core has no dedicated Local API.

```text
local.initial : () -> Local
local.invoke  : Local -> Local & U32
local.observe : Local -> Local & U32
closure.make  : Local -> (Unit -> Local & U32)
closure.invoke: Local -> Local & U32
system.step   : @-T:Type ->
  (T -> Motion -> T & U32) ->
  (T -> Motion -> U32 -> T) -> (T -> Motion -> U32 -> T) ->
  (T -> T & String) -> (T -> U32 -> String -> T) ->
  Mode -> Bool -> U32 -> T -> Prepared<T>
schedule.loop : List<Input> -> ScheduleOwner -> String -> String
```

`ScheduleOwner` owns A's Local, B's Local, an affine World and a Data tail count.
Each invocation consumes/returns exactly the selected Local and world owner.
The counter observation is Data; the Local/Array is never marked reusable.
The independent explicit-owner and regenerated-closure canaries print `2,1`
on Native and JS: A ran twice, B once, each from a separate initial owner.
The latter calls each closure once, returns its captured owner and constructs
a **fresh closure** for the next call. A single captured closure cannot be
called twice; the paired negative fails at the intended affine-use diagnostic.
This supports a factory/state-threading seam, not a freely reusable closure.
The runner also rebuilds the **whole schedule variant** with `closure.invoke`
instead of `local.invoke`; both variants must match all39 actual TS checkpoints
on Native and JS, including skip, typed failure, restoration and retry.

`system.step` is checked for arbitrary affine T, with no concrete World/Tx
argument. Trusted provisioning supplies fresh read, two write, projection and
publication functions. Two separate affine write values permit B's two writes;
neither setter closure is copied. All constructors/functions remain public.
The `schedule.provision(~body, ...)` template receives the closed generic
application body and supplies those fresh operations for each invocation.
The callback's returned `Prepared<T>` includes the sole T and typed Outcome;
nested parent dispatch propagates B/code7 and omits Tail on failure. A read-only
projection returns a String plus its retained owner, never a writable Array.

## Actual TS behavior and matching trace

The independent `reference.mjs` imports the pinned public core directly with
existing Node. Its `instance` factory creates two **separate lexical counters**,
not a module-shared substitute. TS `Runtime.ts:1366–1377` ties reader state to
the system/base instance; `1387–1428` skips before callback invocation and
advances completed reader positions only on success. `1051–1064` restores ECS
transaction stores and clears staged events, with no lexical capture journal.
A search of pinned `packages/core/src` for `Local`, `localState`, `writeLocal`
and `readLocal` returned no matches. Lexical behavior is the reference subject;
an ECS-owned Local API's lifecycle/rollback policy remains a distinct decision.

`expected.txt` contains **39 ordered freshly executed Native/JS/TS lines**:

- Empty schedule changes neither owner nor callback count. Initial B no-op
  registers its reader and increments only B's capture to1.
- A's earlier success commits `[11,20,30,40]`, message1 and `remove:A`.
- B reads message1, advances its capture to2, writes slot0 twice (21 then31),
  stages message9/`insert:B` and returns typed failure B/code7. The world restores
  `[11,20,30,40]`; earlier `remove:A` and unread1 remain. Tail stays2; B capture2
  persists, as in the actual TS lexical environment.
- Retry increments B to3, reads message1 **again**, commits31 and publishes9
  and `insert:B`. The next B run sees9, reaches capture4 and commits51.
- A's independent second run reaches capture2 and commits52; B still has4.
  A's message2 and B's9 are both observed by B's next no-op, whose capture is5.
- Explicit state-transition barriers in the TS scenario flush the pending
  structural commands. The bounded Bend queue is cleared at the same normalized
  barriers. A separate publisher emits7 while B is disabled: unread1 becomes0
  on skip, B remains5, and its next actual no-op reaches6 and sees no backlog.

The command observation projects public TS pending-command tag/publisher for one
fixed input entity. Bend stores that projection and clears it at explicit
barriers; this experiment does not contain Tag membership storage or validate
general structural application, allocation or command-target authority. Those
integration obligations remain separate from the observed publication boundary.

Reader positions are observed through actual reference event reads and public
`debug.streams()` unread counts. Bend's bounded saved position is the index into
its retained event sequence. The skip/failure/retry observations establish these
inputs; they do not identify index positions with the general TS tick clocks.
Capacity/retention/lag, changes and lifecycle cursors are not implemented here.

The `host:*` labels in the TS callback are real `console.log` effects. In Bend
they are **diagnostic trace strings**, printed after the pure schedule by main;
their equality does not execute a native external effect before failure and
does not validate host-IO rollback. Host IO is outside ECS rollback and the
provider sandbox claim. No rollback of lexical captures or outside effects is
invented. Local is intentionally outside the experimental ECS transaction to
match these capture observations; that is not approval of a new ECS Local policy.

## Restoration algebra and precise destructive boundary

`World` owns `Payload{items:Array<U32>}` as Type. `write` projects the old U32
at fixed slot0, records it in a LIFO inverse journal and writes the new value
into the **same returned owner**. Abort applies these inverses in reverse mutation
order. Read-your-writes and all four payload fields are observed; entries20/30/40
never change. Neither `Array.clone` nor a Data replacement world is used.
The Data journal stores numeric old values, not a copied Type payload. Normal
success publishes staged entries; failure drops them and preserves earlier lists.

This algebra supports fixed-slot numeric replacement with a retained array and
recoverable old values. It does **not** restore an arbitrary callback that drops
an affine element, consumes a closure/handle, performs an irreversible effect or
replaces a Type payload without keeping its old owner. Affine discarding is legal.
`destructive-negative.bend` actually transfers a payload to `discard` and tries
to return its former alias: the checker rejects repeated consumption. Its positive
retains the owner. `snapshot-negative.bend` tries to make the owned Payload Data
for a duplicate rollback snapshot and fails `expected Data / observed Type`.
Installed Base `Array.clone(-T:Data,...)` likewise requires Data elements.
These refute those concrete recovery approaches; they are not a theorem that
all possible Type restoration designs are inexpressible.

**Bounded redesign seam for S-INTEGRATE:** own per-instance state separately,
invoke closed providers or regenerated once-only closures, and require declared
mutations to return the updated owner plus a valid inverse/retained prior owner.
Destructive mutation with no recoverable inverse needs an explicit rejection,
retained-owner API or contract decision **before general callback rollback is
accepted**. Do not silently restrict the full runtime to numeric/Data payloads.

## Reproduction, controls and mutations

Run `BENDVY_CPU=9 python3 experiments/s-capture/run.py`. No new dependencies.
Requires existing Bend2.0.34, Node24.20.0 and clang14.0.6. Read-only absolute
reference paths permit execution from isolated worktrees; the tracked manifest
is checked against all three actual HEADs. `results.json` records compiler/Base
SHA256, pins, source hashes, bounds, six paired controls and five mutant witnesses.

The runner reuses dependency-free T05 process/build helpers: every checker and
runtime/actual-reference invocation has a **five-second** limit; code generation
30s and clang120s are distinct build stages. Native uses one worker/GPU off,
clang `-std=c11 -O3 -lpthread -lm`; JS uses existing Node. Temporary build and
mutant directories are deleted. Only the task's child processes are controlled.
Recorded affinity is CPU9, while unrelated parallel investigations run elsewhere;
this is correctness evidence, no timings/performance claim.

Every positive control must exit0 with `ALL PROOFS CHECK`; every negative must
exit1 with `SOME PROOFS FAIL`, exact expected/observed and `Location: bad`:
undeclared read, writes through read (`Tx` versus abstract T), other schema token
(`Motion` versus `Other`), twice-used closure, duplicated Type snapshot and a
consumed destructive-transfer alias. Token evidence is a nominal second schema
boundary, not a second complete integrated world or runtime namespace theorem.

Each mutant first passes the same checker, then compiles/runs on **both** backends
and must disagree with the actual reference while Native/JS agree:
reset persistence to1; route B through A's single counter; omit inverse restoration;
reverse the inverse journal; advance the failed reader. The state-routing mutant
shares one affine counter operationally across the two callbacks, not by forbidden
Array aliasing. First differences are persisted in `results.json`.
An early reset mutant written as a standalone annotated literal failed inference;
it was corrected to a typed arithmetic expression and **only the compiling
version** counts as killed. Forward-def/order and computed-match prototype errors
were corrected, not counted as capability failures.

## Acceptance ledger and retained integration work

| #17 acceptance item | Fresh evidence | Limit / next obligation |
|---|---|---|
| Owner signatures/repeated isolation | Owner/closure canaries; both full schedule variants | General state registry/lifetime not selected |
| TS success/skip/failure captures | Actual reference + source locations | No TS Local API; Bend host labels are diagnostic |
| Earlier commit/failure/restoration/retry | 39 ordered three-backend checkpoints | One owned payload, two fixed numeric writes |
| Restore Type without cloning; destructive boundary | `core.finish`, inverse trace, snapshot/destructive paired negatives | General recoverable mutation algebra requires decision |
| Saved failed reader position | Unread1 remains; retry reads1; skip drops7 | Full clocks/allocation/marks/cursors → S-INTEGRATE |
| Nested failure + access confinement | No Tail on B/code7; six paired controls | Closed finite provider boundary; arbitrary Base IO excluded |
| Meaningful compiling mutants | Five Native/JS mutant differences | Finite witnesses, no general ECS law proof |
| Runner/pins/bounds/evidence layers | `run.py`, `expected.txt`, `results.json` | Source2.0.35 not claimed identical to binary2.0.34 |
| Integration seam + full-scope follow-ups | Restoration seam and list below | Research completion does not accept capability gaps |

Retain: captured Type elements and IO handles; arbitrary closures returned from
providers; dynamic instance registration/disposal and identity; Local lifetime
and rollback policy; resource/service captures and missing-provider behavior;
shared callbacks over multiple schema compositions; dynamic schedules/conditions/
phases; general destructive restoration; allocation/marks/readers rollback;
relations/scopes/machines and snapshot recovery; universal provider/runtime
refinement; equivalent integrated performance. These are return conditions for
later detailed S-INTEGRATE and full-core work, not removed requirements.
The experiment chooses no production storage, numerical threshold or dependency.
Specific laws remain unapproved, and the original Tower Defense repository and
all read-only references were untouched. Coordinator owns review/delivery/tracker.
