# Public schedules (#33)

Run `python3 experiments/public-schedules/run.py` from the repository root. It
creates a fresh source-bound receipt under `.artifacts/public-schedules-*` and
refuses source drift across the full relative Bend import DAG. The installed
Bend/Node and previously approved private Clang19 are used; checker/runtime5,
emission30 and native compilation120 second caps remain.

The actual pinned TS oracle and Bend JS/Native run the same six scenarios,
including two repeat executions per valid schedule. Complete outputs compare
phase/order/status, every resource value, event payload and live entity ID,
including the final explicit command drain. False conditions still allow marker
execution. Failure writes resource777, stages event7 and a command, then uses the
actual transaction rollback; prior commits/commands persist. IDs1,3 after failure
are intentional observed TS reservation semantics.

The harness requires affine/schema negatives, mutations inside the actual called
abstract condition callback for undeclared access and writing through read, and
runtime foreign-world rejection on both backends. All three order, condition and
implicit-flush mutants must check, emit and execute on both backends before their
complete observation mismatch counts as detected. A compile failure cannot pass
mutation acceptance.

`main.bend` demonstrates two independent registrations of the same closed runner.
The public owner type itself is arbitrary affine Type and supports heterogeneous
registry records. Closed dispatch/catalog are trusted typed provisioning; gameplay
gets abstract capabilities. No Data-only component restriction is introduced.

This feature's complete process timings are diagnostic command receipt fields,
not hot-path qualification. Root integration additionally runs the unchanged
#28 Workshop regression gate and independent reviews before delivery.
