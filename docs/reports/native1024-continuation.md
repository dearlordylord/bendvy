# Native1024 owner-transport continuation

**Incomplete; investigation in progress.** User window2026-10-06
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

## Next bounded probe and open gates

Motion split-ID v10 emits an8-word carrier, but independent review rejected
its runtime admission: it allocates the ID buffer using untrusted Rows.depth
before the physical-size guard. Builds are retained as rejected history;
capacity-derived allocation must be fixed and freshly controlled before timing.
Health retains the v3 route because its wider carrier would remain16words.

Full22, all five workloads×three sizes, production authority/confinement, actual
workload transaction/reader occupancy, common timed physical-World forcing and
noise/resolution qualification remain open. [Forcing review](../reviews/native1024-forcing-diagnostic.md)
found no demonstrated deferred-update mismatch; a stronger private Bend walk
has no identical TS physical representation counterpart. Do not silently change
acceptance timing or treat full serialization after timing as that forcing gate.
