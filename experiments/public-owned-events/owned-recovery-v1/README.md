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
attempt1 exit1. That source-stage evidence establishes no backend, law/proof, World integration, numeric gate or #53
completion claim. Frozen delivery/reader/projection/retention/rollback evidence
remains due; this direct development shell lock is not a frozen collector.

## Executed detached development controls

A complete byte oracle was authored from the fixture's cells/order before the
first child: commit and abort each return first[11,12], second[21,22,23,24];
immediate refusal returns staged first[11,12] and incoming second[21,22,23,24].
`main.bend` consumes all owners through the complete observer. Actual JS and
Native stdout are byte-identical,132bytes,SHA256
`ed73cad108507ba89f20870d8b6cbda757e0d66e8e81d08b202e6870aade838d`.
Runtime stderr is empty. Node24.20.0 and approved private Clang19 are used.

The first JS whole-byte gate failed because `IO.print` appended a terminal LF
omitted by the pre-run oracle. All other bytes match exactly. Original oracle,
executed runner, raw outputs and failed receipt remain immutable under
`evidence/js-1`; `expected-1.stdout` retains that original expectation.
`expected.stdout` differs only by one terminal LF; retained JS raw was compared
without a backend replay. No semantic expectation was derived from stdout.
Native subsequently passed the repaired complete oracle on its first execution.

`development-run.py` narrowly adapts the existing complete-decoder development
runner and reuses task_runner, ReceiptBoundary/GuardBoundary and CommandLogs.
Sources/Base/resources/tools/helper bytes, explicit approved environment, oracle,
raw outputs and generated hashes are guarded initially, after acquiring the
heavy child lock and terminally. Commands are CPU5; JS/C emit cap30, private
Clang build cap120, Node/Native cap5; Native threads1/GPUoff. Retained source5
entry check PASS. No cap increases or concurrent heavy children were used.
Only raw/plan/receipts are committed, not generated binaries or local environment
files. Plans retain historical absolute paths and tool/resource hashes; this is
scoped direct development evidence, not portable tool-resolver qualification.

Run `python3 experiments/public-owned-events/owned-recovery-v1/verify.py` for a
no-child full raw/source/oracle join, including historical LF-only repair. Its
scope does not certify host tools or reconstruct omitted generated artifacts.
No new proof, mutation execution, Type fan-out, World admission, #51/#52 rollback,
retention/readers/performance or #53 completion is claimed.
