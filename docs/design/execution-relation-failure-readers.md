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
The fourth nested GeneralFailureRead selection accepts the same exact witnesses
and a canonical Whole or Sparse resource model. The six top-level classes remain
unchanged. Its recipe grants ReadOnly access to the existing resource view.
That view now contains the actual Store's Data channel snapshot, sequence and
registration counter as well as its graph. The closed provider obtains this
snapshot through the canonical resource interpreter and captures the actual
scope tick; it never obtains the writable graph slot.

Trusted setup registers the Reader in the actual selected canonical Store.
Registration preserves the graph, stamp, failure sequence and channel;
its separate nextReader counter advances and the canonical snapshot refreshes.
A refused relation operation likewise refreshes the snapshot from its returned
actual Store, preserving its graph, stamp and complete refusal receipt.
The Reader remains an affine
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
first/finished/retained=0,dropped=0,older=0,maintained=0:3,sequence=0,nextReader=2,cursor=0,delivered-through=0,messages=[],calls=1,received=0,missed=0,session=777
second/finished/retained=2,dropped=0,older=2,maintained=0:7,sequence=2,nextReader=2,cursor=0,delivered-through=0,messages=[],calls=2,received=0,missed=0,session=777
third/finished/retained=1,dropped=2,older=3,maintained=0:11,sequence=3,nextReader=2,cursor=2,delivered-through=2,messages=[relation-failed{relate(1/1:0,1/1:0),family=89/scene-parent/scene-children/hierarchy,legacy=relate,source=1:0,target=1:0,reason=self-relation(1:0,scene-parent)}, relation-failed{relate(1/1:0,1/1:0),family=89/scene-parent/scene-children/hierarchy,legacy=relate,source=1:0,target=1:0,reason=self-relation(1:0,scene-parent)}],calls=3,received=2,missed=0,session=777
```

The first update selects finalApply=false. Subsequent updates enable publication.
The third consumes the two retained failures and then rotates them out at the
whole-update boundary. Reader IDs and the user Session owner remain unchanged.
Snapshot reconstruction returns all actual owners between updates. This finite
execution is not a formal proof. No new law approval or proof is claimed.

Remaining GH89 gates include ordinary non-scope linked despawn, independent graph
update scheduling, the refusal/disabled/Stop cases listed above, all entry-shape
retention wiring, and approved laws and proofs.

The schema-indexed Reader User retains the exact delivered Message values across
body errors, rather than reducing them to a count. The formatter inspects their
original operations, complete namespace/index/generation handles, descriptor,
legacy projection and every error field. `sequence` is the current channel
sequence; `delivered-through` is the actual returned Reader cursor. This API
returns no per-message sequence IDs, so the observation assigns none. The two
actual delivered records both retain the authored self-relation and its reason.
The full-message follow-up ordinary entry completed with exit 0; its captured
output is `/tmp/bendvy-gh89-failure-messages.stdout` in the delivery workspace.

## Sparse composed consumer

`examples/parallel-relations/sparse-failure-scene.bend` registers two actual
Readers before publishing two protected self-relation refusals. Its ordinary
generalized application contains two sparse ReadOnly peers using the same
resource family, with no dependency edge between them. Each retains its actual
Compilation, Book-derived access and affine Local across two updates. The
existing read body returns BodyError after consuming messages, and the ordinary
handler continues. Finished maintenance uses the complete schema catalogue.

The pinned ordinary JavaScript product compiled and ran with exit 0. Both
updates returned Finished with two real BodyFailed observations. Both Readers
ended through=2, calls=2, received=2, missed=0, retaining both complete original
messages and their distinct Sessions 777 and 888. The actual World retained
Session 401, empty graph and inverse lists, sequence=2 and nextReader=3; actual
and cached channels both ended retained=0, dropped=2, older=2. The resource stamp
remained 0:0/0:0 while the World clock reached 0:4. Both full seed refusal
receipts were retained. Captured output is
`/tmp/relations89-sparse-scene.stdout` in the delivery workspace.

This is a finite ordinary execution, not a new law or proof. Native execution,
false-condition and foreign-Reader observations, Stop/Invalid observations and
automatic retention wiring for every entry shape remain outside this evidence.
