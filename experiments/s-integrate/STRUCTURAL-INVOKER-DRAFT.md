# E6–E9 structural helper draft

Actual bounded trace helpers, not new general ECS laws/proof approval.
Cleanup supplies fresh nominal operations over opaque Tx selected by actual p;
write slot zero51, stage RemoveMain(actual a), Despawn(actual b), Ping3; success
commits marks at supplied tick and publishes chronological commands only.
Trusted Cleanup handle inputs must be actual same-world bindings from the trace.
No raw world/journal/undo operation is supplied to the callback.

Inserts accepts five actual retained Main Type payloads and actual returned
handles; public `commands.insert_main` order p71,a80,c30,a81,b90. Dispose uses
public remove_main(c), despawn(a),despawn(p),despawn(r),despawn(c). Rejections retain
actual returned payload owners in Batch.rejected rather than fabricating success.
No helper flushes: the caller owns explicit application and reader clock/logs.

Controls: actual factory/reserve/spawn/apply setup; two schemas, all four payload
cells/metadata; complete pending and live worlds before/after explicit barriers.
Compiling FIFO/cleanup target/disposal mutants must differ at public checkpoints.
Native/JS complete output comparison; checker/runtime five seconds; existing
separate build limits. No new dependencies, production layout or root policy.
SpawnS already has its closed actual callback in the dispatcher-owned module and
is not duplicated here.
