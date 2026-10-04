# Payload operation subjects — unapproved draft

`payload.position_get/vitals_get/velocity_get/armor_get/motion_ledger_get/health_ledger_get`
return the actual affine record and every array element plus every metadata field.
`payload.position_swap/vitals_swap/motion_ledger_swap/health_ledger_swap` replace
only slot0, return its prior scalar and preserve all other elements and metadata.
Domain: the trace's actual four-element arrays and bounded U32 values; no arbitrary
array-index or destructive restoration contract is proposed. These operations
implement SI-OWNER-EDIT/TX-MAIN/TX-LEDGER's already drafted subjects.

Preimplementation full-field oracle perturbations are recorded in
`storage-observation-evidence.json` and `transaction-predicates.bend`: valid
Motion/Health cases pass; wrong old value, tail or metadata is rejected. These
are predicate falsification inputs, not executed payload bodies or proofs.
Actual owner-return controls and compiling wrong-slot mutants follow implementation.
General proofs require exact law approval separately.
