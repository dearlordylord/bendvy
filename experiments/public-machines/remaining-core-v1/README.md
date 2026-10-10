# #48 comparator-aware queue candidate

This private additive candidate implements pinned Bevy `NextState::set_if_different` preservation of an already forced pending value. The governing basis is SPEC's Bevy-first order, not the historical TS overwrite trace. `queue.bend` adds the existing trusted erased value comparator to queue/write/next/next_declared without changing Family indexes, shared source, initialization, duplicate provisioning, transition publication or changed flags.

The actual consumer registers and runs `Sys.run_tracked`, calls `Q.next_declared` inside the existing transaction, and retains an arbitrary affine World with nested component/resource Arrays and a pending callback. Comparator-equal Play20 and Play21 have different representations: a conditional request retains the actual prior Play20 and its forced flag. Different targets overwrite conditionally; forced requests overwrite; reset removes pending work; failed transactions restore the entire old slot. Missing-slot fixtures remain missing. Current Boot10, previous Pause90, changed=True, complete owners, events, clock and registrations remain visible throughout.

The minimal four checkpoints were independently source-reviewed before JS/Native execution. The separate twelve-checkpoint expansion covers two nominal schemas. Its reached former-queue control changes only the comparator-equal forced-pending branch; its complete oracle differs at precisely that checkpoint. Every expected output is a pure source-derived model of the complete quoted String, including Base Bool/List/Nat formatting. No runtime output was used to create or repair an oracle.

## Concrete remaining gates

| Gate | Exact source/evidence | Next action |
| --- | --- | --- |
| Conditional request must preserve prior forced payload | Pinned Bevy resources.rs:210–217; private queue.bend; normal and reached old-conditional cohorts | Promote only the import-rewired additive module after independent final review; PROMOTION.json records exact inverse/body joins. |
| Existing comparator-free route and ordinary capability frontend | Current machine.bend Family has closed take/put but no comparator; machine.next/write remain comparator-free. This candidate calls the trusted declared-Family seam directly. | Route the actual ordinary capability frontend through comparator-aware operations and qualify undeclared/read-only authority there. Family phantom typing is not an unforgeability or general access proof. |
| Nominal schema and affine ownership of this seam | Current negative-cross-schema and negative-owner-duplicate source captures | Preserve intended Family index mismatch and actual World consumption failures; do not relabel these as undeclared/read-only controls. |
| Typed empty-slot provision, missing requirements and optional conditions | Existing integrated provisioning-v1/delivery-v1 complete main/mutant/Flow-only qualification | Reuse exact applicable source/body/model joins; this packet does not rerun or replace that delivery. |
| Public initial messages/changed flags and occupied provision selection | provisioning-v1 explicitly names selected_initial and its empty-slot primitive; BEVY-BASIS.md identifies actual Bevy differences | Resolve the precise existing observable contract against SPEC and approved decisions before adapting these paths. Historical TS behavior alone is not an approved Bend divergence. No choice is made here. |
| Marker-created later-key pending behavior | Existing public-machines/contract.md governing conflict and current marker snapshot/apply route | Reconcile the recorded hold with the issue requirement and Bevy-first SPEC using an actual public marker consumer. This queue-only candidate does not decide it. |
| Full #48 acceptance | docs/parity/machines.md requires complete markers/conditions/readers, equivalent reference execution, current authority and default paired regression plus measurements | Complete applicable existing gates after core/frontend integration; comparative measurements remain deferred during CPU contention. |

`BEVY-BASIS.md` is primary-source research, not a contract approval. New laws/proofs, compiler/caps/dependencies and numerical policies are outside this delivery. Rendering is fixture teardown; no general finalizer or retained-callback identity claim follows.

## Evidence

The unchanged detached-v2 source/runtime collectors execute with stock source cap5, emit30/build120/run5, CPU5, Native one thread and GPU off, using the shared internal child lock. Source attempt history includes the initial private parser/type/observer repairs; all captures retain full source snapshots, closure, pins, pre/post state and raw diagnostics. Runtime evidence retains exact plans, receipts, guards and raw output. Independent minimal/expanded model receipts precede backend execution. Source attempts A-source01–08 are recorded failures, not qualifications; A-source09 is the frozen positive basis. A mistaken preparation-adapter `--help` invocation raised IndexError before any child/capture; it changed no source evidence.

Final results and archive membership are recorded in EVIDENCE.json. This is a bounded additive queue implementation qualification, not full #48 completion or approval of an unresolved observable policy.
