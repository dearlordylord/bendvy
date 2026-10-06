# E11 static-lane diagnostic

See [source findings and integration hook](../../../docs/research/e11-codegen-blocker.md). Only Motion/message is compiled; both actual backends match the unchanged strict comparator after ten fresh full TS reference lanes. Remaining E11 subjects/mutants and full22 are untested here.

```sh
python3 run.py --input /tmp/bendvy-live-first-controls-repaired --output /tmp/e11-static-lane-fresh --cpu 10
```

The recipe checks the exact input manifest/all source pins, resolves two pure selected-lane fixture selectors, uses the unchanged reachability slicer and verifies protected retained invoker definitions plus actual D.tick bindings. Runtime sources remain byte-identical. Checker diagnostic 15 seconds, codegen 30 seconds, clang 120 seconds and runtime 5 seconds caps; no proofs or shared runner changes. Original failed receipt and exact new outputs/derived source archives remain in evidence.

## Full-lane bounded attempt

`full-run.py` extends the same fail-closed static selection to ten original subjects and the unchanged executor's required semantic mutants. It executes a source-pinned local copy of the shared runner with two narrow hooks: stage each constant original/mutant lane before the existing slicer, and supervise/record every command. Shared files remain unchanged.

```sh
python3 full-run.py --input /tmp/bendvy-live-first-controls-repaired --output /tmp/e11-full-static-fresh --cpu 10
```

[Actual attempt](full-evidence/summary.json): all ten subjects check and emit both backends within their caps, but fresh TS Motion/removed and Motion/despawned time out at five seconds with no partial output. Eight fresh references and sixteen actual strict backend comparisons pass. The four comparisons requiring the missing references, all semantic mutants, type controls and oracle perturbations remain unexecuted; **E11 is not accepted**. No failure was replayed or cap raised.

Compressed full receipts retain source pins, staging hashes, every command/output and both timeout failures. The unchanged shared receipt's legacy `checkerSeconds: 5` is metadata only: actual supervised check commands used the explicit diagnostic 15-second cap, recorded in `staging-evidence.json.gz`. Proof/default limits remain five seconds. Earlier reference executions on the same adapter were faster; no process CPU accounting was collected, so scheduling versus execution is unresolved. These sources are the old baseline closure, not later candidate roles.

The archived executed launcher returned shell zero despite the inner executor returning two; the delivered launcher now propagates that inner result. This exit-only correction was syntax-checked, not rerun. The exact executed recipe is archived for reproducibility. Static mutant staging is implemented but has not been exercised because the mandatory original gate failed.
