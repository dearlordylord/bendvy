# S-USER-API #26 — implementation ledger

Status: implementation in progress. This ledger is not a completion report.
The user authorized filling the audited gaps through `$implement` after the
independent interface review. Optimization remains paused.

## Implemented boundaries

- Caller-defined typed stores contain independent component columns, including
  affine Type payloads and Data payloads. Closed lenses are trusted schema
  provisioning; they do not grant gameplay access by constructor secrecy.
- Replacement journals retain previous owned components/resources and undo in
  reverse order. Commands and events publish only on successful transaction
  completion; explicit barriers apply structural changes.
- Closed caller runners have an affine function-indexed registration owner.
  Execution validates its world namespace and exact registered metadata.
  Success-only cursor advancement preserves registration identity on retry.
- Deferred despawn has a schema cleanup declaration which drops component
  owners. Liveness-only low-level despawn is not the public integration route.
- Independent affine event readers observe an append-only Data event log.

## Evidence and remaining gates

Pinned bevy-ts executes all 23 frozen checkpoints using
`timeout 5s node examples/user-simulation/reference.mjs --verify`.
The final foreign-world collision has an approved Bend divergence; the other
22 checkpoints require an actual Bend application comparison.

Replayable bounded source/type controls live under `experiments/user-api`.
Their runner records source hashes and rejects timeouts. Design canaries are
separate from connected public-module controls. These are finite executable
and compiler controls, not ECS proofs or universal runtime refinement.

Still required before closing #26: connected public query/provider callbacks;
full frozen simulation; intended public access/ownership negatives with positive
controls; a fresh blind application author; independent Standards/Spec review;
reviewed bounded backend performance observations. Earlier optimization results
do not establish performance of these new generic interfaces.

## Explicit follow-ups

- Event retention/lag and affine event payloads: bounded log is append-only Data;
  return when independent-reader retention semantics are integrated and tested.
- Arbitrary affine captured callbacks and runtime-extensible heterogeneous
  schedules: current runners are closed templates in a typed static composition;
  return with a repeatable ownership-preserving capture interface and controls.
- Arbitrary typed query tuples and composable capability combinations: bounded
  combinators supply two families and explicit movement/damage/full bundles;
  return after a third independently authored application/query declaration
  demonstrates a need and its access/ownership negatives pass.
- Universal root provisioning authority and globally unique independent factory
  roots: shared affine Factory creates distinct namespaces, but concrete public
  constructors are not protected against a malicious root owner. Callback
  confinement requires separate rank2 tests; no universal authority claim.
- Optimized storage/provider integration and qualified performance: this generic
  component-family boundary requires fresh connected measurements before any
  adoption. JS/TS <= 1 and Native/TS <= 0.5, complete connected gates and the
  full five-family/three-size matrix remain binding and open.

No new ECS laws, proofs, dependencies, compiler/kernel/reference changes or
Canonical Tower Defense edits are authorized or delivered by this task.
