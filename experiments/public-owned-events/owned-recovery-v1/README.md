# Detached affine staging — development prototype (#53)

`staging.bend` is generic over arbitrary `Payload:Type`. An invocation-created
payload or an explicitly transferred owner from surviving external state may be
offered to a detached Stage. A caller's admission result either accepts ownership
or immediately returns the original incoming owner together with the unchanged
Stage. Acceptance prepends internally; commit and abort each consume Stage and
return its entire list in offer FIFO order using Base.List.reverse. Distinct
`Committed`/`Aborted` receipts preserve the terminal result. Commit hands ownership
to its caller; it does not publish into a World by itself.

No resource/component extraction is provided: transactional rollback of live ECS
owners remains #51/#52. There are no reader snapshots, scoped read views,
classifications of expensive payloads versus notifications, mandatory finalizers,
IO cleanup, cloning, or automatic reinsertion. Caller admission is a Bool result,
not a built-in capacity or failure policy. The existing Data event API is untouched.

`controls.bend` source-consumes success, abort and immediate refusal. Complete
Array payloads have cells11,12 and21,22,23,24; terminal observers consume every
list entry and every Array leaf. Abort retains both staged owners in FIFO;
refusal returns the first staged owner plus the second incoming owner separately.
These paths source-check, but are not executed observations or universal proofs.
`duplicate-owner-negative.bend` calls the abort control and attempts to duplicate
the recovered list; source checking refuses `owners (consumed more than once)`.

Raw guide/source/negative outputs are retained in `evidence`. Guide cap5;
source checks use existing scripts/bend-check cap5, telemetry off and the shared
/tmp/bendvy-parity-heavy.lock. Positive source attempt1 exit0; intended negative
attempt1 exit1. No backend, law/proof, World integration, numeric gate or #53
completion claim. Frozen delivery/reader/projection/retention/rollback evidence
remains due; this direct development shell lock is not a frozen collector.
