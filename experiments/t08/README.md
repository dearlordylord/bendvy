# T08 — independent change and lifecycle observations

[Issue #9](https://github.com/dearlordylord/bendvy/issues/9), [SPEC](../../docs/SPEC.md).

An owned Type World threads ordered Data row projections, deferred commands,
separate removal/despawn logs and two independently stored reader positions.
Added/changed select live present components by their marks and return current
committed values. Writes commit without a structural marker; insert/remove/despawn
remain pending until an explicit flush. Existing-component overwrite preserves
its addition mark; reinsertion stamps both marks. Failed writes restore both
values and marks in this Data projection experiment.

A reader has distinct change/lifecycle and buffered-message positions. Failure
preserves both; skipping advances only the message position. Registered lifecycle
readers retain removal/despawn records across empty frames and entity destruction.
New readers can still find old additions/changes on surviving rows after sparse
change logs have expired: this prototype scans marks rather than copying a sparse
cache. Records for absent/dead entities are observed through independent logs.

## Evidence and reproduction

```
BENDVY_CPU=11 python3 experiments/t08/run.py
# Affinity is optional; python3 experiments/t08/run.py also works.
```

The run passes 31 ordered native/JavaScript/fresh TypeScript observations:
21 public combined-reader checkpoints, 5 public retained-change/removal checks,
1 public unheld-expiration check, and 4 internal capacity/lag boundaries. Public
cases use unmodified bevy-ts systems/schedules, including actual state-conditioned
skips and failures. IDs are mapped from actual reservations to scenario labels.
The internal adapter separately runs both removed and despawned logs at capacity
3 and asserts identical boundary results. It drops one of four records published
at the same tick, retaining the other three; public capacity stays unchanged.

Nine compiling native/JS mutants are detected: cursor advancement on failure,
lifecycle advancement on skip, message preservation on skip, overwrite counted
as added, failed write leakage, implicit structural flush, ignored holders,
ignored capacity and ignored registration when reporting lag.

Bend 2.0.34 / pinned Base, clang 14.0.6 -O3, Node 24.20.0;
native --threads 1 --gpu off. Checker/runtime deadlines are five seconds;
code generation is bounded at 30 seconds and clang at 120 seconds. No new
dependency, proof, numerical performance acceptance or universal refinement.
[CANDIDATE-LAWS](CANDIDATE-LAWS.md) are draft, unapproved obligations.

## Representation boundaries and return gates

The closed trusted driver addresses unique predeclared IDs and one component
with a U32 projection; it is not a schema/access provider or production System.
The affine World owner does not make its immutable Data projections affine
payloads. Data snapshot restoration here does not prove arbitrary Type payload
rollback; T06 separately exercises owned-array inverse restoration. T05 separately
establishes world-scoped handles, absent from this observation-only probe.

Lifecycle records use one singleton batch per record; this preserves upstream's
individual-record capacity behavior. The copied log primitives are local and
kept separate from the event batch/skip policy; no common production log API is
selected. General payloads, declared reader authority/lifecycle, allocation/tick
rollback, nested schedule integration, sparse/indexed storage, clock exhaustion,
scalable retention/update cost and runtime-to-model refinement remain gates.
Nonwrapping U32 clocks and valid fresh commands are explicit preconditions.
