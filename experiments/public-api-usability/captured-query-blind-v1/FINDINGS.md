# Blind captured-query ordinary App audit

The independent greenhouse consumer runs on stock JS and Native and matches every byte of its independently authored oracle. The source uses the public `Comp.add`, `Capture.add`, `Entry.attach`, and `Entry.run` entry points. It authors no schedule, plan, dispatcher, invocation runner, registration IDs, or query cursor updates.

## Independence and source boundary

The audit starts at core commit `3c40177bd` on `audit73/captured-blind`. The auditor reads public `src`, ordinary App documentation, the scheduled-health example, and the documented `audits/blind-user-73` ordinary component/service example. The auditor does not read `captured-query-v1`, its consumers or oracles, the old #24 consumer, or optimization and profiling packets. The author supplies no test logic or expected values. The coordinator supplies the reviewed generic runner path and execution lease.

The manifest pins Rust Bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60` and Bend source `a950fd683c0d76f09794078e6174fe98a1492876`. Both read-only reference checkouts match. Bevy's retained `FunctionSystem` function/state and `unregister_system` owner return inform the ownership model. Approved Bend failure, rollback, and success-only query cursor rules in `docs/SPEC.md` and `docs/parity/captures.md` govern the tested behavior. Installed Bend is pinned to 2.0.35 in both execution plans.

## Simulation and independent observations

Two plants start at heights 10 and 20. The component system waters each plant by one. A captured Changed query adds ten and remembers every entered row, including a row that returns typed `Frost{2}` failure. Its memory owns a mutable Array and a function that captures another owned Array. The function remains untouched through all runs and executes once at final observation, returning 77.

`expected.py` derives the complete output before any backend execution. Each line contains `status,cursor,entered,total|heights|component outputs|captured outputs`, with trailing commas on numeric lists. Status 2 requires the actual nested typed `Frost{2}` error. Status 1 requires a completed schedule.

| Run | Observation |
| --- | --- |
| Failure | Watering commits heights 11,21. Both growth writes roll back. Captured state retains two entered rows and sum 32. Query cursor remains 0. Captured outputs are empty. |
| Retry | The returned App waters again, then growth commits heights 22,32. Capture reaches four entries and sum 66. Cursor advances to 10. Both systems retain their actual outputs. |
| No new writes | Watering is disabled through returned owners. The Changed query enters no rows. Heights, capture, and cursor remain unchanged. Captured outputs become empty. |
| Resumed writes | Watering resumes and growth commits heights 33,43. Capture reaches six entries and sum 122. Cursor advances to 14. |

The observer consumes and reconstructs the actual returned affine owner while reading its cursor, Array sum, entered count, and row outputs. It supplies no cursor value to execution. Reserve results supply real handles for component insertion.

## Execution evidence

Both `js-attempt02/receipt.json` and `native-attempt02/receipt.json` report `COMPLETE_CONSUMER_DEVELOPMENT_PASS`. Their consumer stdout equals all 126 oracle bytes. SHA-256 is `960ede2ea30a75b3c5dc4bac24715263cfda688b3379c45c9450d72f9157d33e`. Runtime stderr is empty. The packet retains plans, guards, raw streams, generated JS/C, and the Native executable.

The unchanged reviewed runner is `experiments/public-inspect/ordinary-declaration-v1/canonical-full-consumer-v1/development-v2.py`. `prepare.py` prepares this specific consumer's plans and invokes no children. Its plans bind the full import closure, oracle/model, helper sources, installed tools, resources, and explicit environment. Execution uses Node 24.20.0 and Clang 19 on leased CPU9/11, sequentially. Limits remain emission 60 s, build 120 s, consumer 180 s.

The initial source check uses the current canonical `scripts/bend-check` wrapper with its 15 s limit. `check.log` contains only the expected unsafe/foreign trust report for `world-namespace.fresh`, `world-io.create`, and `main`. This is not an all-proofs-pass claim. Both stock backend emissions subsequently accept the exact source.

Attempt01 preserves preparation history. The JS launcher failed before child execution or receipt creation because its pins omitted canonical helper paths required by the runner's module loader. Native attempt01 was never launched. Attempt02 adds those canonical helper pins, without changing consumer source or oracle. No failed backend result is treated as a pass.

## Usability findings and limits

The ordinary entry successfully composes a regular component system with a genuine affine captured query. The caller writes domain bodies and declarations, and the library derives execution routing. Reusing the returned App for retry works directly.

The erased-index aliases remain verbose: this consumer needs fourteen generated index aliases plus error and application aliases for two registrations. They call library functions and contain no hand routing. The existing ordinary App guide at the audited commit omits `ordinary-app-capture-query.add`, so source reading is needed to discover its signature and generated aliases. Retrieving capture state currently requires a deep public owner constructor pattern. `outputs` exists, but there is no equivalent concise capture projection helper used here. These are concrete documentation and ergonomics costs, not runtime blockers in this scenario.

This is one finite public consumer, not universal refinement, full #73 acceptance, a new law, a mutation campaign, or a performance result. It does not test foreign-world rejection, duplicate registration, schema separation, disposal/unregister, commands/events, host IO rollback, or component payloads containing affine Arrays. Its affine Type coverage is the captured memory and the opaque closure. The existing runner supplies guarded development receipts; this packet adds no new portable verifier or installed-resolver qualification.
