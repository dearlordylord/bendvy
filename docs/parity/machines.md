## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

An application declares finite machines, reads committed states, queues changes and gates schedules by machine conditions at explicit transition markers.

## Acceptance criteria

- [ ] Observe pinned initial provisioning, missing/invalid machine values, queued overwrite, same-state/skip behavior, definition order and inState/stateChanged/not/and/or conditions.
- [ ] Apply transitions through actual schedules with explicit structural flush semantics. Failed publishing systems discard their machine changes; changes created during a marker remain for the next marker.
- [ ] Execute independent transition-event readers with exact retention/cursor rules and complete machine/world/queue observations. Reject undeclared/cross-schema writes and detect a reached early-commit or queue-loss mutant.

## Blocked by

- #34

## Delivery and evidence

The integrated [ordinary machine operations](../../src/ecs/ordinary-machine-operations.bend) construct typed `ValueRead` and `ValueWrite` capabilities from the existing nominal declaration and trusted schema lenses. Gameplay bodies receive an opaque owner; the writer accepts `Set`/`Reset` requests and uses [comparator-aware queueing](../../src/ecs/machine-queue.bend). A conditional request preserves an existing forced comparator-equal value, including its original representation.

The [bounded delivery](../../experiments/public-machines/remaining-core-v1/ordinary-frontend-v1/README.md) records complete rollback, two nominal schemas, four intended access/ownership refusals and a reached dropped-write control on JS/Native. Public relocation qualification and the combined regression remain separate gates. This does not close the marker, provisioning, reader or full #48 acceptance criteria above.

