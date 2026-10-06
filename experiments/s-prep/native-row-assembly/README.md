# Native row-owner assembly diagnostic

Unchanged baseline/row Motion C are emitted to ARM64 assembly with identical
approved private Clang19 -O3 -S -pthread, CPU11 and120-second child caps. Both
pass; original C hashes are unchanged. Commands and output hashes are archived.
No source/compiler/kernel/reference edit or runtime measurement occurs here.

Public Heldmotion_row input ABI is already flattened identically in both generated
C files:27 scalar/Term owner slots. Selected Handle is two u32 slots21/22;
World namespace slot0 is compared to21. Row splitting does not add public-entry
arguments. The specific emitted function has these static footprints:

| Property | Baseline | Row split |
| --- | ---: | ---: |
| stack sub allocation (plus16 prologue) |688|576|
| folded spill annotations |111|64|
| folded reload annotations |177|126|
| stack-address load/store instructions |351|245|
| assembly excerpt lines |2430|1146|

This emission does not support the proposed increased public-entry/spill footprint.
It does not establish dynamic executed traffic, latency, causal speed benefit,
calling frequency or universal compiler behavior. Functions contain multiple
branches; static instruction counts are not measurements. Flattened transport
still uses runtime register/stack slots; new private callback owner boundaries
must be inspected independently before attributing their cost.

Full and exact Held-function assembly excerpts plus compiler receipts are in
hashed deterministic archives. Existing full65 semantic controls and allocation
counts are distinct evidence in native-hotness-seed-followup, not re-run acceptance
of any new source in this assembly-only task. Performance/authority/full22 remain
separate gates. A useful next source seam is avoiding redundant boxed Held cache
or handles inside callbacks while preserving the unchanged public flattened entry;
this is a hypothesis, not an approved optimization.

## Actual write-row-fold v2 transport

The separate write-fold C
`4b6402750739fbf88959eaf82931b510dbd9ac9903f09e53582f1905bcf5e7f2`
passes unchanged same-toolchain O3-S/120 emission. Its transport differs from
prior row split despite identical independently observed allocation counters.

| Emitted body | Input runtime slots | Stack sub +16 | Spill annotations | Reload annotations | Stack load/store instructions |
| --- | ---: | ---: | ---: | ---: | ---: |
| prior row entry |27|576|64|126|245|
| fold step |30|592|103|190|355|
| fold self-loop |29|224|51|80|152|
| fold entry |29|176|14|36|63|

This is exact static function evidence, not summed executed cost: branches,
tail transfers and calling frequencies differ. The larger step static footprint
provides a concrete transport seam for source investigation, not a causal
explanation of any timing result. No speed threshold, source adoption or semantic
gate is established by assembly. Exact function excerpts/fullassembly/receipts
are archived separately from earlier row source.
