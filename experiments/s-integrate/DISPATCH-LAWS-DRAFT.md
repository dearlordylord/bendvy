# Dispatcher/capture subject draft — before bodies

Bounded #19 E2/E4/E6/E10 requirements, not approved general proof laws. Actual
subject names proposed below; finite oracle inputs are checked before implementation.
No field/payload/reader/counter simplification passes the integrated trace gate.

| Subject | Exact proposed observable equation / witness |
|---|---|
| `dispatcher.preflight` / `tick` | Traverse all nested declared requirements before any invocation, capture increment, reader begin or Audit effect. E10 missing MotionLedger/HealthLedger or Audit returns exact MissingRuntimeRequirements entries and untouched owners/counts; both present permits E2 B/code7. Conditions do not erase declared requirements. |
| `dispatcher.run` / `schedule.Nested` | E2 actual A,Fast,[B-fail,TailInner],TailOuter commits A; B failure returns original base name B/code7 and suppresses both tails. E4 same B base retry succeeds once and both tails run; nesting does not create a new reader/capture identity. |
| `capture.invoke` | Every actual invocation increments slot0 of its own Local Array<U32>; preserves slots1–3. E2 failed B increments1→2, E4 retry2→3; skip whileOff preserves5. Direct returned owner and regenerated once-only closure have identical full observations; no shared/reset capture. |
| `dispatcher.condition` | B gates on actual nominal MotionMode/HealthMode field, initiallyOn; authored SetOff+T/SetOn+T determine state. Skip precedes callback/begin, advances only existing message boundary and increments no capture. |
| `systems.provision` / `invoke` | Rank2 callback receives fresh schema-specific main/resource read/set, structural/Ping and Audit operations over arbitrary affine Tx/provider. Trusted provisioning binds actual selected handle; no world/journal/restore capability. Returned Tx+capture+outcome governs actual finish. |
| `systems.audit` | A:attempt:1 and B:attempt:2/3 call the declared actual external IO service before returning outcome. Failure does not retract IO; invented post-hoc strings are not evidence. |

Preimplementation finite oracle: requirements ledger/audit bothpresent versus each
missing; A1/Fast3/B2/tails0 failure versus incorrectlyadvanced tails; retryB3/tails1
versus reset/newB1; Off skipB5 unchanged versus6. Full E2/E4 storage projections,
raw failed5/subsequent6 reservation and inverse journal are bound to reviewed
shared transaction predicates; dispatch observations must carry those actual
results, not produce expected tuples in lieu of running systems.

Implementation starts with checked registry/capture/schedule/preflight; concrete
Motion/Health world/Tx and reader/log hooks join as committed modules become
available. A partial hook is reported open, never counted as complete E2–E10.
General proof needs exact-law approval; compiling semantic mutants and fresh
Native/JS trace checks follow actual subjects. No new dependency or production
root/reuse/Local/destructive policy is selected.

Checked glue checkpoint: `dispatcher.bend` threads the actual affine registry,
reader invocation owner and Audit owner through nested schedules. `run` aborts
both tails on failure, obtains failure identity from the registered entry, applies
explicit barriers, and records successful SetOn/SetOff for the explicit transition.
Reader begin/complete/skip use the committed reader module. Trusted adapters must
supply actual world presence, command application and opaque callback invocation.
The closed fixture permits at most32 registered entries; dispatcher searches use
that explicit fuel. Declared reader interests currently correspond to the main
trace's Ping/Main ordinal0/despawn declarations. There is no public tick setup or
frame-retention join yet. Checker success is signature/body feasibility only;
full dispatcher Native/JS execution and semantic mutants remain open.

Next checked join: `dispatcher.tick` now observes actual World Ledger presence
and retained actual Audit owner, preflights every nested declaration, and calls
the trusted frame adapter only on empty missing requirements. The adapter owns
actual log trimming/holder mechanics and returns World/Readers/Clock; it is not
a callback capability. Mode carrier is present in trusted-created worlds.
Tick/count/key aggregate bounds and concrete Host adapter binding remain open.

Finite source controls executed using `experiments/t05/run.py`'s `build` and
`paired(...,quoted=True)` with temporary output directories (checker5s,
codegen30s, clang120s, each runtime5s), source `dispatcher-controls.bend`.
Both Native and JS produced exactly:
```
present=
missing=resource:MotionLedger;service:Audit;
returned=2:2,0,0,0
regenerated=2:2,0,0,0
```
Two isolated compiling source mutations were rejected by that unchanged expected
output on both backends: replacing `preflight` Nested branch union with only
`preflight(tail,ledger,audit,state,ledgerName,stateName)` erased missing entries;
replacing capture Regenerated `call(closure(local))` with
`call(closure(initial()))` changed regenerated result to `1:1,0,0,0`.
An earlier inadequate fixture repeated B outside nesting and missed the first
mutation; revised fixture has B only inside nesting and a requirement-free Tail
outside. This evidence covers preflight traversal and capture continuation only.
It does not establish failure-tail execution, owner-invariant rollback, full
reader tuples or E0–E11 integrated reference parity.

Closed A callbacks now exist for both schemas: set actual selected main.slot0=11,
Ledger.slot0=101, read full updated projections, reserve/stage flagged p V(50),
remove selected A Flag, stage Ping1 and invoke actual provided Audit action with
real capture count. `spawn_flagged` is a distinct trusted capability. Bounds in
the accepted trace guarantee reservation success; the callback parameter carries
an explicit rejection outcome for callers outside that fixture, rather than
selecting a production error policy here. Checked callbacks alone do not prove
concrete adapter/runtime observations; that join remains required.
