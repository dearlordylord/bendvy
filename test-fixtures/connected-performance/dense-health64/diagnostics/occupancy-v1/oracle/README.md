# DenseHealth64 independent occupancy oracle

Run `python3 model.py --output FRESH` from this directory or provide its repository-relative path. The output directory must not exist. The model reuses current independent Dense state/operation/complete-stream recipes and first reproduces all retained normal Health64 bytes. Report-only subclasses record completed column writes and component/resource append events without changing those original operations. The additive normal stream must remain byte-identical.

The expected sidecar is one JSON array containing warmup and sample records in their authored order. Each retains chronological seed/loop transaction append records, actual prefinish simultaneous column vectors, and final per-column completed-hook histories. Structural shapes count referenced array leaves/nodes and scalar metadata occupancy, excluding payload values, separately retained prepared owners/history storage, bytes and unique allocated cells. Timestamp magnitude is never an occupancy count.

`counter.stats.json` changes only `populatedTotal` in every reached prefinish vector. The full original normal method output remains an independent control. This finite slice is not a broad workload matrix, per-allocation peak measurement or performance qualification.
