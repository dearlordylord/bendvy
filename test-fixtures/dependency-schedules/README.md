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
scenario. Static invalid-plan and intended access controls remain separate gates.

`bevy-reference` uses the manifest-pinned Bevy source at
`ad678262ce53b5d142fe49ee5e08caff6f00ab60`. Its serial schedule runs twice after a
writer error, a false condition, a condition error and skipped admission. The
`--missing-resource` case separately establishes that a missing `Res` parameter
calls the System error handler without entering the body. The default
`Single<&Missing>` case is skippable and does not call that handler. Both cases
retain the writer's partial mutation and Local and execute later dependencies.
These returned-error cases do not specify fatal runtime exits.