- Apply the [SPEC reference order](../SPEC.md#implementation-decisions): Rust Bevy architecture and ECS semantics first; Bend types, affine ownership and runtime constraints second; bevy-ts feature inventory and porting inspiration third. Record exact reference commits. Execute bevy-ts comparisons for shared agreed scenarios, not as a blanket behavior authority; preserve approved contracts and record reference differences explicitly.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native correctness observations without dropping work; keep boundary and capacity correctness checks. Comparative timing/scaling is qualified on the combined feature workload under #21/#23/#24 and is not a prerequisite for individual semantic delivery. Consequential hot-path changes and detected regressions still require targeted performance investigation. Final JS <= TS and Native <= 0.5 * TS goals remain unchanged. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.

## Ordinary initialization delivery

Rust Bevy `ad678262` (`crates/bevy_state/src/app.rs`, `state/transitions.rs`) governs the next public initialization slice. This dedicated delivery follows the user's Bevy-first default direction; it supersedes the historical report's proposed no-notification provisioning slice rather than silently promoting that experimental policy. `init_state` preserves an already initialized state without evaluating its default again. First initialization publishes an initial notification with no exited state. `insert_state` replaces current state and prior transition messages while retaining an existing pending next state. Initial dispatch runs `OnEnter`, without inventing an exit or a same-state transition. Actual system-relative change observation and skipped-reader preservation must be checked at the consuming paths; the experimental empty-slot initializer's absent message and `changed=false` are not the public default.

Implementation owner: `missing_resource_direct_consumer`; shared-core integration: root; independent source/complete-oracle owner: `debug56_reader_product_oracle`. Reuse the qualified private provisioning and cleanup evidence only for unchanged reached branches. Acceptance starts with a complete ordinary two-schema consumer on JS/Native, covering repeated init/insert, pending-next preservation, initial and later marker ordering, independent readers, skip and actual changed conditions. Then apply affected authority/mutation and regression gates and one independent final review. No new ownership contract, law, dependency or performance tolerance is selected by this implementation slice.

### Ordinary initialization acceptance

The public declaration-bound `init_state`/`insert_state` and App marker wrappers are integrated with initial Enter notification, occupied-init idempotence, pending/previous preservation and registered change observation. The [consumer and retained evidence](../../experiments/public-machines/ordinary-initialization-v1/current-delivery-v1/README.md) pass full JS/Native observations (105,004 bytes), an independently predicted reached idempotence mutant, affine `Type` admission and nominal-schema refusal. Independent Spec/Standards review passed; unchanged protected #28 source bindings are reused only for that workload. No new performance claim is made.

Full #48 remains open for issue-level reconciliation of capacity/retention frames, broader conditions/marker combinations, disposal and foreign-authority applicability. Condition-false noninvocation preserves readers; this slice does not introduce a reader `run_if` API. Mirror checker recaptures hit the five-second deadline and remain inconclusive, separately from its successful full mutant execution.

### Stateful condition composition acceptance

The ordinary App schedule now accepts affine `in_state`/registered `state_changed`
conditions composed with `not`, lazy `and_then` and lazy `or_else`. Bindings target
actual scheduled system IDs; an unbound system runs unconditionally. A skipped
right-hand condition retains its owner and cursor. Debug descriptions derive the
condition structure and accesses from these same declarations.

The [current consumer packet](../../experiments/public-machines/remaining-core-v1/condition-readers-v1/current-source-v1/delivery-v1/README.md)
retains complete two-schema JS/Native observations (17,373 bytes), affine and
cross-schema controls, and a reached eager-RHS mutant that rejects the normal
oracle. Independent Spec/Standards review passed. Backend evidence binds the
82-path producer import graph; adoption checks all 68 canonical source bodies
and the relocated entry, with only a recorded trailing-newline normalization.
Unchanged protected #28 bindings are reused for that workload only.

Full #48 remains open. The historical 65,537-record run selected an experimental
queue; current canonical execution is covered separately below.
Marker-retention and foreign/disposal evidence still need exact current-source
joins. This slice does not establish arbitrary fallible custom-condition parity,
all refusal branches, or combined performance acceptance.

### Canonical stream capacity

The FIFO representation caches retained event and batch counts, avoiding growing
list copies on publication and repeated full counts at each frame. It preserves
ordered expiry then capacity eviction, whole-batch removal, empty batches,
reader positions, dropped ticks, initial replacement and skipped-reader identity.

The [current packet](../../experiments/public-machines/followup/canonical-stream-capacity-v1/delivery-v1/README.md)
retains complete JS/Native output for 65,537 publications per nominal schema
(19,367,810 bytes), a reached no-eviction mutant, boundary/lifecycle controls,
and both ordinary initialization and condition consumers using snapshots.
Independent Spec/Standards review and root adoption verification pass.
The focused 1,024-publication-per-schema profile preserves all 33,072 output
bytes. Sampled allocation estimates were 136,924,608 bytes for the old list and
32,824,456 for the FIFO; old append/reverse stacks dominate the removed costs.
These are allocation samples under contention, not RSS, physical allocation
totals or comparative speed qualification. The protected #28 workload’s current
23 source pins remain unchanged. Its recorded World pending-count difference
and this stream representation are unreachable from that workload; reuse covers
only the existing workload.

Marker-retention, failed-publisher and foreign/disposal applicability still need
exact current-source reconciliation before closing #48. Combined performance
qualification remains under #21/#23/#24.

Remaining source reconciliation can reuse
`remaining-core-v1/marker-phases-v1/apply-retention-v1/EVIDENCE.json`
(registered callback pending retention, no stream reached) and
`remaining-core-v1/ordinary-frontend-v1/PROMOTION.json` (failed publisher rollback,
no stream reached). The existing `handler-schedule-composition-v1/bundle-v2`
consumer needs exhaustive initial-notification cases and snapshot observers.
For cleanup, use the terminal `native-readiness-v1/ACTUAL-NATIVE-v3.md` and
`INDEPENDENT-JS-ACTUAL-v2.md` under the existing stream-opt production-adoption
packet: actual foreign invocation rejects in System before reader activation,
foreign disposal rejects before port removal, and accepted disposal removes
reader positions. Its failed-batch case is a failed reader, not a failed publisher;
neither selected cleanup scenario executes skip. Compare the selected nested
`current-core/ecs` sources, not the unused staging copies. These are bounded
reached-body reuse candidates, not a claim of identical full source closures.
