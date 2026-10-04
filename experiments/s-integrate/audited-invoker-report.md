# Actual retained Audit provisioning

`audited-invoker.bend` joins the committed closed A/B bodies to private actual
transaction adapters and the retained `dispatcher.Audit` owner. `Wrapped<Tx>`
contains the actual transaction and service; supplied fresh operations lift the
nominal getters/setters, reservation, flags and Pings without exposing this
representation to the callback. The IO logger consumes `D.audit_log`, retains
its returned owner and unwraps it only after the body returns. Transaction finish
then commits or restores the numeric journal while returning the actual Audit.
No replacement Console is constructed by the provisioning module.

Host interface: `ServiceResult<W,H>{result: A.RunResult<W,H>, audit: D.Audit}`.
For each schema, `motion_a`/`health_a` take count, explicit rejected outcome,
mark tick, world, selected actual handle and Audit. `motion_b`/`health_b` take
mode, count, mark tick, world, selected actual handle and Audit. The Host owns
reader Runs and clock advancement/publication; these helpers return chronological
Ping batches and do not complete readers or choose publication ticks.

Run `python3 experiments/s-integrate/audited-invoker-run.py` from the repository.
The fixture creates actual worlds and retained Type payloads, executes closed A,
failed B and retry with the same returned Audit, and logs through that owner
between every outcome. Every full world field and operation result is compared
to independent operation-input expectations from `transaction-ab-oracle.py`;
actual output never supplies the oracle. Each schema contributes twelve lines.
Both Native and JavaScript must agree. The compiling dropped-service-effect
mutant must differ, and affine service duplication and cross-schema token use
must be rejected for their specified diagnostics. Evidence pins the complete
local source closure and records all values, controls and first differences.

Checker and runtime invocations retain the five-second bound; code generation
and clang retain the existing separate t05 limits. No dependency or compiler
change. This is a concrete service/transaction join, not full dispatcher,
registration/capture/reader, public E11 or performance acceptance. `Audit.Console`
currently has no distinguishable internal state: the gate observes actual IO and
legal affine return, not physical pointer identity or a general service theorem.
