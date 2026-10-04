# Implementation review — Spec axis

## #17 S-CAPTURE

Reviewed `git diff 484fb88...00f4407` and `git log 484fb88..00f4407 --oneline`:
`96bd5d9` tracker instructions; `400f4dc` capture/restoration implementation;
`00f4407` integrated rerun record (no implementation change).
Authority: live [#17](https://github.com/dearlordylord/bendvy/issues/17),
[ticket](../tickets/16-capture-restoration.md), [SPEC](../SPEC.md),
[initial review](next-research-tickets.md) and [law decision](laws-decision.md).

**No blocking Spec findings or scope creep identified for this bounded research.**

- “Demonstrate multiple executions of each instance, persistent Local state and
  isolation”: `local.bend` returns each affine counter owner; `schedule.bend`
  stores A/B separately. `closure.bend` consumes each generated closure once.
  `run.py` substitutes closure invocation into the entire schedule and compares
  both representations against the same 39 TS checkpoints, beyond isolated
  canaries. The TS factory creates distinct lexical environments.
- “Restore without cloning Type storage or replacing the subject with Data”:
  `core.write` retains the owned array and journals old numeric fields;
  `finish` applies inverse writes in LIFO order. The trace covers failed
  11→21→31 restoration to11, retry, earlier publications and unchanged payload
  fields. Snapshot/destructive negatives reject their concrete duplication/alias
  attempts; they do not establish general restoration impossibility.
- “Check exact payload observations, publications, failure identity and Local
  state at each boundary”: the real TS adapter and Bend trace include pending
  command tag/publisher, actual event reads/unread counts, B/code7 and omitted
  parent Tail. Failure preserves B's saved reader; retry sees message1 again.
  Success and registered skip have distinct observations.
- “A reversible subset does not establish arbitrary callback rollback”: the
  README expressly leaves arbitrary destructive mutation, Local lifetime/policy,
  full reader clocks, command application/authority and general integration open.
  Bend host labels are diagnostic strings, not claimed native IO evidence.
  These are permitted bounded limits, not silently removed requirements.

Inspected all changed implementation/fixture files, runner, expected trace,
recorded mutants and pinned TS execution/rollback source. Source hashes and
all reference HEADs match the recorded manifest. Six intended negative/positive
pairs and five compiling mutant checks are wired into the runner. The coordinator
reports the full CPU10 rerun passed, including both 39-line schedule variants,
two canaries, six controls and five mutants. This reviewer did not rerun it.
The coordinator owns delivery checklist synchronization. Specific law, production API and
performance approval gates remain open.

## #16 S-LAYOUT

Reviewed cumulative range `484fb88...276a71c`, focusing on
`df22bf2...276a71c` (`276a71c`, indexed/owned-storage investigation). Authority:
live [#16](https://github.com/dearlordylord/bendvy/issues/16),
[ticket](../tickets/15-indexed-storage.md), SPEC, initial review and law decision.

**No blocking Spec findings or scope creep identified for bounded research.**
All nine acceptance items have concrete implementation or explicitly bounded
evidence; this does not pass product performance or integration gates.

- Representation/bounds and identity/order: `core.bend` checks logical IDs and
  setup capacity before reversed-slot array access; trusted fixed constructors
  establish array sizes. `identity.bend` carries actual factory namespaces,
  binds commands to handle IDs and retains pending/live distinctions. Lifecycle
  checks cover FIFO, reinsertion, exhaustion and out-of-range IDs; the foreign
  collision is checked as the approved TS divergence. `relocation.bend` actually
  moves a row and updates its map. Its stale-map mutant is observable. Timed
  fixed mapping and untimed relocation are accurately distinguished.
- “Data-copy rollback cannot satisfy this bounded owned-payload criterion”:
  `owned.bend` swaps genuinely Type cells out, returns their sole owners and
  reverses numeric-field inverses on retained payload arrays. Full snapshots,
  retry, prior commit and explicit disposal are compared with actual TS.
  Ten generated provider pairs exercise both nominal schemas through the real
  indexed read interface, including fabrication/reconstruction and write denial.
- Data/owned comparison and exact observations: six Data kernels cover all
  required sizes; separate reader fixtures exercise independent message/change
  positions through indexed-row projections. The owned comparison uses a
  disclosed two-cell slice and a distinct owned-list baseline. Neither reader
  integration nor owned scaling is inferred from Data timings. Ten compiling
  mutants cover mapping, order, readers, writes, churn and both rollback paths.
- Reproducibility/tradeoffs/follow-ups: inspected timer placement, three warmups,
  five samples, raw observations, RSS limitations and integration proposal.
  Verified source hashes, reference pins, 18 Data cases × five backends × five
  samples, owned five-backend samples, and recorded Data medians/ranges.
  Dense, sparse-JS, rollback-JS and owned-versus-list regressions are disclosed.
  “Research completion is not final performance acceptance” is respected.

This reviewer inspected code, adapters, controls and stored 59 semantic
checkpoints; no new runtime/measurement run is claimed. Coordinator verification
was running during review. #12 is not yet reviewed in this report.
