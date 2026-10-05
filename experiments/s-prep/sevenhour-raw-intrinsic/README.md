# Native Raw intrinsic candidate

This isolated semantic candidate derives from the verified Native static-only input `/tmp/bendvy-sevenhour-next-candidate/native-static-only`. Only `experiments/s-integrate/uncached-payload.bend` changes. Its `four` body delegates to existing `original_four`; `scalar0_swap` delegates to `Array.swap(U32,array,0,value)`. Every baseline import, type and definition header remains exact. The existing unused structural helpers remain to preserve headers. JS running source and all callbacks remain unchanged.

Finite contract: retain the nominal affine Raw owners, all array cells, metadata, scalar-zero old value, read-after-write and repeated inverse restoration. Constant-index getter behavior also matches original Base intrinsics for the retained one-, two- and eight-cell fallback fixtures. No ECS law/proof or universal refinement claim is made.

Fresh CPU8 controls (`run.py`) passed Native O3 and JS against the explicit full-output oracle. Both wrong-cell and tail-loss mutants compile and fail that oracle; affine owner duplication is rejected. Fresh actual split-schema transaction controls retain all144 cases, original callback bytes, and independent original Raw field observation: Native and JS both pass cached/raw field comparison, success/failure, rollback, marks and journal checks. `tx-evidence.json` records all eight72-record lanes. These executions do not constitute a benchmark.

Commands from this worktree:

```sh
python3 experiments/s-prep/sevenhour-raw-intrinsic/run.py
python3 experiments/s-prep/sevenhour-raw-intrinsic/materialize.py --baseline /tmp/bendvy-sevenhour-next-candidate/native-static-only --output /tmp/bendvy-sevenhour-raw-intrinsic03
python3 /workspace/formal-proofs/bendvy-worktrees/twohour-indexed-query/experiments/s-prep/fivehour-connected-gates/tx-controls-run.py --overlay /tmp/bendvy-sevenhour-raw-intrinsic01 --output /tmp/bendvy-sevenhour-raw-intrinsic-tx02 --cpu 8 --split-schemas
```

The recorded actual Tx copy was01; rematerialization03 has the identical complete source manifest. `materialization.json` binds every copied file and the shared Tx runner. The derived `overlay.json` source hashes are refreshed; other inherited descriptive recipe metadata remains historical, not adoption authority. The first Tx launch correctly rejected stale source metadata before compilation; the second launch rejected an occupied output directory. Both failures are retained in `measurement-check.json`.

Complete measurement source checker5s and C codegen30s passed. Each runtime/checker uses5s, clang O3 uses120s, on CPU8. `codegen.json` retains fresh emitted snippets: scalar swap directly reads/writes indexzero, with no structural split calls. Native compiler array intrinsics avoid `ANode` pattern splitting. This is a source/codegen observation, not evidence of allocation dominance or speedup. No timing, packet, compiler change, dependency or running-candidate edit occurred. Full workload/matrix and scope adoption gates remain the integrator's responsibility.
