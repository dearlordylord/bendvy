# Fresh Owned controls on Slot Host closure

Frozen source `4baad4960575cda216576e8b90593fbd7ed7dcd44cfa86836b8d87dd5af71f5c` (`/tmp/bendvy-slot-host-v1`), implementation [1429379](../source-slot-host/README.md). New isolated finite controls; no core/shared runner changes. CPU10, authorized executable checker15s, emit30s, Clang120s, runtime5s; default/proof5s unchanged. Bend2.0.35/version/guide read before this window's Bend work. No law/proof, dependency, compiler/kernel/reference change or canonical allowance reset.

## Observed routes

| Subject | Actual route | Fresh result |
|---|---|---|
| Unchanged `fivehour-connected-gates/owned-storage-run.py` | Generic indexed `S.Rows` with distinct affine Type Main/Aux owning Arrays; **not** Slot Host dispatch |39 literal records/backend, three intended type negatives, three compiling storage mutations detected |
| Unchanged `full-shape.bend` | Private descending ID cursor on arbitrary Type Main/Aux/Ledger |20 exact physical full-shape records/backend; four selections at depth0–4 |
| `public-query-full-shape.bend` | Original public `Q.each`, abstract client, trusted **nonidentity** getter |20 exact records/backend; selected Main scalar changes once and complete returned affine owners survive |
| Motion/Health Slot payloads | Actual `CP.prototype_slot_position/vitals_get/swap` |Five full-cell snapshots/schema/backend; raw and cached metadata deliberately differ, retained Data view remains old, two swaps return actual old raw scalars |
| Motion/Health Slot Rows lifecycle | Actual generic `S.Rows` containing nominal affine Slots, then actual Slot getter/swaps |50 literal records/schema/backend: shape, extract/restore/remove, zero/hole/dead/out/max missing, reinstall, full payload snapshot |
| Concrete Slot cloning controls | Actual nominal Slot declarations annotated as Data |Both schemas reject intended `expected Data / observed Type` |
| Live Slot/Rows semantic mutations | Actual reached CP swap helpers and S.remove_done |Ten compiling variants, each JS+Native, with exact intended witnesses |
| Public query returned-owner mutation | Actual reached Q.struct_idx_return |Compiles/runs both backends; first expected Main `1000@2` becomes `none`, while handles/other fields remain equal |

All payload depths0–4 (lengths1/2/4/8/16) observe every cell; generic indexed storage additionally grows to capacity131072/depth17/high65537. The generic full-shape fixtures print **all physical** Main/Aux/Ledger trees, namespace/next, shape/high, live/flags/stamps/mode and ordered results, including dead/high-excluded owners. They do not infer preservation from selected values alone. These are finite representative Type payloads, not a Data-only restriction or universal Type theorem.

The public-query oracle starts from the unchanged independently authored literal state. Only the selected Main scalar gains one through the supplied getter; Aux, Ledger, all arrays and metadata remain exact. Dropping the callback's returned Main is detected even though the query's Handle outputs stay correct. This tests the original generic query route separately from the callback-free private cursor.

Slot witnesses detect: lost raw cell0 (100 instead of700), altered unrelated cell1 (0 instead of101), stale cached-a (999 instead of700), wrong old values ([500,700] instead of[100,500]), and removed membership incorrectly remaining live (`unexpected-present` at dead ID3). Retained views keep original cached-a999; raw scalar100 differs intentionally. Mutations are applied to actual reached definitions on fresh copies; current candidate is unchanged.

## Failure history and evidence

`evidence/summary.json` records successes and failures. Initial lifecycle fixtures failed for forward callee order, computed-match syntax, missing Data reuse annotation and a recursive-function-value termination restriction. The final fixture uses five explicit finite missing-ID stages with identical original inputs/literal expectations. No core algorithm, runtime cap or oracle was weakened. Initial public-query callback fixtures used ordinary/erased provider binders incorrectly; the final frozen binder spelling matches the existing public query contract. All failed receipts and original fixture bytes remain archived.

`evidence/controls.tar.gz` deduplicates177 SHA256 objects representing1353 source/build/command/output files. `manifest.json` maps every original relative path and permissions to its content hash. `evidence-replay.py` checks the archive and every object, optionally reconstructing all evidence. Installed Clang14 is used by the unchanged generic runner; new finite fixtures use the already approved Clang19 child wrapper. These functional observations claim no comparative timing.

```sh
python3 experiments/s-prep/source-slot-host-owned/generic.py --overlay /tmp/bendvy-slot-host-v1 --output /tmp/owned-generic-fresh
python3 experiments/s-prep/source-slot-host-owned/fixture-run.py --overlay /tmp/bendvy-slot-host-v1 --output /tmp/owned-public-query-fresh --fixture experiments/s-prep/source-slot-host-owned/public-query-full-shape.bend --expected experiments/s-prep/source-slot-host-owned/public-query-full-shape-expected.txt
python3 experiments/s-prep/source-slot-host-owned/mutants.py --overlay /tmp/bendvy-slot-host-v1 --output /tmp/owned-slot-mutants-fresh
python3 experiments/s-prep/source-slot-host-owned/query-mutant.py --overlay /tmp/bendvy-slot-host-v1 --output /tmp/owned-query-mutant-fresh
python3 experiments/s-prep/source-slot-host-owned/negative.py --overlay /tmp/bendvy-slot-host-v1 --output /tmp/owned-slot-negatives-fresh
python3 experiments/s-prep/source-slot-host-owned/evidence-replay.py --extract /tmp/owned-archived-evidence
```

`fixture-run.py` likewise runs each tracked fixture/expected pair with fresh output paths; `slots-generate.py`, `slot-lifecycle-generate.py` and `public-query-generate.py` regenerate only these authored controls. Source/cache preflight pins all29 files and both closure digests. The unchanged historical owned-index harness is a separate Array mini-provider, not actual storage/query/Slot Host, and was not relabelled as connected evidence.

Full Host dispatch, captures, factory/staging, Tx/rollback and E11 receipts belong to other workers. This package does not transfer their results or claim full22, universal authority/refinement, production adoption or performance acceptance. Follow-ups remain: complete independent connected gate map and original Host/E11 coverage; additional arbitrary nested Type payload representations/depths; approved general invariants/proofs and qualified equivalent-work performance.
