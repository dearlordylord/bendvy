# Actual retained Audit provisioning

`audited-invoker.bend` joins the committed closed A/B bodies to private actual
transaction adapters and the retained `dispatcher.Audit` owner. `Wrapped<Tx>`
contains the actual transaction and service; supplied fresh operations lift the
nominal getters/setters, reservation, flags and Pings without exposing this
representation to the callback. The IO logger consumes `D.audit_log`, retains
its returned owner and unwraps it only after the body returns. Transaction finish
then commits or restores the numeric journal while returning the actual Audit.
No replacement Console is constructed by the provisioning module.

Host interface: `ServiceResult<W,H,V,AV,F>{result: A.RunResult<W,H>, audit: D.Audit,
reservation: Maybe<O.BundleView<V,AV,F>>}`.
For each schema, `motion_a`/`health_a` take count, explicit rejected outcome,
mark tick, world, selected actual handle and Audit. `motion_b`/`health_b` take
mode, count, mark tick, world, selected actual handle and Audit. The Host owns
reader Runs and clock advancement/publication; these helpers return chronological
Ping batches and do not complete readers or choose publication ticks.

Run `python3 experiments/s-integrate/audited-invoker-run.py` from the repository.
The fixture creates actual worlds and retained Type payloads, executes closed A,
failed B and retry with the same returned Audit, and logs through that owner
between every outcome. Before finish, the actual retained private Type command
queue is read through owner-return `O.commands` and rebuilt. The actual returned
escaped handle ID selects its Spawn payload only when its namespace matches the
actual world namespace. Both schemas retain every Main/Aux/Flag field in nominal
BundleView, including the payload of failed q before it is discarded. The failed
and retry B bodies also perform actual `query.lookup(Required)` on their returned
transaction world with that actual reserved handle; the real Access result is
appended as `ReservedObserved`. No payload is reconstructed from input constants
or pending labels. Every full world field and operation result is compared
to independent operation-input expectations from `transaction-ab-oracle.py`;
actual output never supplies the oracle. Each schema contributes twelve lines.
Both Native and JavaScript must agree. The compiling dropped-service-effect
mutant must differ; compiling omitted-reservation-observation and wrong-lookup-
status mutants must also differ. Affine service duplication and cross-schema token use
must be rejected for their specified diagnostics. Evidence pins the complete
local source closure and records all values, controls and first differences.

Checker and runtime invocations retain the five-second bound; code generation
and clang retain the existing separate t05 limits. No dependency or compiler
change. This is a concrete service/transaction join, not full dispatcher,
registration/capture/reader, public E11 or performance acceptance. `Audit.Console`
currently has no distinguishable internal state: the gate observes actual IO and
legal affine return, not physical pointer identity or a general service theorem.

The reservation and reserved-lookup fields are finite actual-operation observations,
not a general refinement proof. The optional reservation field describes the
one escaped reservation of these closed A/B bodies; it is not a general API for
collecting arbitrary numbers of reservations. That broader capability remains
a follow-up if future callbacks need it. No observer reads an affine owner and
then reuses it: every command/world/row operation retains and returns its owner.
