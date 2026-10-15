# Ordinary initialization source controls

These controls separate initialization ownership and schema typing from the
ordinary queued-write grant controls.

- `affine-owner-positive.bend` defines a generic adapter that threads its
  `World` owner through `Init.init_state` and `Init.insert_state`, then calls it
  at both the concrete `SchemaA` fixture specialization and a `Type` resource
  specialization carrying a linear function field.
- `negative-cross-schema-init.bend` applies a `SchemaB` declaration to a
  `SchemaA` world. The pinned checker is expected to reject the nominal
  `Declaration` mismatch.
- The path-preserving 33-source mutant mirror and its exact manifest are retained
  in `../current-delivery-v1/EVIDENCE.zip`, indexed by the packet's full
  `sourcePath` records. The sole semantic mutation reruns the default effect
  in the occupied `init_checked` arm. Its full JS counteroutput rejects the
  normal oracle. Redundant working-tree copies were removed after byte-for-byte
  archive verification. Checker recaptures timed out and remain inconclusive,
  separately from the successful mutant execution.

Run the positive entry with the repository's pinned checker. Run the cross-schema entry with the same checker and expect a
`Declaration<SchemaA,...>` versus `Declaration<SchemaB,...>` type error.

Queued-write authority remains covered by the existing
`experiments/public-machines/remaining-core-v1/ordinary-frontend-v1/public-successor-v1/`
controls (`negative-undeclared.bend`, `negative-cross-schema.bend`,
`negative-read-write.bend`, and `negative-owner-duplicate.bend`) and its
dropped-write control. Those exercise queued system writes; they do not impose
a capability restriction on the administrative whole-World init/insert API.
