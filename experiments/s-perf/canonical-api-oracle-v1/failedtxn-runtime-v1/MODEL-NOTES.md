# FailedTxn Motion64 streamed-source oracle

This additive successor rebinds the complete finite Motion64 oracle to the frozen streamed-record source. It is a scenario oracle, not a proof, universal law, approval, or subject implementation. The prior corrected source and oracle remain recorded in `SOURCE-FREEZE-v1.json`, `SOURCE-BASIS-v1.json`, and `motion64/SOURCE-BASIS-v1.json`.

## Source closure and provenance

The current source is frozen in `SOURCE-FREEZE.json` (source body commit `7fcdf08234cba057112ec520758e0e0e630a3a9f`, freeze commit `8a8bf7d26507dba306cf14cf1eddb445188a3ccc`, manifest SHA-256 `39589b499e93bc51edf68230dbe8ea76f8c6c37c8627b69b3b3a1105fab69b59`). It pins 115 Bend files and two namespace sidecars. Relative to the previous freeze, the workload changes are the new `motion-stream.bend` plus the `motion-scenario.bend` and `motion-driver.bend` streaming updates; the ECS, transaction, reader, capture, and scenario operations are unchanged. The source diff and full transitive closure are pinned in the manifest.

Rust Bevy remains the primary semantic reference, Bend runtime and ownership constraints second, and the TypeScript adapter a third-priority workload inventory. The frozen Bend transaction and ordinary-reader paths determine rollback, reader completion, cursors, and mutation order. The streamed driver determines output ordering and the actual World creation boundary.

The model was rendered without compiling, executing, or reading a current streamed-source backend. The earlier corrected source's existing JS output had already been read after the earlier render for byte-equality validation; that evidence is retained only in `SOURCE-BASIS-v1.json`. The current streamed rebind was compared against the predecessor's independently generated expected stream, not against subject output. It has not yet been validated against a streamed-source backend run.

## World and IO ordering

`motion-driver.run` calls `make` and waits for `WI.create` to return a `Created` World before it writes the `warmup={` record. `warmup_created` sequences all `Stream.write` IO before calling `measured`; only then does `measured` call `make` for the second World. The model mirrors two process-global namespace allocations, creates each World before its first output write, completes all warmup writes before creating the measured World, and evolves each single World through seed, barrier, registration, readers, and disposal. The namespace lineage is 1 then 2, and each World starts with fresh ECS state.

`motion-stream.write` sequences `IO.write` for each String element in its list. The oracle reproduces that ordered chunk list and hashes the concatenated bytes. Initial state observations are whole records. The final state emits its opening prefix, registered/dispose/frame owner fragments, each boundary record, each schedule item, and the closing status in source order. `Stream.shown` uses comma-space before every noninitial element and emits the closing bracket as its own String. No boundary, schedule, Audit entry, or final state is reduced to a digest.

## Runtime derivation

For 64 seeds, component writes produce World clock 107 (64 Position, 22 Velocity, 21 Selected writes). The event route starts at tick 0, while failure state starts at tick 107. Each reader attempt synchronizes at `e = max(1, routeTick, failureTick, worldClock)`, sets the ingested route tick to `e`, advances the route to `e + 1`, and advances the World clock once. Preparation reads at that advanced route tick and returns `readThrough = e`; a missing reader position is activated at `registered = e - 1`, with cursor 0. Callback success advances the stream cursor to `e`, the ordinary `Sys.Registry` cursor to the post-callback World clock, and ingests at the current route tick. Callback failure skips commit and `after_success`; preparation activation remains while stream and ordinary registry cursors remain unchanged. The source uses `Sys.run`, not `run_tracked`.

For each iteration, A commits one Position write, one Ledger field update, an Audit service request, a reservation, and event `2*i`. B's failure and retry read the same committed cursor. Each B attempt performs two Position writes, one Ledger update, one Audit request, and one reservation. Failure replays only the private Position/Ledger inverses and consumes its failed reservation without publishing the staged command or event. The Audit update survives because its declared service request changes the separate Audit slot outside the transaction's undo journal. B retry commits event `2*i + 1`; the Publications reader observes A's event after failure and B's after retry.

The allocator model follows actual full handles and release/reuse. Seed handles occupy indices 1–64. Iteration 0 returns A `65:0`, failed B `66:0`, retry B `67:0`; disposal releases A then retry B, prepending each to the free list. Iteration 1 therefore returns A `67:1`, failed B `65:1`, retry B `68:0`. Later generations follow reserve/abandon/activate/release state transitions, not arithmetic on event or iteration numbers. The source's recursive `drain_fifo` applies the tail before the head, so the pending A spawn applies before retry B.

## Serialization boundaries

World snapshots retain namespace, allocator, stores/resources, events, pending count and kinds, registrations, next-system ID, and clock. Callback/boundary handles use their renderer's `Found{...}`, `Absent`, and `Missing` forms; inspector rows keep their separate `Found(...)`, `ComponentAbsent`, and `MissingEntity` forms. Callback write results use braces, and the B reader registration contains its full writer access list as well as `ping:read`.

Boundary owner rendering uses only `Observe.registered`; final owner rendering uses the separate full `Observe.owners` projection, including dispose registration and accumulated frame calls. Audit entries stay in newest-first cons order with length-prefixed strings. The independent serializer writes each final boundary and schedule record in the exact streamed list order and applies the source's comma-space framing.

## Checks

`python3 -m py_compile model.py`, `python3 model.py --self-check`, and two full 64-by-64 renders pass. The streamed model's complete raw and gzip bytes are identical to the prior source-derived oracle; this confirms the source-rebound writer preserves the predecessor wire while following the new ordered IO and one-World lifecycle. Current streamed-source backend equality remains untested. Exact hashes, full source closure, and predecessor lineage are recorded in `SOURCE-BASIS.json`.
