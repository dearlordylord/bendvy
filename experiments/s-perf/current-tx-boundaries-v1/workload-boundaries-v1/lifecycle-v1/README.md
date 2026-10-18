# Actual Lifecycle transaction boundaries — Motion64

Private instrumentation of the unchanged ordinary LC2 workload; production ECS is untouched.

- One primary and one genuinely IO-created foreign World; original payload owners, Local arrays, six schedules, barriers, queries and rope/chunk output remain.
- 4,226 actual records: main/foreign seed, 4,096 read-only `scan/unselect` discards, 64 reservations and 64 disposals. Records are grouped by owner, with local ordinals; this is not global chronological order.
- Actual append/current/peak counters are checked against prefinish list traversal. Finish records witness the actual returned World. Unselect records witness the original rollback-returned World and have `committed: null`; no consumed-Tx postcounts are invented.
- The independent oracle reproduces the original complete 3,848,488-byte LC2 trace before deriving the boundary sidecar. A reached reporting mutant changes only the 4,096 raw-discard outcomes from null to false; canonical output must remain identical.

`COPY-BASIS.json` separates the import-only declaration wrapper from the sixth-field structural overlay. The accepted immutable World/Tx identity is shared. `checks/GENERIC-CONTROL-APPLICABILITY.json` records external prerequisite controls, not self-contained re-verification.

This first Motion64 slice does not qualify other sizes/schemas/families, nonempty raw discards, unreached relation/owned-decode aborts, separate recovery journals, stamp peaks, marks, allocation/RSS or comparative timing. Physical lifecycle stamps remain observed by LC2. Per-append ticks are unavailable; actual begin/end ticks remain distinct.
