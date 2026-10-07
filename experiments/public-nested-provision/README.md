# Public nested schedule provisioning — #34

Finite application evidence, not a universal proof or performance qualification.
Root owns `schedule-provision.bend`; this directory independently instantiates
its public API with actual `Sys.register`/`Sys.run` registries and owned Worlds.

## Application and observations

`app.bend` and `other.bend` define independent nominal schemas with the same
12 authored scenarios. `main.bend` executes both. Each application owns a real
Column with affine `Array<U32>` components; replaced payloads remain in an
observed affine retired-owner list. Resources and service state are real
Ready/Missing/Incompatible slots containing Array owners. Component-family
provisioning is a typed record: DeclaredFamily contains the actual nominal
`C.Family` descriptor, WrongFamily contains an Other-schema descriptor, and
AbsentFamily contains none. Availability comes from matching these records;
a physically absent entity component does not imply an unavailable family.

Registered runner owners invoke the actual public component replacement API,
resource mutation, service callback, event publication and command enqueue.
Attempt counters are coupled to those operations. The service callback threads
its owned state and count; it is not an installed external IO host or a claim
about transactional rollback of arbitrary host effects. No body failure or host
rollback behavior is invented here. Conditions have a separate invocation count.

The scenarios cover nested left-to-right phases/systems with empty branches,
first-occurrence requirement union (S1,R1,C1; identical numeric IDs remain distinct
categories), duplicate systems across nested branches, absent/incompatible
resource/service/family provisioning, a false condition with declared
requirements, empty composition, available family with absent entity component,
and simultaneous missing service/resource. Every refusal records unchanged
component/resource/service owner cells, retired owners, registry metadata,
clock, event/command counts and every attempted-work counter. Missing schedules
return their owners and successfully retry after repairing actual slots. Repair
moves incompatible Array owners into Ready slots; it does not replace those
owners with copied payloads. Full observations are retained, not reduced to sums.
Queue counts are owner-preserving structural counts of actual callbacks; this
fixture's queued callback is identity. This is not a full arbitrary-command
payload trace, a lifecycle-stamp proof, or a schedule-reader qualification.

## Observed pinned TypeScript boundary

`reference.mjs` executes the pinned public bevy-ts runtime using Node directly,
without installing packages. Public inspectors read actual post-run component
and resource values. It observes nested flattening, duplicate rejection,
first-occurrence service/resource union, false-condition provisioning, empty
composition and missing provisioning before any work. Seven common application
traces match JS/Native counters, cells, events, queue attempts, requirement union
and complete ordered missing lists. Component-family provisioning is Bend's
additional trusted nominal-schema gate; TS Requirement does not contain that
category. Schema-specific phase labels map to empty TS phase systems.

Pinned TS runtime checks presence, not malformed JS value compatibility. A present
null service therefore reaches the body: one component and resource write are
attempted, then TypeError occurs. Actual TS World values roll back to their
initial cells; attempted-write counters remain one. This raw-input observation
is retained separately, never normalized into pre-execution refusal. Bend's
Incompatible slots reject before work as the explicitly stronger typed/raw
boundary. A malformed Ready payload also fails the checker.

The initial core prototype returned only the first missing requirement. The
both-missing observation exposed that discrepancy; root repaired the API to
return ALL missing requirements in unique authored order. Current tests retain
the entire S1,R1 list. The initial source-drift INCOMPLETE receipt remains at
`.artifacts/public-nested-provision-first`; it is not current acceptance.

## Reproduction and current evidence

```
python3 experiments/public-nested-provision/run.py --output .artifacts/nested-provision-replay
```

[evidence/current/receipt.json](evidence/current/receipt.json) passes31 commands on
P source `45d8b7d2c11d9fe28a6ee2a4cd460bad2b8591dbc8546daa68ae29d66d3979e9`.
Both backends agree on all scenarios and retries. The access positive checks;
cross-schema composition, affine schedule duplication, undeclared abstract-owner
access, writes through read, and malformed typed provisioning reject for their
intended diagnostics. Actual-core omitted-requirement and precheck-bypass mutants
check, emit, compile, execute and are detected on JS and Native.

The runner freezes the complete recursive Bend import DAG, authored fixtures,
TS oracle and harness before copying. It verifies the copied inventory and all
normal/mutant inputs before and after each operation, records intentional mutant
hashes, restores the stage and checks the final live-source closure. Referenced
TS source and installed Base hashes are guarded; tracked reference commits are
verified. Unimported concurrent core additions do not invalidate this semantic
closure. Caps remain checker5/emit30/Clang120/runtime5. There was no CPU pinning,
timing, profiling or dependency change. Contention timeouts are inconclusive,
not semantic regressions.

Independent review, unchanged old-consumer replay and the final shared regression
gate remain integrator responsibilities. This evidence does not close #34 by
itself or claim #35 reader-lifecycle delivery, universal authority, production
layout selection, or full-core parity.

The refusal-validator revision binds every refused mode to its complete original
resource/service cell lists (or explicit missing/incompatible representation),
family descriptor state, and both returned registries' namespace, ID, name,
complete access list and cursor. Its 24 observation-corruption controls change
both nominal schemas identically before retry and require rejection; these are
validator controls, distinct from the two reached actual-core mutants. Earlier
receipts retain their earlier validator scope.
