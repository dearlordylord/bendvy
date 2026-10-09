# Canonical observable declaration API controls

Source-only development evidence for #56. Final subject: `4321fc69` plus the
registered-inspection deferral `9887af15` (local cherry-pick `ed40e400`). No
backend, runtime noninterference, performance or full #56 acceptance is claimed.

`positive.bend` imports the existing ordinary-declaration `caller.bend`: its
schema A/Other, array-owning affine Type Payload, owner-preserving Data view,
Column lenses and canonical Binding are reused unchanged. All seven observable
constructors and read/changed pair are concretely specialized for both schemas.
The same declaration's operational and detached inspection result types check.
Actual `observable_define` and `observable_run` have specialized typed consumer
wrappers; A registration is concretely instantiated. The source-only body
returns the owner and success; actual gameplay execution belongs to the assigned
complete consumer, not this check.

Final `source-final-01/` contains eight terminal checker results: one success and
seven intended refusals. Refusals separately cover cross-schema grant,
write-through-detached-read, normal read-to-write capability reinterpretation,
recovering undeclared selection authority from a granted query, abstract H
escape, affine owner duplication after the actual new query call, and duplication
of the actual observable Registry owner. `intended-diagnostics.json` records
expected diagnostic tokens. Each command uses the unchanged `scripts/bend-check`
(5 seconds), shared heavy lock, CPU 5 and pinned 2.0.35 tool selection. Elapsed
seconds include waiting for the shared lock. Exit 1 is a refusal only when its
retained raw diagnostic matches the intended boundary; no timeout occurred.

The entire imported source closure is captured by SHA-256 in `source-hashes.json`
and content-addressed `sources/`; tool selection and raw stdout/stderr are kept.
These are source development receipts, not the delivery runner's launch or
backend receipts. The compiler's `ALL PROOFS CHECK` text denotes typechecking
here; no new law or mathematical proof was introduced.

`development-01` retains earlier source checks and the exact first positive
subject, before concrete constructor and registration wrappers. Its five original
negative sources remain byte-identical. `development-02` retains the original
System candidate and working inspection wrapper, plus an explicitly reproduced
erased-vs-runtime type-family signature failure and its repaired source. The
first failed terminal output had not been archived at the time: that reproduction
is labelled as such, not passed off as the original attempt. Final controls do
not expose the removed registered inspection seam.

## Policy boundary found

In candidate `4321fc69`, `ordinary-system.observable_inspect` borrowed only
`Sys.cursor`, then queried an arbitrary same-schema World. `system.bend` cursor
only unpacks and reconstructs Registry fields. Unlike `Sys.run`, it neither
checks Registry/world namespaces nor calls `W.registration_matches` for current
id/name/access. Consequently the source interface accepted a Registry paired
with another world, or a world whose registration was removed. Source acceptance
is not a claim that a runtime trace was executed.

Existing execution validation is in `Sys.run_namespace_value`,
`run_namespace_checked`, and `W.registration_matches`; tracked execution flows
through those guards. `SystemInstance.run_tracked` also delegates to that guarded
execution. Copying execution's RegistrationRejected outcome into detached debug
would choose the unresolved foreign-Inspector association contract. Root deferred
the new registered-inspection API in `9887af15`; no refusal contract was invented.
Same-declaration lowerings and operational registration remain. A future public
registered-debug entry must settle that association/removed-registration policy
or use an already agreed authority-preserving API.
