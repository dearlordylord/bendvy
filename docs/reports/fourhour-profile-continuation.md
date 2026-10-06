# Four-hour profile-guided continuation — active

Authorization: user granted four hours, 2026-10-06T05:51:16Z–09:51:16Z,
including preparation, source experiments, controls, observations and delivery.
Governing issues: #21 and #24. JS/TS <=1 and Native/TS <=0.5 remain unmet.

Exact baseline: fold/noAux closure
`49614f72311af5b03123d536ff301115d28b8886bf516b0d7057a8c52e68ad38`;
master at start `d0b43c2fd03fc872a360938b074f42e3bafb83a6`.
The historical canonical20-attempt session is untouched; this is direct bounded
investigation, not a new qualified keep contract or production acceptance.

Main uncertainties: avoidable Health/Ledger owner reconstruction in emitted JS;
dynamic Native runtime cost after request-word reduction. Investigate actual
source and generated code before changing representation. Preserve authored
callbacks, arbitrary affine Type ownership, rollback and negative controls.

Limits: executable diagnostic checker15s, default/proofs5s, emission30s,
Clang120s, runtime5s. Private Clang19 remains separate. No new dependencies,
laws/proofs, compiler/kernel/reference or external-repository changes.

## Fresh baseline diagnostics

Native phase profiles on both schemas match actual65 TS worlds. Motion dynamic
branch counters match65 fields:4.235m outer destruction iterations/12.714m inner,
4.223m atomic RFC decrements. Destroyed nodes are primarily journal Cons/Handle/
MainInverse. These are operation counts, not elapsed attribution or physicalRAM.
See [Native evidence](../../experiments/s-prep/native-joined-hotpath/README.md).

Retained Health JS driver with V8 optimization tracing matches all nine actual TS
worlds; one prepare-for-OSR bailout, no other observed JS bailout/abort/disable.
This bounds an unsupported recurring-deoptimization hypothesis, not all JIT behavior.
See [JIT evidence](../../experiments/s-prep/source-js-jit-diagnostics/README.md).

The new source/build-pinned observation recipe passes on identical Health source
and binaries for both roles, preserving all65 worlds. Native253/257ms and JS287/
300ms are single raw unchanged-source observations, not qualification or a gain.

Status: active. Isolated source experiments investigate ledger owner flattening,
private journal representation, query transport and the actually reached generic
publish frontier. No changed-source elapsed result or new adoption exists yet.
