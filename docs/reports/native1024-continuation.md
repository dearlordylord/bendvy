# Native1024 owner-transport continuation

**Incomplete; bounded source investigation and raw comparisons delivered.** User window2026-10-06
18:25:54–20:25:54UTC includes delivery. Governing #21/#24 and full-core SPEC
remain open. Required JS/TS<=1 and Native/TS<=0.5 are unchanged; no canonical
20/20 reset, accepted keep, new law/proof/dependency or compiler/kernel change.

## Observed bottleneck evidence

[Source-v8 counters](../../experiments/s-prep/native1024-attribution/README.md)
freshly compare full65 worlds against actual TS. Both schemas at1024 execute
4,194,304 row updates,33,887,175 allocation requests and16,806,206 RFC creations.
Motion requests123,235,343words; Health156,789,775, exactly8more words/update.
The concrete MainSlot classes are8 and16words respectively. These are request
proxies, not physical malloc or timing. Inside the phase, blk_copy, bank_pop and
system allocation entries arezero; heap allocation misses are254. Per-update
flat Array/Buffer accesses do not grow from256 to1024. The hypothesis of deeper
runtime array-tree traversal is unsupported by these observed helper counts.

[Fresh CPU-PC diagnostic](../../experiments/s-prep/native-phase-profile/NATIVE1024.md)
collects413 Motion/366 Health process-delivered samples and matches all65worlds.
Reference-count, owner transport and callback/context helpers occur frequently.
This supports examining the seam without proving sole causation. Signals,
-g/-no-pie and endclock printing perturb execution: **no sampled elapsed result
is used for comparison**. The earlier gprof README/evidence remains intact.

## One bounded source probe

[Reviewed design](../design/native1024-owner-transport.md) and
[implementation audit](../reviews/native1024-concrete-source.md) preserve arbitrary
affine Type generic callers while adding concrete nominal carriers to the two
existing private consumers. Source29 closurea4672d110446195e3ac92911c6f41166b62025811df8816878356d0eafd08a55.
Original callbacks/providers, preflight, returned context and recovery/fallback
algorithms remain. The current Batch confinement limitation is unchanged.

[Actual emitted/build evidence](../../experiments/s-prep/source-concrete-owner-handoff/README.md)
shows the Main owner flattened into Array+scalars at the successful take,
without its opaque constructor seal there. Motion/Health nodes have9/11fields
and round to16words; wider nodes can erase any benefit. Fresh Native/JS full65
checks pass both schemas (260worlds). Fresh generic Q controls pass1,600 records and24 compiling-mutant roles;
registration passes four positives and ten intended negatives. Fresh actual
HA controls pass384 logical records,288 compiling-mutant counterexamples and
400 physical Main records. The latter include current+remaining owner recovery,
raw/cache discrepancy and original retained/rollback fields. The drifted first
wrong-old recipe attempt is retained and does not count as a passing gate.
No source-v8 control is transferred as a new-route pass.

[Independent new copied-C counters](../../experiments/s-prep/native1024-attribution/concrete-v3/README.md)
pass all65 worlds in both schemas. Requests/RFC fall by4,128,768 each, but
requested words increase46,202,880: the16-word carrier adds12words/update,
offset by the removed owner RFC. The MainSlot constructor remains once/update
at final Array publication. This is RFC removal, not elimination of every owner
box. Motion/Health requested words are169,438,223/202,992,655. The complete raw cohort below measures this representation; it does not
authorize production selection.

## Completed raw comparison

[All20 raw rotations](../../experiments/s-prep/source-concrete-owner-observations/README.md)
pass full65 in every role. Prospective r2 enrollment pins989 inputs; its first
r1 refusal for14 omitted consumed pipeline paths is retained. Same-cohort
Motion median TS635.4188185ms, v8JS564/Native354, concreteJS603/Native331;
Health TS614.561384ms, v8JS524/Native376, concreteJS542.5/Native320.5.
Concrete JS/TS is0.9489804/0.8827434; Native speedup1.9196943×/1.9175082×.
Native decreases6.50%/14.76% relative to v8, but JS increases6.91%/3.53%.
Both schemas still fail Native2×. Every outlier remains; these unqualified
ratios of medians are not canonical keeps or causal conclusions. The archive
explicitly preserves the pre-run source audit snapshot later extended by the
conditional split-ID design.

## Split-ID and compiler probes

Motion split-ID v10 emits an8-word carrier, but independent review rejected
its runtime admission: it allocates the ID buffer using untrusted Rows.depth
before the physical-size guard. Builds are retained as rejected history;
capacity-derived allocation was repaired in v12 and passes fresh130full65
worlds and1,600generic/access records. Its copied-C complete-work counters reject
the representation mechanism:101,073,863requests/37,851,454RFC/561,613,839words.
The three captured-rest closures and temporary Fold/context materialization
outweigh the8-word node; no comparative timing admission or speed claim follows.

Reviewed direct-v1 replaces that success path with saturated named helpers and
structural direct recursion over the remaining owners. Source closure
84b808cee2c1a657569888229241dd95ae59f314025512c20159d951f4a1db2c.
Fresh default Native/JS130fullworlds and1,600generic/access records pass. Actual
C has no allocated DirectDrainState constructor. Fresh copied-C65worlds show
29,762,503requests/12,677,438RFC/137,980,943words: ID buffer adds4,096requests,
RFC is unchanged versusv3, and words decrease31,457,280 (7.5/update).
Fresh Motion lifecycle gates pass304logical records,6produced-Bundle snapshots,
160records from10detected compiling mutants and200physical Main records;
15refused/insensitive/historical receipts remain separate. Guarded JS passes
fresh65,32retained records,8helper witnesses,3livekills and46guards, with92actual
consumed producer files frozen. [Ten raw source rotations](../../experiments/s-prep/source-motion-id-observations/README.md)
pass all65 fields in every role: TS633.347607ms, v3JS584.5/Native333.5,
directJS579.5/Native345. JS/TS0.9149794, Native1.8357902×; Native increases3.45%
against same-cohort v3 despite reduced words. This variant is not selected as
a Native improvement; the v3 source is retained for the next flag comparison.
Health retains the v3 route because its wider carrier would remain16words.
A persistent raw-extras8-field Health slot is a reviewed future design requiring
all packed-row consumers and short-array authority controls, not a CP-only fix.

