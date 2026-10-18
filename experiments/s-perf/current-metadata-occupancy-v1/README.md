# Persistent metadata observations — finite Readers Motion64

Six actual consumers passed: ordinary JS/Native, the full affine fixture on both
backends, and one compiling reporter defect on both backends. Evidence is retained
in `results/actual-attempt01/`; `verify.py` validates the package without a compiler
or backend replay.

The ordinary canonical stream remains **10,810,200 bytes**, SHA256
`183936740ad2407530099198388cc87d872b121fa0681a3a7777ec42797b83ce`.
The independent full metadata sidecar is **67,575 bytes**, SHA256
`09d1d2c794cd9893eae80ade652873caf4a94d588b4e4c19baeb2182b4bd03fa`.
The indexed Readers model reproduces the original complete stream before adding
observations. No subject output supplies the model or fixture expectations.

| Column | Recorded states | Maximum normal-array populated rows | Maximum added/changed array shape, each |
| --- | ---: | ---: | --- |
| Main | 321 | 65 | 128 leaf occurrences, 127 node occurrences |
| Aux | 23 | 22 | 64 leaf occurrences, 63 node occurrences |
| Flag | 22 | 21 | 64 leaf occurrences, 63 node occurrences |

These are per-column maxima over **completed** `empty`, `mark`, `clear_stamp`, and
`restore_stamp` snapshots. Ordinary execution reaches 256 Main marks and 64 Main
clears, 22 Aux marks and 21 Flag marks. It reaches no restoration. Rejected
Aux/Flag clears produce no invented mutation sample. `ensure`, `prepare`, and
`recover` forward history; they are not additional measurement events. Indexed
factory growth monotonically increases complete metadata shapes up to the returned
shape; this is a source/model bound, not measurement of intermediate allocations.

`ArrayStats` is `[leaves,nodes,nonzero]`; `EntryStats` is
`[physical,addedNonzero,changedNonzero,populated]`. Indexed `populated` counts the
union of nonzero normal-array slots, using actual ordered leaves from both arrays;
exceptional entries remain separate. Plain zero-valued entries still count as
physical entries. Capacity/depth are actual stored fields, measured separately
from array shapes. Timestamp magnitude is never used as occupancy.

All shape counts are structural occurrences, **not unique allocated cells or
bytes**. Shared scalar representations may have multiple references. `values`
shape covers the column's values array, excluding evacuated current, remaining,
and history payload storage. Those arbitrary affine owners are preserved, but
this report does not measure their storage. Summing per-column maxima would not
establish a whole-world peak; aggregate retained-owner occupancy remains open.
Current Tx has no separate marks-journal field.

The private `Monitored` carrier preserves the original callbacks, captures,
ordinary App execution, and canonical render/chunk construction. Generic
inspection handles Plain, Indexed, Prepared, and PreparedIndexed carriers and
wrapper chains without requiring payload `Data`. Fixtures retain full tree
strings/cells and a `Type` payload containing an owned array and a function that
captures another owned array. After inspection/recovery, the function is invoked
once and its complete result checked. Fixtures cover physical zero entries,
exceptional IDs, unequal raw shapes, payload/metadata capacity separation,
Prepared current/handoff/history owners, manual zero restoration, and actual
component transaction failure. The latter checks the restored payload/stamp,
clock, handle and retained observation history. Raw-constructor cases test
inspection; they do not establish constructor refinement.

The reporter defect changes only serialized `ArrayStats.nonzero` to `1+nonzero`.
Both backends retain the full ordinary canonical stream, reject the normal metric
gold, then match the independent 67,581-byte counter gold exactly. All 732 changed
fields are checked. Fixtures and controls are finite evidence, not universal laws
or proofs.

Actual01 ordinary plans were **never executed**. Before actual02, transparent
Monitored render branches were moved ahead of existing generic fallbacks.
`oracle/SOURCE-PROVENANCE02.json` distinguishes the immutable historical copies
from repaired source. The package retains the unexecuted plans and recovers their
changed source bytes from the exact historical git object; no current-filesystem
validation is claimed for those old versions. Actual02 and all control plans bind
current source separately. Initial source-check failures remain in `checks/`.
The final pure checks pass; the ordinary IO entry separately reports only its
existing unsafe/foreign dependencies, not a mathematical proof.

The existing collector, regular-file metric verifier, explicit environment and
output-local CommonJS configuration are reused. Budgets are source 15 seconds,
emission 60, Clang O3 120, consumer 180 and offline retention/verification 120 per
process. No source/core API, law, dependency, performance criterion or runner was
changed. This delivery makes no timing, RSS, allocator-memory, aggregate-world
peak or full #21 qualification claim.
