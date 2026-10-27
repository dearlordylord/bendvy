# Ordinary protected relation failure readers

The ordinary resource-read selection has a third, explicit FailureRead branch.
The six top-level Builder classes remain unchanged. The same closed declaration
and Compilation produce the opaque capability and its read footprint. The
capability accepts an abstract H and its retained Reader, and returns H plus the
channel reading. It exposes neither the graph owner nor an owner transform.

The branch requires the actual full schema, route, grant validity, descriptor,
payload equality, view equality and ProtectedRelation policy equality. A separate
physical slot equality binds the local Whole resource model to that same full
origin. It does not recover a type from a policy, resource key or entity index.
The generic resource-read operations continue to expose only cached graph views.
Sparse/general composed failure reads remain an explicit delivery gap.

Trusted setup registers the Reader in the actual selected canonical Store.
Registration preserves the graph, cache, stamp, failure sequence and channel;
only its separate nextReader counter advances. The Reader remains an affine
Local owner. Local.invoke advances its cursor before calling the body and
retains the returned cursor on BodyError. Conditions precede body invocation.
No invocation occurs for a false condition. Actual false-condition and foreign
Reader consumer evidence remains to be delivered for this new selection.

## Whole-update retention

The schema-bound retention catalogue contains closed typed callbacks and their
route manifest. Its constructor deduplicates routes. Admission checks every
ProtectedRelation leaf of the actual full schema before the run. It refuses an
incomplete catalogue rather than maintaining a subset. Actual payload/view/policy
proofs are required for every callback, independently of that coverage check.

The ordinary Root owned-completion hook consumes the accepted callback once,
after final deferred policy. The callback composes existing lifecycle maintenance
and rotates relation failure generations only on overall Finished. This includes
finalApply=false. Stop and Invalid return their exact actual state and reports.
The generalized adapter additionally retains refused physical-cut inventories
without treating them as a World. Automatic wiring for all application entry
shapes and actual Stop/Invalid observations remain explicit delivery gaps.

Retention does not advance the World clock or any Reader. It preserves actual
World owners, graph, graph cache, resource stamp, failure sequence and nextReader.
Two updates at the same administrative tick must still rotate twice. The existing
shared channel implements the same sequence-based two-generation policy used by
the machine stream. Pure queue/channel/journal helpers now use erased generic
indices internally; all historical public template entry signatures delegate to
the same algorithms. This repairs nested command/reader source instantiation
without changing a compiler limit or storage policy.

Bevy's pinned source ad678262ce53b5d142fe49ee5e08caff6f00ab60 supplies
[reader count semantics](../../.references/bevy/crates/bevy_ecs/src/message/message_cursor.rs)
and [generation maintenance](../../.references/bevy/crates/bevy_ecs/src/message/messages.rs).
Bend additionally retains affine Local owners and explicit refusal inventories.
These ownership details are this project's contract.

## Actual ordinary consumer

`examples/parallel-relations/failure-scene.bend` starts with actual Factory/schema
setup, registers a Reader from its real Store, and runs an ordinary nested Tree
containing the existing relation command author and the new registered Reader.
It checks the retained SchemaCreated Context before executing any system and
admits the complete typed schema catalogue. It uses Root's real deferred queue,
owned completion callback and returned reports. Every read body returns BodyError
and the handler continues.

The pinned ordinary Bend entry completed with exit 0 and these observations:

```text
first/finished/retained=0,dropped=0,older=0,maintained=0:3,sequence=0,nextReader=2,cursor=0,calls=1,received=0,missed=0,session=777
second/finished/retained=2,dropped=0,older=2,maintained=0:7,sequence=2,nextReader=2,cursor=0,calls=2,received=0,missed=0,session=777
third/finished/retained=1,dropped=2,older=3,maintained=0:11,sequence=3,nextReader=2,cursor=2,calls=3,received=2,missed=0,session=777
```

The first update selects finalApply=false. Subsequent updates enable publication.
The third consumes the two retained failures and then rotates them out at the
whole-update boundary. Reader IDs and the user Session owner remain unchanged.
Snapshot reconstruction returns all actual owners between updates. This finite
execution is not a formal proof. No new law approval or proof is claimed.

Remaining GH89 gates include ordinary non-scope linked despawn, independent graph
update scheduling, the refusal/disabled/Stop cases listed above, all entry-shape
retention wiring, and approved laws and proofs.
