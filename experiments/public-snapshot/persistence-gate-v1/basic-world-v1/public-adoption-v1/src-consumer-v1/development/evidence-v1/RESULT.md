# Actual public src application development

At source commit `fc37a04d`, the complete snapshot and Family consumers use one coherent 44-file closure from the integration checkout, including the promoted public `src/ecs` modules. Independent read-only review admitted the unchanged complete oracles before backend execution.

Actual JS and Native complete reports match type-sensitively and are byte-identical:

| Route | Whole oracle | Bytes | Raw SHA256 |
| --- | --- | ---: | --- |
| Snapshot + ordinary admission | a73fafb4… | 9605 | c381bdeab1e75d6ecbe893baabc2e901ee162499c2e59d838f7cdaa0a9a201dc |
| Full two-schema Family | 724b69f4… | 8482 | 4bd6d9336e5216708725059bffd10d87313e517a71a1ae49cbbeaed38b284e1f |
| Reached Family codec-reset mutant | fd8f5204… | 8472 | 4fcf8855636da6f90803b2203340f125db92564488d5526340dd6e32e73a7bc7 |

The source-current mutant is a private copy of the actual Family closure. The sole semantic delta resets the retained codec in `declared-family.put_column` to Array<Integer>, preserving the actual column/rest/identity/project. All 44 private source-copy members were compared against the frozen normal stage. Its source5 check passes; both actual backends match the pre-runtime full counterfactual. Only Workshop/Garden trace.afterA.owner.store.codec differ from normal; every other field remains equal. Real src files were not changed.

The existing direct recipe uses central task_runner, JS emit30/run5 and Native emit30/approved private Clang19 build120/run5, CPU5, threads1/GPUoff, telemetry off and heavy lock only around each actual child. Source/stage/oracle/tool-byte/environment guards and raw are retained; all child exits are zero and stderr empty. Native source pins match the corresponding JS plan before execution.

The reused compact archive contains 349 regular members: consumed source stages, exact receipts/plans/raw, helper inputs, oracle bytes and private mutation provenance. Generated JS/C/native outputs are excluded; their hashes remain in receipts. `verify.py` performs no backend execution and checks exact archive membership/hashes, full type-sensitive oracles, JS/Native byte equality and sole source-copy mutation.

Scope is application development semantic evidence. The final root source5 snapshot deadline remains honestly INCOMPLETE; runtime success does not rebind that receipt. Complete resolver/tool delivery qualification, performance gates, master delivery, mathematical proof and full #58 closure are not claimed. Performance checks remain a separate root gate under CPU contention.
