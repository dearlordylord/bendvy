# Fused indexed query candidate

Ordinary bounded implementation for #23 from source8919d52; only
`candidate/query.bend` changes. Added helper names `struct_idx_*` and affine
`StructIdxState`. Existing public headers and helpers remain unchanged. Storage,
identity, transactions, laws, proofs, dependencies and references remain unchanged.
No measured performance improvement or production adoption is claimed.

The ordered logical-ID loop carries separate Main/Aux/Metadata arrays and reversed
observations. The original per-ID nonzero/capacity guard precedes index arithmetic.
Dead membership and Flag mismatch skip payload transfer; Main=None skips Aux
transfer and callback. Every selected Main owner transfers Aux, including None,
to the **unchanged** rank-2 Main token/optional-Aux providers and client. Both
returned owners are restored into their original physical indices. The callback
cannot modify Flag/added/changed Metadata; the actual metadata array returns
untouched. `Rows` is reconstructed once after traversal, and observations are
reversed once to ascending logical ID order. No queue/barrier operation changes.

This is an indexed-body optimization, not the earlier structural-occupancy design:
there is no new cache, payload Data copy, Array pattern traversal or full shape
preflight. It preserves the original trusted representation assumptions and
per-ID bounds rather than adding a stronger rejection rule. Finite point access
and the original high-water traversal remain. Root may reject it against actual
performance or capability results.

## Reproduction and observations

Installed toolchain during this run: Bend2.0.35; checker/runtime5s, codegen30s,
clang120s, Native O3/oneworker/GPUoff. Full main fixtures run both Motion/Health
and explicit-owner/regenerated capture styles against a fresh pinned bevy-ts
reference. No historical task passes substitute for this candidate's evidence.

```sh
python3 experiments/s-perf/overlay.py /tmp/indexed-query-overlay
BENDVY_CPU=7 python3 experiments/s-perf/main-run.py --overlay /tmp/indexed-query-overlay --build-dir /tmp/indexed-query-main
python3 experiments/s-perf/access-run.py /tmp/indexed-query-overlay --evidence /tmp/indexed-query-access.json
python3 experiments/s-prep/integrated-indexed-query/run.py --overlay /tmp/indexed-query-overlay --build-dir /tmp/indexed-query-controls --cpu 8
python3 experiments/s-prep/integrated-indexed-query/ownership-run.py --overlay /tmp/indexed-query-overlay --evidence /tmp/indexed-query-owner.json
```

The distinct Type Main/Aux fixture observes ascending IDs, actual Flag values and
selection, dead row with retained payload, live Main-absent row, returned-owner
reread and retained owner sums143/2004. The single-leaf dead metadata case verifies
unchanged original metadata addressing behavior and payload-owner preservation;
it is **not** a claim that this candidate validates malformed structural shapes.
Five compiling mutants must produce exit-zero exact Native/JS counterexamples:
reverse output, wrong physical Main slot, include dead membership, lose returned
Main owner and drop callback Flag. Static actual-call-site controls reject
undeclared access, cross-schema, write-through-read and reconstruction misuse.
An additional paired control rejects duplicating the actual affine query state.

The first mutation runner stopped on an ambiguous reverse anchor occurring both
in retained original helper and new finalization. No mutant was counted detected;
the corrected specific anchor was rerun under the same limits.

Generated JS query helper bodies contain zero `.slice` or `array_node` calls:
Base.get/swap/set use native indexed operations. This avoids the structural
candidate's copied halves, but does not establish an elapsed-time improvement.
Native remains indexed root traversal; this candidate removes the Metadata restore
access and intermediate Row/Metadata reconstruction, without promising native
parity or a complexity change.

Full actual E11, integrated command/effect/payload/capture mutation gates and the
chosen combined candidate's workload/time qualification remain required before
keep/adoption. Universal owned runtime refinement, root authority, general
capture recovery, simulation and copied Tower Defense integration remain open.
