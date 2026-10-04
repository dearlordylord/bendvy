# Actual A/B transaction join

Standalone trusted hook driver, not nested scheduler/reader/capture acceptance.
No proof or production API is claimed. Run `python3 transaction-ab-run.py` from
this directory. Checker/runtime invocations are five seconds; generation/build
remain separately bounded by the existing t05 helper. No dependency/install change.

For each nominal schema, one actual factory creates a world; real reserve/spawn and
apply create a,b,c and their genuine Main/Aux owners. Actual A writes a11 and
Ledger101, reserves/stages p4, stages removal of a.Flag, emits1 and commits. Its
stdout Audit fixture effect runs after writes/staging and before commit. B is the
committed closed rank-2 body from systems11b8542, supplied fresh opaque Tx/H
operations by transaction-dispatch-adapters. It writes b30 then50, Ledger201,
reserves q5, stages spawn/flag/Ping9, calls the actual supplied IO Audit and fails7.
The real inverse journal restores b20/Ledger101; A values/pending/marks survive,
q5 remains missing and next6 is retained. Same body retry reserves r6, commits
b50/Ledger201/Ping2 and preserves pending FIFO. Explicit apply makes p4/r6 live
and applies flags; q5 never appears. Both schemas use their full four-cell Type
arrays and every nominal metadata field, with no seeded poststate substitute.

Every one of28 output lines is compared to independently written operation-input
expectations in transaction-ab-oracle.py. Full owner-return WorldViews include all
rows, Main/Aux/Flag, marks, typed pending payloads, Ledger, Mode, namespace and next.
The retained world is separately read through the existing validated storage-stage
observer at A/failure/retry; the final returned owner is read twice through O.world.
The oracle expects both complete observer formats separately; no summary/hash
replaces full-value assertions. Native and JS must agree before oracle comparison.

Three compiling Native/JS mutants are killed: restore prior A Ledger to100,
commit failed staged publications/writes instead of rollback, and rewind allocation
only after failed rollback (causing escaped q to be reused on retry). All baseline
prefixes are actual valid operations; first differences and full mutant outputs
are retained in evidence. Original observed output and source hashes are committed.

The IO Audit here is a concrete stdout fixture service invoked before outcome,
not post-hoc diagnostics. Counts2/3 are declared standalone inputs; no Local/capture
or registration/preflight claim follows. No actual registered reader stream is
exercised, and returned Ping batches are not yet published through clock/log
integration. Full nested dispatcher, lexical captures, reader completion/failure,
Fast visibility, missing requirements, public E11 and measurements remain separate
#19 gates. No fresh TS full-trace comparison is claimed by this standalone tranche.
