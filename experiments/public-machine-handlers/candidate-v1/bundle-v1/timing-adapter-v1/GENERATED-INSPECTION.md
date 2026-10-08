# Actual JS dependency inspection

Generated `inspection.mjs` SHA256 `dfc1ef3debcfedec15014d867c822d77bcacba1a3708414277deb48058fb84d2`, from exact plan `0c699e2b50f78993cd3f603d646874d9eaf54ddf9e76e5a08e758fa96c239ad9`.

- 1516–1521: start IO.bind continuation calls completed(Batch.step(batch,operation), started).
- 1644–1648: Batch.step's applications field is the result of actual stepped(apps,operation).
- 1752–1759: stepped evaluates actual Stepper.step for the head and recursively stepped for the tail before returning the JS constructor. No observer/thunk field is installed.
- 1870–1880: Stepper.step dispatches real application queue/marker/read. Marker2070–2080 calls current core Bundle.run; read2081 onward calls Sys.run_tracked. Actual affine owners flow into those calls.
- 1634–1642: completed extracts returned applications and then constructs the end IO.now continuation. 1748–1750 stopped returns those same applications with start/end values.

JS evaluates call arguments and constructor field expressions synchronously. This actual emitted dependency puts the batch operations before creation of the end-clock request. It establishes a finite source/generated-code dependency; the consumer does NOT call any clock operation, and no elapsed sample was collected. Correctness separately executes the actual same-owner stepper over all forty-two canonical common checkpoints and retains complete physical observations.

Native scheduling has only source-causal support so far: corpus_eval5251–5288 and io_step5844–5878 resolve the continuation request before effect dispatch, with seq tied to !BANGS and pool_size1. Fresh generated Native Batch.step → returned owners → completed → endNow still needs inspection. This package grants no Native timing boundary or universal normalization proof.
