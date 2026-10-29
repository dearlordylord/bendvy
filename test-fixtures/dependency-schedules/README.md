> Verification policy override (2026-10-27): semantic verification uses Bend laws only. The new non-law models, reference tests, golden outputs and check scripts have been retired at the user's direction. References below to those checks describe historical work, not current acceptance. Historical receipts remain outside the source tree; the five approved Bend helper laws do not prove the whole ECS.

# Dependency schedule consumers

`ordinary/main.bend` registers four systems and two conditions through the
replacement declaration and System API. Its public dependency App derives
identities and requirements from those actual owners. Gameplay bodies receive
resource capabilities. They do not receive a World or a dispatch adapter.

The writer increments its genuinely affine resource and returns an ordinary
error. The first dependent condition reads the resulting state. A second
condition returns false, then an error, then true on successive runs. A further
dependent executes after each completed predecessor, including skipped and
failed work. The consumer runs twice nominally, under Alpha and Beta, and keeps
its nested resource, Local, guard and handler owner tokens through three runs.
The final observation includes registration, access, cursor, clock, empty
allocator, events, pending work, output and error facts.

`ordinary/reference.py` derives the complete expected output from the authored
scenario without importing Bend implementation code. Independent author review
of this oracle remains a delivery gate. Finite observations establish only this
scenario. `plan-controls.bend` separately checks duplicate identity, unknown dependency,
missing provision and cycle rejection with actual returned affine state and no
body invocations. Its chain-order and ready-set cases distinguish completion
dependencies from blanket serial ordering. Intended access controls remain a
separate gate.

`ordinary/admission-controls.bend` registers an actual writable condition whose
body would increment the resource. The App rejects its declaration before
condition or system invocation. Its full owner and World observation remains at
initial values in both nominal schemas.

`bevy-reference` uses the manifest-pinned Bevy source at
`ad678262ce53b5d142fe49ee5e08caff6f00ab60`. Its serial schedule runs twice after a
writer error, a false condition, a condition error and skipped admission. The
`--missing-resource` case separately establishes that a missing `Res` parameter
calls the System error handler without entering the body. The default
`Single<&Missing>` case is skippable and does not call that handler. Both cases
retain the writer's partial mutation and Local and execute later dependencies.
These returned-error cases do not specify fatal runtime exits.

The ordinary application now accepts actual system and condition owners plus
closed `dependency-registry-program.Selection` definitions. A selection receives
an abstract registry family and closed leaf, pair, partition, rootcut and empty
builders. A rootcut retains the actual owner products and interprets both closed
scope selections; its condition compiler derives read-only checks from those
same scope trees. Each leaf
compiles the actual owner's declaration Program; conditions additionally require
read-only permissions. The default entry cannot accept detached registry nodes,
a cached validation flag, or a custom World dispatcher. The explicitly named
`trusted_build_checked` entry remains a low-level interpreter boundary.

The `negative` controls must fail source checking: `raw-system-registry` rejects
a detached body registry, `forged-condition-cache` rejects the reported cleared
cache bypass, `forged-family` cannot construct the hidden family, and
`custom-dispatch` cannot substitute a dispatcher for the canonical leaf provider.
These are compile-time controls; the positive `ordinary/admission-controls.bend`
observes writable guard refusal while retaining all actual owners.
