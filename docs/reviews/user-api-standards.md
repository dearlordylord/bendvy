# S-USER-API Standards review

Baseline `7ea583bc8771c5243dca4495c899868a2e7dc6f9`; reviewed HEAD
`7fcbf10a29b52907868f301973012fe5fe8fa233`.
Commands: `git diff 7ea583bc8771c5243dca4495c899868a2e7dc6f9...HEAD`
and `git log 7ea583bc8771c5243dca4495c899868a2e7dc6f9..HEAD --oneline`.
Sources: AGENTS.md, docs/SPEC.md, installed Bend guide, bend-ldd and code-review.

**Hard documented-standard violations: none found in the reviewed diff.**
Task artifacts are English. New APIs retain affine Type components, explicit
closed template bodies, owner-threaded transactions and namespace creation.
Access/ownership negatives have positive controls and intended diagnostics.
Checker harnesses retain five-second limits; code generation/Clang limits are
separate. No new ECS laws/proofs, dependencies, compiler/kernel modifications,
reference edits or Canonical Tower Defense edits occur in this diff. Module
canaries and application observations are described as finite evidence; the
in-progress ledger does not claim production adoption, universal root authority,
complete qualification or issue completion.

Typed callback grants, not string metadata, form the gameplay capability boundary.
`src/ecs/README.md` explicitly says "String registration metadata alone does not
constrain a concrete runner" and documents trusted provisioning/public
constructors, broader grant bundles and two-family query follow-ups. These limits
must remain visible in the final report. The pending actor-handle delta requires
separate review; this result does not assert that its confinement gate passed.

**Heuristic follow-up: possible Primitive Obsession**, nonblocking.
`src/ecs/system.bend:9` hunk:
`Registry{namespace: U32,id: U32,name: String,access: List<&2,String>,cursor: U32}`.
Exact ordered access strings are legitimate diagnostic/validation metadata here,
not capability authority. If independently authored applications expose repeated
registration-declaration mistakes, consider nominal declaration metadata or
schema-local wrappers. Do not infer that changing strings alone grants access.

No helper/DAG, repeated parameter-list or explicit match is flagged merely for
verbosity: Bend guide/bend-ldd require head matches, dependency ordering and
owner threading, overriding generic Duplicated Code/Data Clumps/Middle Man
heuristics. Tool-enforced syntax/quantity checks are not duplicated as style
findings. This axis reviews documented standards, not completion of #26's
independent consumer, backend timing or universal refinement obligations.
