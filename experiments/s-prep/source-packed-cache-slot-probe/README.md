# Persistent packed Motion Main slot feasibility

Private Bend-source probe, not a backend rewrite or production API. Baseline is frozen
identity-query v3 source29 `0b3339e7fde4dc1af610ec76b1656b2f9c39748a546ba5929766d7445a51fa43`.
Current candidate `/tmp/bendvy-packed-main-slot-motion-v4`, source closure
`52b505c4d7c3a0b304659b48b0a892e6d0db973a3637bc033e03282792d52c6e`.
Actual full64 build `/tmp/bendvy-packed-main-slot-motion-build-v6`.

MotionMainSlot is Type: owns the complete raw coordinates Array<U32>, raw frame,
and separately cached a/b/c/d/frame scalars. The private row owner holds those seven
slots directly plus unchanged ledger/raw view/handle/inverse/marks transport.
Main setter reads actual raw cell0 then sets it and cached-a only. The returned row
stores one new MainSlot into its Main column; no nominal Position/View/Cache trio
is rebuilt there. Original nominal PositionView/Four Data is reconstructed on get.
Whether these reads unbox or recreate Native allocations is an independent open
counter gate, not inferred from source shape.

Private Host/Bench/World<Slot,...> persists through all64 scheduler frames using the
unchanged generic dispatcher, Host, Rows/World/query/transaction APIs. No wholeWorld
Cache conversion occurs per frame. Nominal raw Position is converted at original
factory/bundle ingress; terminal observations use generic Slot getters returning
original full Data views. Commands carry Slot where generic M belongs. Ledger,
Aux, metadata, flags, epoch, namespace/id, mode, events/readers and schedule work
remain present. Concrete private fallback uses checked slot-aware providers and
repackages every returned transaction field, not the incoming owner.

Six modules append private source families: cached-payload, held-adapter, host,
measurement, raw-boundaries, transaction-dispatch-adapters. Every original module
prefix/header/body remains byte-identical; original aliases/public/generic route and
SC authored callbacks are unchanged. Generic Core still accepts arbitrary Type M/A/L.
Private naming is not language-level privacy; no universal authority/alias claim.
No kernel/compiler/reference/external/dependency/law/proof changes.

Actual first gates: checker15, Cemit30, JSemit30 and approved process-local Clang19
O3 compile120 PASS. Fresh independent TS complete65 Motion Native and JS fields PASS
(runtime5, CPU9). Raw emitted clocks are not comparative performance acceptance.
Prepared full64 driver adds a separate private fresh entry; original public MotionBench
and generated original fresh entry remain present. Build pins include prepared module,
driver and generated C/JS/native hashes; source verification checks exact source29/cache
closure and all original prefixes. No synthesized compiler pass is recorded.

Retained failures: v1 multi-scrutinee tuple syntax; v2 scalar consumed twice; v3 explicit
shared scalar binder mismatched the opaque provider's linear header; v4/v5 generated
fresh helper retained old nominal Bench/factory adapter. Correct v6 keeps the expected
linear provider header and duplicates only its local U32 match binder, and appends a
private generated fresh adapter. These are concrete rejected intermediate subjects,
not exceptions to ownership checking.

Native executed allocation/RFC/word attribution is pending independently. Do not expand
Health or claim adoption until that mechanism checkpoint is observed. New dedicated
stale-cache/raw frame/cell lengths, retained-view, returned-owner/fallback, authority,
factory/provider, actual Tx/suppression/rollback/order/live mutation gates remain OPEN.
First full65 dense equality does not imply those capability gates. Full22, proofs and
mandatory equivalent-work performance acceptance remain open.

Reproduce: derive.py --output FRESH_OVERLAY; build.py --overlay FRESH_OVERLAY --output
FRESH_BUILD; verify.py with those paths. The current task uses executable checker15
only, default proof budget5 unchanged. Original references are absolute read-only root
paths. evidence/motion-feasibility.tar.gz archives source29/cache, actual generated C/JS,
prepared modules, intermediate failure/build receipts and both finite full65 records;
all decoded member hashes independently verified in evidence/manifest.json. Native
binary is hashed in build receipt, not committed.
