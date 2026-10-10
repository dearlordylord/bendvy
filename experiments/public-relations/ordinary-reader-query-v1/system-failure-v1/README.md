# Registered transaction failure with retained relation reader

The actual registered writer stages a valid declared Parent relation request, then finishes its transaction with `X.Failure{Unit{}}` and forwards `Sy.Failed`. The consumer retains the returned registry and records `FailedWrite`, rather than converting failure to fixture refusal or successful write. Public `Sy.run_tracked` preserves the failed instance cursor.

Ten complete checkpoints first publish a self-relation failure and consume it through the actual registered reader; then publish another backlog. The failing writer runs with that preexisting reader position and backlog. An explicit barrier and two actual reader runs reveal any leaked transaction-local relation command, reader consumption, publication or retention changes. Both physical affine store/resource arrays, all instance registries, queue size, graph/inverse order, complete Notice batches/domains/positions and runtime/world clocks remain observed. This tests command discard, not local event discard or arbitrary transaction rollback laws.

Workshop source04 passes stock source5. The three earlier concrete constructor/parser/serializer typing refusals are preserved losslessly. Independent whole oracle and backend execution remain pending; no full #42 or performance claim.
