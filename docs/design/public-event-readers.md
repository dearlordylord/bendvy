# Public event readers — #31

Pinned bevy-ts stamps successful event batches at the system's run tick. Every
reader sees batches newer than its previous successful stream run. Failure keeps
that cursor, a condition skip advances it without reading, and a first run sees
retained history. Lag means a dropped batch tick exceeds both the cursor and the
reader's registration tick. At frame start, drop complete batches older than the
previous frame start only after all registered readers passed them; then drop
oldest complete batches until stored entry count is within capacity (65536 in TS).

The additive Bend event runtime owns the actual World and event domain together.
World remains the authoritative retained payload owner. Registered wrapper runs
synchronize successfully appended World events exactly once into stamped batch
metadata; trim replaces the actual World event list, not a cached count. The
existing append-only Events API and historical consumers remain unchanged.
Gameplay transaction publication still uses Transaction.finish. Reader success
commits its position, failure preserves it, and skip does not invoke gameplay.

One runtime covers one E event domain. Removal/despawn streams must use independent
retention ownership because their skip rules differ; a mixed tagged World log
cannot be trimmed as this event domain. This does not establish integrated
mixed-stream parity. Data events allow independent fan-out; affine Type event
fan-out remains full-core work, not an approved final payload restriction.

Reader retention activates on its first actual registered run, matching TS lazy
slots. A skip before that run creates no holder. Failed valid first runs retain
the original cursor; rejected registrations create no holder.

Registration/disposal consumes affine handles. The pinned TS public Runtime has
no per-system disposal method; independent reader removal is therefore an explicit
Bend lifecycle extension, verified separately from TS-equal checkpoints. No new
laws, proofs, dependencies, performance tolerance or production approval follows.
