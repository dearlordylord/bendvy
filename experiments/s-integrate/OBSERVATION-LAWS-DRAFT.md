# Observation adapters — unapproved draft

`observations.world` threads the actual World owner and reports every row,
pending command payload, Ledger field, allocator, namespace and Mode. Pending
observations are in application FIFO order. It changes no owner, mark or clock.
`observations.client` is a rank-2 query callback returning both abstract providers
with full Main/Aux/Flag/handle observations; query ordering/selection stays in query.
The configured getters are the pinned `payload.*_get` operations on the trace's
four-element arrays. This is not an arbitrary-length or arbitrary-getter encoder.

These are SI-Q-EXACT/SI-Q-LOOKUP/SI-OWNER-EDIT's planned observation bindings.
Full-field valid/perturbed oracle cases precede the bodies in
`storage-observation-evidence.json`; those cases are not executed adapter evidence.
Actual controls must compare independently supplied complete values and read the
returned owners again. No owner identity or general law proof is inferred.
