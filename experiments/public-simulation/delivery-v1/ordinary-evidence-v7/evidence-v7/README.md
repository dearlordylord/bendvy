# Ordinary simulation delivery v7 evidence

This packet retains the current-root ordinary simulation delivery and its bounded reached hit/death controls. Run `python3 verify.py` from this directory for the no-child archive, receipt, source, output, and oracle checks. The verifier consumes the immutable sibling `ordinary-evidence-v6` packet as the prior normal-delivery basis; v6 contents are referenced and verified, not copied here.

The v7 ordinary run records all seven planned commands, 24 guards, 140 environment probes, and the complete 107-file stage (106 source files plus its stage manifest). The TypeScript reference, generated JavaScript, and generated Native program completed their full consumers. JavaScript and Native each produced the same 44,552-byte report, matching the retained independent oracle and v6 normal output. The source audit records 51 entry-reachable sources and four changed, unreachable source transitions. The result is `RELOCATED_SIMULATION_SEMANTIC_DELIVERY_PASS_NOT_TIMING_OR_FULL_PARITY`; `closedResolverQualified` remains false.

The reached-control history is preserved by attempt:

- The original hit/death attempt remains `INCOMPLETE`. Its hit consumer ran, but the collector's first validator rejected the root constructor before the retained-output check could complete. The old validator bytes are archived separately and hash-bound; the original receipt is not upgraded.
- A post-hoc check applies the source-current validator to the retained hit output. It matches the independently derived hit-omission counter and rejects the ordinary output for the expected mutation mismatch. The same check retains positive ordinary JS/Native cases and rejects malformed root, missing-phase, wrong-stream, and corrupted-counter controls. This is retained-output validation, not a new collector pass.
- The first death-only attempt remains `INCOMPLETE`: its emitter targeted the previous output root, so the consumer did not run. The generated artifact and wrong-target receipt are retained.
- The corrected death-only successor completed its source check, emit, and full JS consumer. The complete report matches the independently derived death-omission counter while preserving the hit stream. Its inherited collector status token is not a timing result.

The control models start from the independent normal full report and remove only the selected event constructor. They retain both schemas and all fourteen phases, and the validator checks the exact one-expression source mutation, event counts, preserved opposite event stream, and full report equality. Raw stdout/stderr, generated artifacts, plans, receipts, guards, probes, counter-oracles, and source history are content-addressed in `MANIFEST.json`.

This packet establishes finite current-source semantic delivery and the named hit/death controls. It does not establish full parity, resolver closure, timing or performance, universal mutation coverage, or complete issue acceptance. Compiler, runtime, operating-system, and linked-library files are represented by their recorded pins and are not bundled as binaries.
