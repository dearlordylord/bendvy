This audit describes the pre-fix discovery; the candidate and retained runtime successors resolve its pending-spawn mismatch. Remaining identity policies are unchanged.

# Pending spawn/despawn: pinned Bevy-first contract audit

Read-only source audit. Pinned Rust Bevy HEAD is exactly ad678262ce53b5d142fe49ee5e08caff6f00ab60, verified locally; source anchors below are under /workspace/formal-proofs/bendvy/.references/bevy. Bend anchors are current /workspace/formal-proofs/bendvy/src/ecs. No backend/reference/checker execution, core change, reuse/capacity policy or new contract was performed. TS pending-discovery is supporting already executed evidence, not the governing authority.

## Finding

The same command sequence `commands.spawn(bundle).despawn()` is supported by pinned Bevy's ordinary deferred API. Spawn allocates an ID immediately and queues a spawn operation; despawn queues a later operation for that actual Entity without requiring it to be spawned at enqueue time. FIFO application spawns it first, then despawns it. Consequently it is absent after application. This is ordered deferred execution, not a promise that spawn work/hooks never happen or that a pending spawn callback may be erased without other observations changing.

Current canonical Bend Cmd.tx_spawn returns an actual reserved handle but marks it not-live until its queued spawn applies. Cmd.tx_despawn_with consults W.valid immediately, so the same transaction's actual pending handle is refused MissingEntity. Its accepted spawn later materializes at the barrier. That contradicts the supported Bevy ordinary spawn→despawn sequence independently of the TS reference. Fixing actual own-pending cancellation is an existing delivery gap; it does not decide index reuse, generations, maximum capacity or failure-finalization policy.

## Exact Rust source chain

- crates/bevy_ecs/src/entity/mod.rs:64–76 distinguishes allocation/validity from actual spawning, and later despawn/free. An allocated ID is not proof of a spawned entity. EntityAllocator::free at :794–802 is a separate explicit allocator operation; allocation alone does not confer live membership.
- crates/bevy_ecs/src/system/commands/mod.rs:231–239 (`spawn_empty`) and :283–293 (`spawn`) call allocator.alloc immediately, queue World.spawn_*_at_with_caller for that ID, and return self.entity(entity). EntityCommands construction at :324–329 only retains ID and command-buffer reborrow; it is not World.get_entity_mut.
- Same file :1899–1901 (`EntityCommands::despawn`) queues entity_command::despawn with warning handling. :1956–1961 documents that EntityCommand entity existence is checked at execution time. There is no immediate spawned-entity test in this enqueue path.
- crates/bevy_ecs/src/system/commands/entity_command.rs:98–105 wraps the entity command in a World closure: `world.get_entity_mut(entity)?` runs when the command is applied. :278–282 then invokes EntityWorldMut.despawn_with_caller.
- crates/bevy_ecs/src/world/command_queue.rs:181–189 applies the queue; CommandQueueRunner::run at :294–338 consumes entries in buffer order through its increasing local_cursor. Commands.spawn's closure precedes the returned EntityCommands.despawn closure, so the latter sees the entity actually created by the former. World::flush at world/mod.rs:3210–3218 applies queued components/commands; no reader-visible query entity is promised before deferred application.
- crates/bevy_ecs/src/world/mod.rs:1590–1613 documents/implements try_despawn failure when an entity is not spawned; this is distinct from accepting a future queued operation. CommandQueue::drop at world/command_queue.rs:214–230 drops unapplied commands, rather than materializing entities. These paths do not give a successful despawn result for an allocated-but-never-spawned ID.

Thus the governing contract is deferred ordering and eventual absence for an actual accepted spawn followed by despawn in the same applied command stream. Rust's warning/silent entity command handlers are not evidence for changing Bend's explicit W.Status for stale/foreign/abandoned IDs.

## Exact Bend mismatch and failure boundary

- commands.bend:28–40: Cmd.tx_spawn calls W.reserve_id and prepends an actual spawn_apply closure to the local transaction command accumulator. The returned Handle is actual reservation authority, not a fresh guessed numeric ID. spawn_apply at :25–26 activates it and then populates the payload.
- world.bend:50–62: reserve_finish advances nextId/highWater, retaining the false live bit until activation. metadata_valid at :64–66 accepts same namespace and numeric range; valid at :87–98 additionally reads the live bit.
- commands.bend:49–61 (plain), :74–86 (with schema clear), and corresponding observed variant at :106–118 gate deferred despawn on W.valid NOW. The returned own pending handle therefore fails before its earlier accepted spawn applies.
- transaction.bend:41–51: Success reverses local commands to FIFO before enqueue/publish; Failure rolls back undo and does NOT enqueue that transaction's command accumulator. world.bend:100–110 maintains reverse World.pending and drains oldest-first at the explicit barrier.
- A failed/abandoned spawn can leave nextId/highWater advanced without a retained accepted spawn command. Cmd explicitly preserves consumed IDs on failure (commands.bend:37). The same old numeric handle can satisfy metadata_valid while never becoming live. Replacing W.valid by metadata_valid would incorrectly accept those holes, as well as previously despawned allocated IDs. Bevy does not justify that weakening.

Bevy has no analogue of Bend's whole recoverable T.Failure/inverse-owner protocol here. Preserve the existing Bend failed/abandoned reservation rejection and owner-return scope; do not infer new rollback/free/reuse semantics from Rust or the TS silent try-despawn path. If an earlier transaction has already committed a spawn to World.pending, a later failing transaction must not erase that accepted pending spawn by mutating global state irreversibly. Identity/authority validation must remain independent from liveness.

## Smallest required behavior / qualification

1. Admit a despawn request for the exact same-world actual accepted pending spawn produced by the current ordered transaction/retained command stream, even while live=False; preserve ordinary live despawn behavior. Namespace mismatch and absent/stale/failed-abandoned reservations remain explicit refusals under the current Bend contract. Numeric allocated-range membership alone is insufficient.
2. On successful transaction and explicit barrier, apply the existing spawn followed by schema-owned despawn/clear (or an observationally equivalent representation retaining all existing promised callbacks/removal/owner effects). The entity is absent afterward, query rows empty and lookups MissingEntity; all component families must be cleared by the existing authored clearer. Before barrier it remains not-live and the accepted deferred work remains observed.
3. Preserve transaction failure semantics, FIFO ordering, existing committed pending work, raw undo/event/payload owners and all unaffected World fields. Do not merely delete a spawn callback to make the final live bit false: pinned Bevy executes ordered spawn then despawn, and deleting work could suppress authored installation/removal observations. Any optimization requires that exact source/effect argument separately.
4. Reuse the existing actual pending-discovery mismatch as motivation. The smallest new ordinary consumer exercises actual tx_spawn→tx_despawn_with in one transaction, complete pre/post barrier World/column/stamp/pending/receipts, plus concrete abandoned-ID and foreign refusals that the representation could otherwise accidentally admit. This is a decision-free fix to the accepted sequence, not a new reuse/generation/capacity or destructor contract. No new runner or broad numerical matrix follows.

Representation research belongs to the other assigned agent. This report does not select a global pending table, new authority token, generic closure metadata format or broader all-API pending access policy. Root is the sole core integrator.
