# #48 observed machine contract and pending decision

The pinned TS public API is the executable comparator. Node 24.20.0 directly executes reference.mjs with no dependencies. The frozen expected.json contains 24 complete checkpoints per independent schema plus raw provisioning/name controls. evidence/reference-v1/receipt.json binds actual sources, installed tools, complete TS source inventory and all three tracked reference commits before/after execution. No Bend implementation existed when this oracle was frozen.

## Actual observations

- Definition order is Flow then Level, despite reverse provision and pending-write order. The marker flushes structural commands before machine processing. Queued values remain separate from committed values until a marker; applyDeferred alone does not commit machines.
- Repeated aliases see the same pending slot; the last set/setIfChanged overwrites both value and skip flag. reset removes the pending value. set of the current state emits a transition and sets stateChanged; same-state setIfChanged consumes the request without publication.
- Conditions include inState/stateChanged/not/and/or, empty and=true/or=false, and schedule/marker changed-set boundaries. The condition tree carries machine requirements before execution. Earlier successful systems remain committed; a failed publisher restores prior queued values, resources and complete component cells, and discards its commands.
- Independent readers retain their own cursors. Failure retries see the same retained data; successful retry consumes it, repeated reads are empty. Registered skips discard backlog. Frame retention and registered failed-reader holds remain visible in complete public debug stream metadata and full deliveries.
- Missing machines refuse before frame/work. Raw JS invalid initial and queued values are accepted, not dynamically enum-validated. Duplicate initial provisions use the last value; duplicate machine definitions reject by name. Raw invalid values are separate from the typed finite-value boundary.

## Governing conflict — approval pending

Issue #48 says: “changes created during a marker remain for the next marker.” The actual pinned public API has an exception. The initial pending snapshot includes Level=1 and Flow=Pause; definition order processes Flow first. Its enter handler queues Level=2 and Flow=Boot. Runtime.ts:1534 deletes the current pending entry for each snapshotted machine immediately before processing it. When Level's turn arrives, that deletion removes newly queued 2; copied 1 commits. Flow's self-requeue remains and commits at the next marker.

The actual checkpoint marker-generated-and-definition-order ends Flow=Pause/pendingBoot and Level=1/no pending; next-marker ends Flow=Boot,Level=1. This uses valid declared machine values and public systems/transition bundles, not private maps or malformed input.

The staged candidate will reproduce pinned behavior as a reference investigation. No blanket retention acceptance or approved divergence is claimed. The decision remains explicit: preserve the pinned loss or deliberately provide stronger retention. #48 stays open pending the governing decision; no law/proof approval or silent contract amendment follows.

## Source authority and implementation scope

Pinned bevy-ts 3040a3b2a3f28fa8554d856f9ccb6bf5433fa334: Machine.ts337–425 declares reads/writes/conditions; Runtime.ts995–1065 journals pending changes per system,1133–1170 supplies views/conditions,1521–1602 snapshots/sorts/applies transitions,1390–1430 controls cursor success/failure/skip; internal/streams.ts defines keyed retention and capacity 65,536. internal/game.ts records definition order and binds schema APIs.

Pinned Bevy ad678262ce53b5d142fe49ee5e08caff6f00ab60: crates/bevy_state/src/state/resources.rs separates State from NextState; transitions.rs separates transition/exit/enter phases and emits transition messages. Rust informs architecture; TS behavior remains authoritative, including its identity-transition behavior.

Pinned Bend a950fd683c0d76f09794078e6174fe98a1492876 and installed 2.0.35 guide/Base determine affine quantities, closed templates, head matches and decreasing recursion. Machine values are finite Data; ECS components/World owners remain arbitrary Type. All actual Array payloads, returned owners, queue metadata and public stream deliveries are retained. New Type-owner and access boundaries require positive/negative controls; finite traces are not universal refinement. Full handler failure-position matrices belong to #49, while #48 covers publishing-system failures and successful hooks that create pending writes during markers.
