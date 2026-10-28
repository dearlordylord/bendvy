# Relations, hierarchy, and lifetime scopes

## Scoped-scene execution contract

Issue #89 applies the [execution-core contract](../SPEC.md) to one ordinary
[retained scene](../../examples/parallel-linked-despawn/generalized-scene.bend).
The scene keeps one provisioned `World` across three updates with `finalApply`
set to `True`, `False`, then `True`. Component values are affine `Session`
owners. The scene uses the existing relation, hierarchy, linked-deletion, and
lifetime-scope algorithms through their command and publication boundaries.

The [application](../../examples/parallel-linked-despawn/generalized-application.bend)
retains seven nodes. Its facts come from each node's actual compilation.

| Node | Operation |
| --- | --- |
| 1, hierarchy author | Queue component values 11, 22, 33, and 44. Relate the child to the parent, reparent it to the replacement, attempt the reverse edge that would create a cycle, and assign the fourth entity to scope `scene`. |
| 2, independent link author | Queue an ordinary link from the parent to the replacement in a separate command queue. |
| 3, link editor | Queue unrelate and relate for that same ordinary-link source after node 2. |
| 4, relation-failure reader | Consume the registered hierarchy-failure stream and read published hierarchy, ordinary-link, and scope views before cleanup. |
| 5, cleanup author | Queue two despawns of the replacement and two cleanups of scope `scene`. |
| 6, lifecycle reader | Read the actual `Removed` and `Despawned` streams through `Empty`, retaining rows, cursors, and missed counts. |
| 7, survivor updater | Move the actual pending `Session{222}` and `Session{333}` values from its local state into its command queue. |

Nodes 1 and 2 enter the retained parallel scheduler as independent authors.
The declared edges are `1 -> 3`, `2 -> 3`, `3 -> 4`, `4 -> 5`, `5 -> 6`, and
`6 -> 7`. The `2 -> 3` edge orders conflicting deferred edits to the ordinary
link. A deferred relation grant does not itself add a physical resource-access
recipe. The scene does not rely on automatic physical resource-conflict
detection to order those edits.

Dependency barriers publish authored commands before the corresponding readers.
The [actors](../../examples/parallel-linked-despawn/generalized-actors.bend)
return handled `BodyError` completions after authoring. Publication retains
their partial effects. The
[readers](../../examples/parallel-linked-despawn/generalized-readers.bend)
also return handled errors after consuming their streams, preserving their
updated local state. Dependencies define this order without requiring a global
worker order.

The cleanup contract removes the child value 11 and the replacement value 33
through linked deletion, and the separate scoped value 44 through scope cleanup.
The parent with initial value 22 survives. On the second update, disabled final
application retains the actual incoming value 333 in the updater's queue until
the third update publishes it. Readers precede the updater, so their dependency
barriers do not publish that update's pending survivor value.

Source and inverse relation views remain read-only projections of the protected
stores. Mutations use the declared source-of-truth commands. The
[initializer](../../examples/parallel-linked-despawn/generalized-initialize.bend)
allocates all four handles from the actual world and registers the failure and
lifecycle readers against that world.

This section describes the consumer and its required observations. JavaScript
and native qualification must bind the complete observation to the current
source and an independently derived expectation. A selected parallel group or
matching output alone does not establish that the parallel ownership path ran.
Finite observations do not establish universal correctness or add an approved
law. The [current workflow](../agent-workflow.md) governs checks, law approvals,
review, and publication.

## Historical relation delivery

The remaining sections preserve the earlier relation ticket and its evidence.
Their acceptance and publication instructions are historical. They do not
qualify the current execution-core consumer or override the current workflow.

### Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

### What to build

Systems create, replace and remove typed directed entity links and query both ends with consistent inverse results.

### Acceptance criteria

- [x] Observe pinned relation definitions, self-link policies, missing-source/target errors, source replacement and inverse iteration order; compare Rust Bevy relationship source-of-truth and protected target collection architecture.
- [x] Execute actual deferred relate/unrelate and query operations, preserving pre-barrier visibility and exact post-barrier inverse consistency. Direct inverse mutation must not bypass the declared relation API.
- [x] Cover source/target deletion and exact ordered structural failure publication. Separate relation mutation failures from SystemFailure; registered failure-reader composition is a dependent slice.
- [x] Test foreign handles and schema/access controls; detect a reached stale-inverse or failed-publication mutant and preserve arbitrary component owners.

### Blocked by

None (can start immediately; explicit unresolved contract gates still apply).

### Delivery and evidence

- Apply the [SPEC reference order](../SPEC.md#implementation-decisions): Rust Bevy architecture and ECS semantics first; Bend types, affine ownership and runtime constraints second; bevy-ts feature inventory and porting inspiration third. Record exact reference commits. Execute bevy-ts comparisons for shared agreed scenarios, not as a blanket behavior authority; preserve approved contracts and record reference differences explicitly.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native correctness observations without dropping work; keep boundary and capacity correctness checks. Comparative timing/scaling is qualified on the combined feature workload under #21/#23/#24 and is not a prerequisite for individual semantic delivery. Consequential hot-path changes and detected regressions still require targeted performance investigation. Final JS <= TS and Native <= 0.5 * TS goals remain unchanged. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.

### Semantic acceptance reconciliation

The earlier delivery recorded a reader-identity repair. Registry 4 was distinct
from Reader 1, with `nextReader=2`. Its independent normal, replacement/unrelate,
and SystemFailure outputs passed on JS and Native with 14,880, 14,303, and 16,488
bytes respectively. A reached clear-omitted mutant matched its full 14,728-byte
counter oracle and rejected the normal result. The former temporary delivery
directory is no longer a current evidence target. These historical results do
not qualify the scoped-scene execution described above.

Independent final Spec/Standards review passed for retained packet `cb196f40b`. Combined with previously qualified definitions/policies, inverse/deferred operations, cleanup, actual foreign IO worlds, two-schema/access/affine controls, full-capacity correctness and executed TS reference, no semantic acceptance gate remains. #43 separately supplies registered-reader composition. The older `ACCEPTANCE-JOINS.json` remains historical; this source repair supplies the current reader/runtime join. Protected #28 reuse retains its qualified scope; comparative timing/scaling and final combined targets remain under #21/#23/#24.
