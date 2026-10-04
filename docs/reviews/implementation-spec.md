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
performance approval gates remain open. Other packages are not yet reviewed.
