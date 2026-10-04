# Review of the next research tickets

Reviewed 2026-10-03: [S-LAYOUT](../tickets/15-indexed-storage.md) and
[S-CAPTURE](../tickets/16-capture-restoration.md), before publication.

**Decision: the revised tickets are ready for publication and both investigations
can start independently alongside open #12.** The two corrections below are now
incorporated in the reviewed ticket files. Neither needs approved ECS laws to
perform bounded implementation, falsification and measurement. Neither result
alone accepts an integrated runtime, production layout or general System API.

## Corrections incorporated and execution guidance

1. **S-LAYOUT now separates bounded and conditional deliverables.** The original
   acceptance list combined a layout comparison, owned restoration and broad
   reader/transaction integration. Requiring arbitrary affine restoration to pass
   would create the S-CAPTURE dependency that the ticket otherwise disclaims.
   Require the six comparable T10 kernels, then a separately reported owned
   payload slice: read/update, successful removal and a T06-style reversible
   mutation with failure/retry. Keep earlier commits and exact observations in
   that slice. General affine restoration is a conditional integration gate,
   with a concrete failed experiment and follow-up an acceptable research result.
   Do not mark its capability passed when it is unavailable. Reader independence
   and separate cursor positions need fresh checks wherever this candidate uses
   them; general allocation/marks/cursor integration belongs to S-INTEGRATE.
   The revision states this staging directly. Data-copy rollback remains insufficient
   evidence for the owned slice; its absence must be reported explicitly.

2. **S-CAPTURE now separates capture observations from a proposed Local contract.** The existing
   [core map](../reference/core-map.md) already records that no dedicated Local
   API was found. A fresh search of the pinned core agrees. The revised
   source-backed requirement now has two explicit subjects:
   actual closure-held state in TS, and proposed explicitly owned per-system
   state in Bend. Execute two separately instantiated TS callbacks over repeated
   success, condition skip, failure and retry, recording each capture and ECS
   observation. Compare Bend's equivalent observable state on those inputs.
   Do not substitute a shared module variable or ECS resource for an isolated
   capture and call it Local parity. TS `Runtime.ts:1387–1428` skips before
   invoking the callback and restores ECS transaction state after failure;
   `Runtime.ts:1051–1064` does not journal lexical captures. These are source
   findings, not freshly executed traces. A new ECS-owned Local abstraction's
   lifetime, identity and rollback policy must be stated separately; any new
   observable contract decision requires approval, not invented reference parity.

## Scope and dependencies

T04 establishes owned-array access and restricted updates, T06 inverse restoration
of numeric fields in an owned payload, and T09 repeatable closed templates with
returned owners. None establishes arbitrary affine closures or destructive-payload
rollback. S-CAPTURE should compare a closure representation only if expressible;
a failed closure canary can complete that comparison without making the explicit
state representation fail. Conversely, a working reversible subset cannot pass
the general capture/restoration capability gate.

T10's current ordered-list baseline fails performance. S-LAYOUT can investigate
indexed columns and ordered membership immediately; capture representation does
not determine that layout. Retain ascending entity-ID observations, explicit
barriers, logical FIFO, pre-access bounds and the existing bounded identity
contract. Foreign lookup rejection is an approved divergence from TS, so validate
it separately rather than requiring equal TS output for that scenario. Do not
silently choose new exhaustion/reuse or foreign-command result policies.

Both tickets correctly retain abstract handles and paired access controls, full
Type scope, Native/JS execution and actual reference checkpoints. Keep finite
trace equivalence separate from universal confinement/refinement. Actual compiled
mutants must exercise the changed path; old probe results are prerequisites, not
the new experiment's acceptance.

Performance remains mandatory: publish per-workload candidate/list/TS timings,
scaling, variability and memory limits, with equivalent semantics before timing.
Separate Data kernels from owned measurements and label unsupported comparisons.
Numerical thresholds and production performance acceptance remain unapproved.
No ECS proof, dependency installation, scope reduction or original
`/workspace/typescript/jev` change is authorized by either investigation.

## Review evidence and limits

Read AGENTS.md, SPEC, the checkpoint, local/live #12, the source-law decision,
R-A/R-C1 and T04/T06/T09/T10 reports. Applied the bend-ldd approval boundaries;
ran `bend version` (2.0.34) and `bend guide`. Checked all three reference HEADs
against `.references/sources.json`: they match. Inspected pinned TS transaction
and system execution source and searched for Local/capture facilities. No new
checker, reference trace, proof or benchmark was run for this document.

Publication should synchronize the checkpoint and parent tracker while leaving
#12's replacement-law approval gate open. User authorization to publish these
research tasks does not approve their future specific laws or design decisions.
