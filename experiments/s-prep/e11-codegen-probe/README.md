# E11 static-lane diagnostic

See [source findings and integration hook](../../../docs/research/e11-codegen-blocker.md). Only Motion/message is compiled; both actual backends match the unchanged strict comparator after ten fresh full TS reference lanes. Remaining E11 subjects/mutants and full22 are untested here.

```sh
python3 run.py --input /tmp/bendvy-live-first-controls-repaired --output /tmp/e11-static-lane-fresh --cpu 10
```

The recipe checks the exact input manifest/all source pins, resolves two pure selected-lane fixture selectors, uses the unchanged reachability slicer and verifies protected retained invoker definitions plus actual D.tick bindings. Runtime sources remain byte-identical. Checker diagnostic 15 seconds, codegen 30 seconds, clang 120 seconds and runtime 5 seconds caps; no proofs or shared runner changes. Original failed receipt and exact new outputs/derived source archives remain in evidence.
