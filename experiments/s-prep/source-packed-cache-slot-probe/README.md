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
The independently executed Native counter below observes zero nominal Main/View
constructors in this phase; this is not inferred from source shape.

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

Independent Native attribution (`primitive_lifecycle_controls`) passed fresh65 fields
with original C preserved: requests 17,171,399→12,977,095 (−4,194,304),
RFC cells 8,479,038→6,381,886 (−2,097,152), requested words
41,507,855→35,216,399 (−6,291,456). It reports 1,048,576 Slot constructors
replacing each Main/View/Cache triplet, with 24,576 Ledger-boundary Cache constructors
remaining. See evidence/native-counter-followup.json for the exact independent receipt
hash and scope; the producer archive is authoritative. This count is not a speed result.
Health is not implemented and adoption remains open. New dedicated
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
