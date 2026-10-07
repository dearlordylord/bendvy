# Bounded prepared view fusion

Draft implementation note for #30; performance selection remains pending.

Current different-row views construct an Accepted/Prepared/Owned/State carrier,
then unpack it to project the actual previous owner and construct a second carrier.
The dense warm diagnostic attributes extra work to Column view/swap transport;
406 found different-row views per Workshop make this intermediate route observable.

Add an internal view seeker with the existing descending-owner provisioning,
ascending seek order, two-step fuel, history and stamp behavior. Found terminals
project the actual owner exactly once and store the owner returned by project in
one final carrier. Nil precedes fuel exhaustion; nonempty exhaustion resets current
to zero and retains all remaining owners. The old current owner moves to history
once. Backward access retains exact ordinary recovery/swap/projection. Writers and
old public seek/phase APIs remain unchanged; no family or workload simplification.

Verify partial fuels against the old view route, including a legal projection that
changes its returned affine Array payload. Observe both returned view and full
recovered cells, alongside aliases, holes, bounds, deep wrappers, fallback,
transaction rollback, archived producer/recovery comparison, mutation and access
controls. Inspect emitted Native widths and JS code growth. Retain the unchanged
paired gate: fewer constructors is not performance acceptance.

Do not replace Component.has with a pure membership read. Admitted project types
allow a changed returned owner; suppressing that call changes existing behavior.
