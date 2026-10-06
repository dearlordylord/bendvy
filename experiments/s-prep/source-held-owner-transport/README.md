# Source Held owner transport — bounded experiment

Draft experimental source variant under #21/#24; no production API/adoption, full22, universal refinement/proof or performance acceptance.

Pinned frozen 29-module baseline: `/tmp/bendvy-query-frozen-provider-native-v3`. Only `held-adapter.bend` changes. Private `PrototypeFlatHeld<W,Raw,View,L,LV,H,C>` keeps separate affine Main/Ledger Raw owners and immutable Data views. Generic Raw/L remain Type. Main/ledger providers transport those fields directly; public Cache wrappers are rebuilt once at storage publication. World boxing, abstract rank2 client headers, general supplied getter clients, original callbacks, actual true-old swaps/inverse/mark order and guard/fallback behavior remain. Public Held/Cache and every non-private-boxed definition header are preserved.

The obsolete private `prototype_boxed_*` family is replaced rather than retained as duplicate unreachable definitions; new helpers use `prototype_flatmain_*` names (historical prefix, now both fields). Private taken binder/call order puts the computed Rows/Taken pair before ledger, so the legal head match follows binder order. Pure argument expressions and all transaction fields are preserved. The new experimental constructor is exported by Bend like the existing Held constructor; private means task-local representation, not module access control. Abstract callback confinement must pass fresh negatives; global constructor/factory authority remains an explicit production follow-up.

Fresh ordinary Motion and Health source counts: **9,562,688 → 9,300,544**, exactly 262,144 fewer Cache expressions (2/update). Owner kind rename cancels: Held−655,360/PrototypeFlatHeld+655,360. Both quiet and instrumented nine complete worlds match fresh TS; counter marker adds 1. This is generated source output without any JS rewrite. Counts are not heap allocation or speed acceptance.

Motion and Health full64 drivers check/emit C/Clang19 O3/emit JS within diagnostic 15/30/120/30 caps. All original work remains; driver adaptation changes only exact overlay import prefix. Initial duplicate-family full driver checker15 timeout and two pattern-order parser failures remain. One Clang child root typo exits127; corrected continuation reuses exact already checked/emitted C, retaining the prior receipt.

Reproduction:

```sh
python3 materialize.py --input /tmp/bendvy-query-frozen-provider-native-v3 --output /tmp/fresh-held-flat
python3 build.py --schema Motion --overlay /tmp/fresh-held-flat --output /tmp/fresh-held-motion
python3 controls.py --overlay /tmp/fresh-held-flat --output /tmp/fresh-held-tx --gate tx
python3 controls.py --overlay /tmp/fresh-held-flat --output /tmp/fresh-held-lost-mark --gate tx --mutation lost-mark
```

CPU 10 only, checker diagnostic 15 explicitly opted in; default/proof 5 unchanged, runtime 5/C emission 30/Clang 120. Approved private Clang19 child wrapper only; no toolchain installation or compiler/kernel/reference/dependency/law changes. Shared protected runners/oracles remain unchanged. The local recognizer adds only exact reached family/route/setter/inverse/mark anchors; executor receipts explicitly pin both original recognizer and actual local override. Root owns adjacent timing and integration. Generic unsafe alias/FFI exposure, full connected matrix and universal refinement remain separate follow-ups.

Fresh exact-source controls pass 576 original/suppressed-owner full checkpoints per backend, plus compiling actual lost-mark/inverse-order counterexamples on both schemas/cached/raw observers. Actual new-provider boundary has four positives/twelve intended negatives; generic arbitrary-Type owned-array canary passes Native/JS and rejects Raw cloning at the intended Data-kind boundary. All four Main/Ledger retained Data snapshots compare every literal field before/after actual writes on both backends/cached/raw. Fresh static/factory matrix passes 16 backend subjects/128 full records, including independent original getter clients.

**Stock access9 remains blocked**, not passed: its original positive uses runtime `-Owner/get` while the inherited frozen query `O.client` requires frozen `~Owner/~get`. Exact failure is archived; these new-provider controls do not replace or waive full access/full22 gates. Adjacent Native attribution reports zero allocator/RFC/requested-word delta; that separate task's diagnostic is not this task's acceptance. No Native savings or stable timing result follows.

Receipts and compressed actual source/field outputs are in [evidence](evidence/summary.json), indexed with source/output SHA256. Initial build receipts pin driver bytes and commands; initial executed build-runner hashes were not captured. The final recipes are tracked; no claim reconstructs absent initial runner hashes.
