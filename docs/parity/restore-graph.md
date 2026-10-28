## Current #77 graph and machine execution boundary

The historical #60 Runtime delivery below retains its original scope. Ordinary
`examples/parallel-persistence/extended-*` consumers use the replacement executor
and the explicit receiver-retention contract described in
[execution save boundary](../design/execution-save-boundary.md).

An extended save contains declared component/resource values, ordered relation
sources, committed machine values and revisions, and detached lifetime-scope
membership. Saved full entity keys are remapping tokens. Restore allocates fresh
receiver handles and rebuilds relation inverses, hierarchy observations and scope
membership through the existing graph algorithms. It retains the receiver's
namespace and actual owner inventory. Invalid graph or scope preparation refuses
before live cleanup or payload construction; the returned actual application can
be retried with valid input.

The ordinary application is defined on the receiver before restoration. Its
registered systems, Local arrays, captures, state-condition compilation, handler,
Reader identities/positions, dependency bindings and deferred configuration remain
receiver-local. They are not deserialized from the snapshot. Pending structural
work refuses before projection and is never implicitly flushed. Consumed affine
command owners are not part of the saved data and cannot be restored.

The modern relation store retains receiver failure-channel history, sequence and
Reader registration. The machine store replaces the committed value, revision and
stamp while retaining receiver stream history, namespace, sequence and next-stamp
state. It clears the source pending transition intent. This differs from the
historical #60 Runtime stream-clearing contract below. Restore returns actual cleanup
and publication receipts, remapping and previous receiver graph/scope values;
partial publication is an explicit retained result rather than whole-restore
rollback.

The ordinary resume entry runs the same returned application twice. Its first
update handles a real body error and transitions the restored Waiting machine to
Running. Its second update tests the changed state and skips the condition-bound
transition system. Existing single-update restore and retry APIs retain their
contracts. Ordering follows declared dependencies, while compatible native tasks
use the existing parallel executor.

Example-local observers traverse actual owners, cached views, queues, allocator,
lifecycle, captures and returned receipts. Invalid-input retry retains a complete
observation of the actual refused application before continuing with that same
application. A saved projection alone is not treated as full receiver state.
The existing terminal relation-failure read remains an actual operation, with its
returned Reader, messages and World observed explicitly. Function closures and
proof witnesses remain opaque. These finite observations do not establish a
universal ownership theorem or full runtime recovery.


## Historical #60 Runtime delivery

## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

A complete public save restores ordered relation graphs and committed machine values with the exact runtime omissions and stream-clearing boundary.

## Acceptance criteria

- [x] Observe pinned relation group ordering, missing endpoints, duplicate source, self policy, hierarchy cycle, unknown machine and illegal-state validation before any live mutation.
- [x] Save/restore all supported fields with explicit codecs and full observations. Clear pending machines, transition events and relation failures as observed; keep services, registered slots/captures/Local outside the save contract.
- [x] Validate partial resource/machine entries and retained omitted values without assuming a full reset; preserve allocator/identity and lifecycle reader contracts from basic restore.
- [x] Detect reached graph-order/cycle/queue-clear mutations and run basic save consumers unchanged. Distinguish successful validation from universal recovery proof.

## Current implementation

The ordinary frontend composes the existing constructed basic schema with declared relations and explicit machine codecs. `restore-graph-save.save` writes the six-field detached snapshot; `restore-graph-raw.parse` and `restore-graph-raw-owner.run` preserve the original Raw on refusal. `restore-graph-runtime.run` operates on the existing mixed Runtime and a catalog derived from actual event-family declarations. Callers do not supply a cleanup callback or duplicate gameplay metadata.

Validation, constructor staging, graph/machine checks and capacity admission precede live cleanup. Successful restore uses canonical entity cleanup and fresh generational handles, returns the saved-key mapping and owned drain receipts, clears pending/transition/failure batches, and preserves omitted committed values and registered owners. Saved full keys are opaque remapping tokens; no runtime-index bound or new Raw duplicate-property policy is imposed on them.

The [ordinary Runtime consumer](../../experiments/public-restore/graph-runtime-v1/README.md) links the complete two-schema observations, genuine room refusal, reached mutants, authority checks, unchanged basic-save reuse and executed TS shared projection. These finite roles passed independently modeled whole-output comparisons. Source-current integration review, unchanged #28 regression and CI remain required before issue delivery.

## Blocked by

- #59
- #44
- #49

## Delivery and evidence

- Apply the [SPEC reference order](../SPEC.md#implementation-decisions): Rust Bevy architecture and ECS semantics first; Bend types, affine ownership and runtime constraints second; bevy-ts feature inventory and porting inspiration third. Record exact reference commits. Execute bevy-ts comparisons for shared agreed scenarios, not as a blanket behavior authority; preserve approved contracts and record reference differences explicitly.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native correctness observations without dropping work; keep boundary and capacity correctness checks. Comparative timing/scaling is qualified on the combined feature workload under #21/#23/#24 and is not a prerequisite for individual semantic delivery. Consequential hot-path changes and detected regressions still require targeted performance investigation. Final JS <= TS and Native <= 0.5 * TS goals remain unchanged. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.


## Pending structural work — #76

Ordinary basic and graph save now return `World & snapshot-data.Outcome<Snapshot>`:
`Saved{snapshot}` or `RefusedPending{}`. A nonempty `World.pending` refuses before
any entity/resource/basic/graph/machine projection. The returned World and queued
affine command owners remain intact; saving never flushes commands. Apply an explicit
barrier, then retry. There is no compatibility API with the old save result.

Machine snapshots still contain committed values, not pending transitions; event
logs/readers likewise are not runtime checkpoints. This guard concerns structural
commands, not hidden queues in arbitrary resource payloads. The focused
[test fixture](../../test-fixtures/public-save-pending/main.bend) covers refusal,
noninvocation of projections, retained command owners/FIFO, barrier/retry, zero-live
resource save and complete graph/current-machine export. Both matched-stock35 JS
and Native consumers pass the full496-byte oracle; independent final review GO.