A separate host-specific unchanged-C build probe adds only
`-march=armv8-a+lse` to existing Clang19/O3, with actual HWCAP_ATOMICS admission.
It targets observed outlined atomic calls while retaining C memory orders;
fresh Motion/Health default and variant full65/tool/header/binary gates pass.
Actual outlined atomic call sites decrease50→0 without source changes. The
final comparative cohort uses stronger concrete-v3 source for BOTHschemas;
the earlier direct-v1 LSE build is retained as untimed history. The completed twenty-rotation comparison retains all raw results: Motion
TS655.318768/defaultNative332.5/LSE336ms; Health
TS638.7356885/defaultNative322/LSE323ms. LSE speedups over TS are
1.95035×/1.97751×, still below2×. LSE medians are1.05%/0.31%
higher than default; this flag is not selected as an improvement.
[Complete raw evidence](../../experiments/s-prep/native-lse-observations/README.md)
includes every rotation, outer status and receipt. Noise qualification remains open.
This is not a portable binary or compiler/kernel source change.

A separate scheduling-only probe adds `-mtune=apple-m1` to unchanged-v3 C.
The original strict feature-list guard rejected before compilation because
Clang adds+zcm/+zcz. [Primary LLVM classification](../reviews/native1024-tune-build.md)
identifies those exact flags as non-ISA zero-cycle move/zero preferences.
A new version independently checks the ordered architectural list, generic CPU,
triple and ABI remain equal and no other added flag is admitted. All four fresh
default/tuned full65 checkpoints pass. The prospective plan was independently
replayed byte-for-byte (SHA124ef20c); the completed twenty-row cohort matches all65 fields in every role.
Motion TS843.8047295/defaultNative426/tuned398ms gives2.12011×TS and
6.57% lower elapsed than same-cohort default; Health
TS636.1532475/default328.5/tuned348ms gives1.82803×TS and5.94% higher elapsed.
The shared tune flag is not selected as a two-schema improvement; Health still
fails2×. Motion clocks across all roles differ substantially from the prior
cohort, so no cross-cohort improvement or qualified causality is claimed.
[All twenty raw observations](../../experiments/s-prep/native-tune-observations/README.md)
retain every outlier, complete outer status and receipt. Host model is unidentified; the name of this scheduling model
is not evidence that the actual host is an Apple M1.

Full22, all five workloads×three sizes, production authority/confinement, actual
workload transaction/reader occupancy, common timed physical-World forcing and
noise/resolution qualification remain open. [Forcing review](../reviews/native1024-forcing-diagnostic.md)
found no demonstrated deferred-update mismatch; a stronger private Bend walk
has no identical TS physical representation counterpart. Do not silently change
acceptance timing or treat full serialization after timing as that forcing gate.

## Delivery ledger and next frontier

| Governing gate | Status in this window | Direct next requirement |
|---|---|---|
| Reviewed affine transport design and unchanged authored callbacks | Scoped finite pass for concrete-v3/direct-v1; rejected v10/v12 history retained | Production authority/refinement and complete connected subject |
| Source-bound ownership, access, rollback and complete observations | Scoped controls pass; full22 remains partial | Fresh complete22 on the selected source under authorized checker conditions |
| JS parity / Native2× | Raw Dense1024 JS parity observed; Native2× failed on both schemas | Reviewed source improvement, then equivalent qualified measurements |
| Five workloads×64/256/1024 and warmup/forcing | Untested for these new closures | Complete parent matrix, identical approved forcing/warmup |
| Noise, interval resolution and qualified selection | Untested; raw median comparisons only | Approved measurement contract and fresh qualification |
| Actual transaction/reader occupancy and counters | Partial earlier evidence, not completed here | Actual workload boundary hooks and compiling counter mutants |
| Canonical budget, proofs and production adoption | No reset, new proof or adoption | Explicit separate prerequisites; no capability inferred from this report |

The concrete-v3 source is the strongest Native source observed in this window;
the split-ID and LSE alternatives were not selected. Continue from its exact
source closure, not from the rejected allocation-depth or closure-heavy versions.
The next source hypothesis is a Health owner carrier below the16-word allocation
class, with persistent affine extras and complete packed-row controls. Motion
needs a different source mechanism: its smaller split-ID carrier reduced requested
words but added Array transport and did not improve elapsed time. Investigate
generated-C ownership transport with fresh phase profiles before choosing it.
Neither source hypothesis is production approval.

Lossless concrete/source-ID archives and raw summary recomputation were verified.
Known elementary infrastructure checks are not ECS law approval; no unapproved
laws or new executable proofs were added. The historical withdrawn proposal
remains withdrawn.

The independently reviewed ledger snapshot is preserved in
[window review](../reviews/native1024-window-report.md). Its exact inspected
bytes precede the final tune reconciliation; that snapshot is not rewritten
to claim review of later results.

[Final tune numerical review](../reviews/native1024-tune-results.md) independently
checks all20 outer statuses, all100 role statuses, complete65 joins and every raw
median. The tune capsule independently verifies1,344 logical files/1,120 blobs;
LSE verifies1,314/1,102 and source-ID1,283/1,063. No capsule verification is a
replacement for the open parent capability gates.
