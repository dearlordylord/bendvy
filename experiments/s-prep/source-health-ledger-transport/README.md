# Private Health ledger array transport (bounded source probe)

This source-only variant carries the existing owning `Array<U32>`, epoch and immutable cached ledger view through the private Health row/fold owner. It reconstructs nominal `HealthLedger` and its cache at the boundary or generic fallback. Original callback algorithms, public definition/type headers, generic affine payload support, journals, namespace/liveness guards and row order are preserved. Motion is unchanged.

Input: joined fold/noAux closure `49614f72311af5b03123d536ff301115d28b8886bf516b0d7057a8c52e68ad38`. Output: `867a3ee9d38d53970f384c944d660ae840ae50edbc5cd3128fb006e23b83984a`, all 29 modules pinned; only `held-adapter.bend` changes. `materialize.py` applies the exact patch with zero fuzz and rejects other source closures, module/header changes and mismatched cache receipts. A fresh reproduction has identical29 source pins.

```sh
python3 materialize.py --input /workspace/formal-proofs/bendvy/experiments/s-prep/source-fold-noaux-join/overlay-v1 --output /tmp/fresh-ledger-overlay
python3 build.py --overlay /tmp/fresh-ledger-overlay --schema Health --output /tmp/fresh-ledger-build
```

Fresh Motion/Health full 65 observations pass on Native and JS against actual independent TS. Health nine-world ordinary constructions decrease from 7,206,464 to 6,946,880 (−259,584); instrumented phase-marker extra 1 is excluded. This counts emitted constructors, not physical allocations or accepted speed.

Finite controls execute actual new private providers: Tx/suppression 576 records/backend; Main lost-mark and inverse-order mutations; four positive/twelve authority negatives; arbitrary affine Raw/owned-array generic canary and clone rejection; all four retained raw/cached snapshots. Raw retained fixtures are sliced only at the exact authored main call boundary, then concatenated and checked against the unchanged full expected records and cached observations.

The ledger-specific literal witness observes every cell at lengths 1/2/4/8, raw epoch 4, cached epoch 77 and retained cached first 999 versus true raw old 100, prior inverse 55, Main metadata and marks. Actual wrong-old, omitted-array-write and omitted-epoch mutants compile and produce the exact expected counterexamples on both backends. Fixture parser/binder failures are retained separately; they do not indicate runtime detection.

Exact final statuses are listed in `status.json`; source-bound successful and failed receipts are archived with SHA256 manifest. Returned Main and Ledger-array discard mutants execute and are detected; actual factory/foreign-world controls pass independently. No universal refinement, proof, production API, full 22 gate, canonical cohort or performance acceptance is claimed. A genuine flat-journal composition must change its reached Health family and rerun source-specific gates; mechanically merging this patch would leave the new provider unexecuted.

Executable checker diagnostic 15 seconds is explicitly opted in; proof/default 5 remains unchanged. Emission 30, Clang 120 and runtime 5 seconds are retained. CPU 10, existing Bend/Node and approved Clang19 child wrapper are used. No compiler, reference, kernel, dependency or external repository changes.
