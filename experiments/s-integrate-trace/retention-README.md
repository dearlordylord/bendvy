# E11 fresh public TS retention reference

**PASS: ten schema/case invocations**, separately bounded to five seconds, for
[#19](https://github.com/dearlordylord/bendvy/issues/19). This executes the E11
public retention lanes of the frozen [trace](../../docs/design/s-integrate-trace.md)
from `f6ef46c`; it is a reference prerequisite, not integrated Bend acceptance.
Evidence pins the adapter, trace, tracked source manifest and actual reference
commit/files. Node v24.20.0 imports the pinned TS sources directly; no dependencies
were added. Each case creates fresh real public runtime/system instances.

```sh
node experiments/s-integrate-trace/reference-retention.mjs --all
# Optional individual replay; inspect the emitted status/firstDifference:
timeout 5s node experiments/s-integrate-trace/reference-retention.mjs Motion removed
```

`--all` launches ten sequential Node children using `execFileSync(timeout:5000)`;
the timeout bounds each complete invocation, including imports, public execution,
all comparisons and serialization. It records PASS/FAIL, execution errors or an
unresolved timeout and exits nonzero unless every case passes. Only its own child
can be terminated. Recorded wall times are approximately 0.10–1.05 seconds per
case; these are reference execution limits, not performance measurements.

| Lane, repeated separately for Motion and Health | Fresh observed result |
| --- | --- |
| Message overflow, C=65536 | Fast reads every code0..65535. After code65536 and trimming, B's first post-drop attempt fails with exact B/code7; the same B instance retries with [65536]/lag=true. Independent Fast reads [65536]/lag=false. Oversized codes65537..131073 are completely dropped: both readers see []/lag=true, new Late sees []/lag=false. |
| Main removal overflow | Reserve raw IDs1..65537 and compare all full Main/Aux/Flag fields via public Q/added/changed for both initial readers. Delete+D+Fast in **one dispatcher tick** lets Fast read all removals before next-frame trim. B's first post-drop failing read and same-instance retry both return IDs2..65537/lag=true. Independent Fast then returns []/lag=false. |
| Despawn overflow | Same fresh setup with despawn: Fast initially sees all IDs in both removed and despawned streams; B fails/retries with IDs2..65537 and both lag flags true. Independent Fast sees both streams empty/not lagged. |
| Late lifecycle registration | After dropping raw ID1, new Late reads the retained IDs2..65537 with no historical lag; it does not substitute for B's failure/retry. |
| Unheld expiration | Spawn two, remove Main on first, despawn second, then three empty ticks before first registration. Q/added/changed/removal/despawn/messages are exactly empty and no historical lag is reported. |
| Old surviving marks | Prime only Fast, seed one, update slot0 to11, three empty ticks, then first B. Both added and changed contain the survivor with complete current Main [11,11,12,13] and unchanged metadata/Aux/Flag. |

Messages use actual `events.ping.all()/lagged()`. Lifecycle public system views
provide `all()` **without a `lagged()` method**; their dropped-record signal is the
public `runtime.debug.observe` system trace's `missed` entries. The artifact saves
actual reader results plus public dispatcher frame/tick/outcome/missed for each
reader, including failed attempts. No internal log/cursor/world read supplied
public evidence. This observable distinction must carry into the integration
trace; it is not a new lifecycle lag API.

## Exact checks and compact evidence

Every returned sequence is compared element-by-element against the frozen lane
expectation; all Main array elements and metadata, all Aux fields and Flag group
are deeply compared for **every** selected Q/added/changed row. Health uses
levels/reserve/class and layers/grade; Motion uses coordinates/frame and
rates/moving. Sets/multiset/count/checksum comparisons do not replace order or
payload comparisons. Raw reservation sequences, exact dispatcher failure objects
and per-base-instance invocation counts are also checked.

After those checks, contiguous actual sequences are encoded losslessly as
`{first,last,count}` inclusive ranges; empty sequences remain []. Full rows encode
actual raw ID and actual payload parameter x sequences, four-slot formula
[x,x+1,x+2,x+3], metadata and complete Aux/Flag. `currentSlot0=11` records the
surviving-mark override while other slots remain unchanged. All other fields are
constant only after full equality checks. These encodings describe actual reads,
not manufactured range-only read substitutes. A mismatch retains its first full
actual/expected diagnostic in the JSON and leaves the lane failed.

The message case additionally keeps one real full-payload survivor throughout;
its Late reader sees the old surviving added/changed marks while messages are
empty/not lagged. This extra payload fixture does not change the frozen message
expectations. Lifecycle Fast must run with deletion+D in the same tick: putting it
in the next tick would already trim ID1 before that read. The initial adapter
probe used the latter ordering and failed; it was corrected to the frozen trace
ordering, not by changing expected retention values. The final frozen sweep has
no source-expectation first difference or unresolved public case.

## Limits

This covers public E11 reference observations only. Ledger/Audit/Mode provisioning,
E0–E10 integrated transactions/captures, factory/root guarantees, affine Bend Type
ownership, integrated Native/JS parity, semantic mutants and measured performance
remain separate gates. TS payloads are fresh immutable-style records; this does
not establish affine ownership. No internal C3 diagnostic was needed or counted.
No reference, Canonical Tower Defense, runtime or proof source was modified.
